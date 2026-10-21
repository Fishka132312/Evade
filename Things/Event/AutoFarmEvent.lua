if _G.FarmUnload then pcall(_G.FarmUnload) end  --йуцйуй1

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local LP = Players.LocalPlayer

if _G.FarmEvent == nil then _G.FarmEvent = false end
_G.FarmPauseUntil = 0
_G.PauseFarm = function(sec) _G.FarmPauseUntil = os.clock() + (sec or 5) end
_G.ResumeFarm = function() _G.FarmPauseUntil = 0 end

local CFG = {
	-- защита от монстров
	enemyRadius = 22,        -- базовый радиус опасности
	enemyRadiusMax = 140,    -- максимум, до которого радиус растёт от скорости монстра
	reactionTime = 0.6,      -- на сколько секунд вперёд предсказываем движение монстра
	jumpDistance = 35,       -- если монстр сместился больше чем на это за кадр = телепорт/рывок
	erraticRadius = 60,      -- радиус опасности вокруг "телепортящегося" монстра
	dangerHold = 0.8,        -- сколько сек. сидим в безопасности после последней угрозы
	escapeCooldown = 0.05,   -- кулдаун телепорта при побеге (маленький!)
	safeHeight = 1000,

	-- тикеты
	teleportCooldown = 0.4,
	clearRadius = 18,
	clearInterval = 0.15,

	-- Glorp Cat
	glorpName = "glorpcat",  -- имя без пробелов, в нижнем регистре
	glorpLead = 0.12,        -- доп. запас предсказания (сек) сверх пинга
	glorpMaxLead = 0.6,      -- максимум предсказания (сек)
	glorpAhead = 2,          -- на сколько studs впереди него вставать
	glorpCooldown = 0.03,    -- как часто можно тпшиться за ним
	glorpStopDist = 3,       -- ближе этого не тпшимся
	glorpTryInterval = 0.15, -- сколько стоим на одной позиции (сек, + 2*пинг), потом, если Glorp не пропал, меняем позицию
	glorpDangerScale = 0.6,  -- у Glorp допускаем монстров ближе (риск ради него); 1 = как обычно

	-- Glorp: фазы "tween" (тп рядом + плавно догоняем) и "snap" (старый метод тпшиться на позиции), чередуются
	glorpTweenTime = 1.2,    -- сколько сек. длится фаза догоняния
	glorpSnapTime = 1.5,     -- сколько сек. длится фаза тпшинга по паттерну
	glorpTweenSpeed = 90,    -- скорость догоняния (studs/сек)
	glorpApproach = 6,       -- на сколько studs позади него появляемся при первом тп
	glorpTouchInterval = 0.05, -- как часто пинать firetouchinterest / prompt / click
	glorpDebug = true,       -- писать в консоль (F9) что за объект Glorp и в какой фазе он пропал

	ignoreRealPlayers = true,
}

-- Порядок попыток, если Glorp не собрался (не пропал): {вдоль движения (+ вперёд / - назад), вбок, вверх} в studs
local GLORP_PATTERN = {
	{ CFG.glorpAhead, 0, 0 }, -- сначала как раньше: чуть спереди
	{ 0, 0, 0 },              -- прямо в него
	{ -2, 0, 0 },             -- чуть ближе (сзади)
	{ 5, 0, 0 },              -- дальше спереди
	{ -5, 0, 0 },
	{ 9, 0, 0 },
	{ -9, 0, 0 },
	{ 0, 3, 0 },              -- вбок
	{ 0, -3, 0 },
	{ 0, 0, 3 },              -- выше / ниже
	{ 0, 0, -3 },
	{ 14, 0, 0 },
	{ -14, 0, 0 },
}

local HIDDEN = CFrame.new(0, -10000, 0)
local connections, ownParts = {}, {}
local collisionMemory = {}
local wasFarming, lastTeleport, lastClear = false, 0, 0
local atTicket = false
local dangerUntil = 0
local frameId = 0

local realCharacters = {}

local function trackPlayer(plr)
	if plr.Character then realCharacters[plr.Character] = true end
	table.insert(connections, plr.CharacterAdded:Connect(function(char)
		realCharacters[char] = true
	end))
	table.insert(connections, plr.CharacterRemoving:Connect(function(char)
		realCharacters[char] = nil
	end))
end

for _, plr in ipairs(Players:GetPlayers()) do trackPlayer(plr) end
table.insert(connections, Players.PlayerAdded:Connect(trackPlayer))
table.insert(connections, Players.PlayerRemoving:Connect(function(plr)
	if plr.Character then realCharacters[plr.Character] = nil end
end))

local function isRealPlayerCharacter(model)
	if realCharacters[model] then return true end
	if Players:GetPlayerFromCharacter(model) then return true end
	if Players:FindFirstChild(model.Name) then return true end
	return false
end

local function isGlorp(model)
	local n = string.lower(model.Name):gsub("[%s_%-]", "")
	return string.find(n, CFG.glorpName, 1, true) ~= nil
end

local function isHostileNPC(model)
	local char = LP.Character
	if model == char then return false end
	if char and model:IsDescendantOf(char) then return false end
	if not model:FindFirstChild("HumanoidRootPart") then return false end

	if isGlorp(model) then return false end -- Glorp не враг, а цель

	if CFG.ignoreRealPlayers and isRealPlayerCharacter(model) then
		return false
	end

	local aiAttr = model:GetAttribute("AI")
	if aiAttr == false then return false end

	local hum = model:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health <= 0 then return false end

	return true
end

local function makePlatform(size, transparency)
	local p = Instance.new("Part")
	p.Size = size
	p.Anchored = true
	p.CanCollide = true
	p.Transparency = transparency
	p.CastShadow = false
	p.CanQuery = false
	p.Locked = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.CFrame = HIDDEN
	p.Parent = workspace
	table.insert(ownParts, p)
	return p
end

local safePlatform = makePlatform(Vector3.new(20, 1, 20), 0.7)
local standPlatform = makePlatform(Vector3.new(10, 1, 10), 0.6)

local function isOwn(obj)
	for _, p in ipairs(ownParts) do
		if obj == p then return true end
	end
	return false
end

local function getRoot()
	local char = LP.Character
	return char and char:FindFirstChild("HumanoidRootPart") or nil
end

local function getHumanoid()
	local char = LP.Character
	return char and char:FindFirstChildOfClass("Humanoid") or nil
end

local function isAlive()
	local hum = getHumanoid()
	return hum ~= nil and hum.Health > 0
end

local function rootOffset()
	local hum = getHumanoid()
	if hum and hum.RigType == Enum.HumanoidRigType.R15 then return 3.5 end
	return 3
end

local function restoreArea()
	for part, original in pairs(collisionMemory) do
		if part.Parent then
			pcall(function() part.CanCollide = original end)
		end
	end
	table.clear(collisionMemory)
end

local function clearArea(pos)
	local ok, found = pcall(function()
		return workspace:GetPartBoundsInRadius(pos, CFG.clearRadius)
	end)
	if not ok or not found then return end

	local char = LP.Character
	for _, obj in ipairs(found) do
		if obj:IsA("BasePart") and obj.CanCollide and not isOwn(obj)
			and not (char and obj:IsDescendantOf(char))
			and collisionMemory[obj] == nil then
			collisionMemory[obj] = true
			obj.CanCollide = false
		end
	end
end

-- clearArea не чаще чем раз в clearInterval (иначе при постоянных тп будут лаги)
local function clearAreaThrottled(pos, now)
	if now - lastClear >= CFG.clearInterval then
		lastClear = now
		clearArea(pos)
	end
end

local function teleport(root, cframe, clear)
	local now = os.clock()
	if clear then
		clearAreaThrottled(cframe.Position, now)
	else
		restoreArea()
	end

	root.CFrame = cframe
	pcall(function()
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end)
	lastTeleport = now
end

local function hidePlatforms()
	safePlatform.CFrame = HIDDEN
	standPlatform.CFrame = HIDDEN
end

local function getRandomSpawn()
	local map = workspace:FindFirstChild("Map")
	local partsFolder = map and map:FindFirstChild("Parts")
	local spawns = partsFolder and partsFolder:FindFirstChild("Spawns")
	if not spawns then return nil end

	local valid = {}
	for _, child in ipairs(spawns:GetChildren()) do
		if child:IsA("PVInstance") then table.insert(valid, child) end
	end
	if #valid == 0 then return nil end
	return valid[math.random(1, #valid)]
end

local function getNearestTicket(myPos)
	local effects = workspace:FindFirstChild("Effects")
	local folder = effects and effects:FindFirstChild("Tickets")
	if not folder then return nil end

	local best, bestDist = nil, math.huge
	for _, child in ipairs(folder:GetChildren()) do
		if child:IsA("PVInstance") then
			local ok, pos = pcall(function() return child:GetPivot().Position end)
			if ok then
				local d = (pos - myPos).Magnitude
				if d < bestDist then best, bestDist = pos, d end
			end
		end
	end
	return best
end

----------------------------------------------------------------
-- ТРЕКИНГ МОНСТРОВ (позиция, скорость, детект телепортов)
----------------------------------------------------------------
local tracked = {}  -- [model] = {pos, vel, t, jumpUntil, stamp}
local npcList = {}  -- список на текущий кадр

local function updateNPCs(now)
	frameId += 1
	table.clear(npcList)

	local folder = workspace:FindFirstChild("Players")
	if folder then
		for _, model in ipairs(folder:GetChildren()) do
			if model:IsA("Model") and isHostileNPC(model) then
				local r = model:FindFirstChild("HumanoidRootPart")
				local pos = r.Position
				local st = tracked[model]
				if not st then
					st = { pos = pos, vel = Vector3.zero, t = now, jumpUntil = 0, stamp = frameId }
					tracked[model] = st
				else
					local dt = now - st.t
					if dt > 0 then
						local delta = pos - st.pos
						local dist = delta.Magnitude
						if dist >= CFG.jumpDistance then
							-- монстр телепортнулся: скорость не трогаем, помечаем как опасного
							st.jumpUntil = now + CFG.dangerHold * 2
						else
							st.vel = st.vel:Lerp(delta / dt, 0.5)
						end
						st.pos = pos
						st.t = now
					end
					st.stamp = frameId
				end

				table.insert(npcList, {
					pos = pos,
					vel = st.vel,
					speed = st.vel.Magnitude,
					jumpUntil = st.jumpUntil,
				})
			end
		end
	end

	for model, st in pairs(tracked) do
		if st.stamp ~= frameId then tracked[model] = nil end
	end
end

-- есть ли угроза в точке pos (учитывает скорость, направление и телепорты монстров)
local function threatAt(pos, scale)
	scale = scale or 1
	local now = os.clock()
	for _, n in ipairs(npcList) do
		local d = (n.pos - pos).Magnitude

		-- 1) радиус растёт со скоростью монстра
		local radius = math.min(CFG.enemyRadius + n.speed * CFG.reactionTime, CFG.enemyRadiusMax) * scale
		if d <= radius then return true end

		-- 2) куда монстр добежит за reactionTime: ближайшая точка его пути к нам
		if n.speed > 1 then
			local seg = n.vel * CFG.reactionTime
			local len2 = seg:Dot(seg)
			local t = 0
			if len2 > 0 then
				t = math.clamp((pos - n.pos):Dot(seg) / len2, 0, 1)
			end
			local closest = n.pos + seg * t
			if (closest - pos).Magnitude <= CFG.enemyRadius * scale then return true end
		end

		-- 3) монстр недавно телепортировался — держим большую дистанцию
		if n.jumpUntil > now and d <= CFG.erraticRadius * scale then return true end
	end
	return false
end

local function findSafeCFrame()
	local map = workspace:FindFirstChild("Map")
	local zones = map and map:FindFirstChild("SafeZones")
	local base = Vector3.new(0, 0, 0)
	if zones and zones:IsA("PVInstance") then
		local ok, pivot = pcall(function() return zones:GetPivot().Position end)
		if ok then base = pivot end
	end

	local offsets = {
		Vector3.new(0, CFG.safeHeight, 0),
		Vector3.new(100, CFG.safeHeight, 0),
		Vector3.new(-100, CFG.safeHeight, 0),
		Vector3.new(0, CFG.safeHeight, 100),
		Vector3.new(0, CFG.safeHeight, -100),
		Vector3.new(50, CFG.safeHeight + 200, 50),
		Vector3.new(-50, CFG.safeHeight + 200, -50),
		Vector3.new(0, CFG.safeHeight + 500, 0),
	}

	for _, offset in ipairs(offsets) do
		local testPos = base + offset
		if not threatAt(testPos, 1) then
			return CFrame.new(testPos)
		end
	end

	return CFrame.new(base + Vector3.new(0, CFG.safeHeight + 1000, 0))
end

----------------------------------------------------------------
-- GLORP CAT
----------------------------------------------------------------
local glorp = {
	model = nil, pos = nil, vel = Vector3.zero, lastChange = 0, attempt = 1, tryStart = nil, force = false,
	root = nil, real = Vector3.zero, dir = Vector3.new(0, 0, -1),
	phase = "tween", phaseStart = 0, arrived = false,
	lastTouch = 0, cacheModel = nil, cacheT = 0, parts = {}, prompts = {}, clicks = {},
	seenAt = 0,
}
local pingCache, pingT = 0.1, 0

local hasFTI = type(firetouchinterest) == "function"
local hasFPP = type(fireproximityprompt) == "function"
local hasFCD = type(fireclickdetector) == "function"

local function resetGlorpPhase(now)
	glorp.phase, glorp.phaseStart, glorp.arrived = "tween", now, false
	glorp.attempt, glorp.tryStart, glorp.force = 1, nil, false
end

local function refreshGlorpCache(model, now)
	if glorp.cacheModel == model and now - glorp.cacheT < 1 then return end
	glorp.cacheModel, glorp.cacheT = model, now
	table.clear(glorp.parts)
	table.clear(glorp.prompts)
	table.clear(glorp.clicks)
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("BasePart") then
			table.insert(glorp.parts, d)
		elseif d:IsA("ProximityPrompt") then
			table.insert(glorp.prompts, d)
		elseif d:IsA("ClickDetector") then
			table.insert(glorp.clicks, d)
		end
	end
end

local function debugGlorp(model)
	local counts = {}
	for _, d in ipairs(model:GetDescendants()) do
		counts[d.ClassName] = (counts[d.ClassName] or 0) + 1
	end
	local list = {}
	for k, v in pairs(counts) do table.insert(list, k .. "=" .. v) end
	print("[Glorp] найден:", model:GetFullName(), "|", table.concat(list, ", "))
	print("[Glorp] firetouchinterest:", hasFTI, "| fireproximityprompt:", hasFPP, "| fireclickdetector:", hasFCD)
	for k, v in pairs(model:GetAttributes()) do print("[Glorp] attr", k, v) end
end

-- говорим серверу что мы коснулись Glorp всеми способами, которые есть у экзекутора
local function touchGlorp(root, now)
	if now - glorp.lastTouch < CFG.glorpTouchInterval then return end
	glorp.lastTouch = now
	if not glorp.model then return end
	refreshGlorpCache(glorp.model, now)

	if hasFTI then
		for _, part in ipairs(glorp.parts) do
			if part.Parent then
				pcall(firetouchinterest, root, part, 0)
				pcall(firetouchinterest, root, part, 1)
			end
		end
	end
	if hasFPP then
		for _, pr in ipairs(glorp.prompts) do
			if pr.Parent then pcall(fireproximityprompt, pr) end
		end
	end
	if hasFCD then
		for _, cd in ipairs(glorp.clicks) do
			if cd.Parent then pcall(fireclickdetector, cd) end
		end
	end
end

local function getPing(now)
	if now - pingT > 0.5 then
		pingT = now
		local ok, ms = pcall(function()
			return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
		end)
		if ok and type(ms) == "number" then pingCache = ms / 1000 end
	end
	return pingCache
end

local function findGlorp()
	local folder = workspace:FindFirstChild("Players")
	if not folder then return nil end
	for _, m in ipairs(folder:GetChildren()) do
		if m:IsA("Model") and isGlorp(m) then
			local r = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
			if r then
				local hum = m:FindFirstChildOfClass("Humanoid")
				if not hum or hum.Health > 0 then
					return m, r
				end
			end
		end
	end
	return nil
end

-- возвращает предсказанную позицию Glorp Cat или nil, если его нет
local function getGlorpTarget(now)
	local model, r = findGlorp()
	if not model then
		if glorp.model and CFG.glorpDebug then
			print(string.format("[Glorp] пропал через %.2f сек, последняя фаза: %s (попытка %d)",
				now - glorp.seenAt, glorp.phase, glorp.attempt))
		end
		glorp.model, glorp.pos, glorp.root = nil, nil, nil
		glorp.vel = Vector3.zero
		resetGlorpPhase(now) -- собрали / пропал: сбрасываем попытки
		return nil
	end

	local pos = r.Position
	glorp.root, glorp.real = r, pos
	if glorp.model ~= model or not glorp.pos then
		glorp.model, glorp.pos, glorp.vel, glorp.lastChange = model, pos, Vector3.zero, now
		glorp.seenAt = now
		resetGlorpPhase(now)
		if CFG.glorpDebug then debugGlorp(model) end
	else
		-- позиции с сервера приходят пачками, поэтому считаем скорость только при реальном изменении
		local delta = pos - glorp.pos
		if delta.Magnitude > 0.01 then
			local dt = now - glorp.lastChange
			if dt > 0 then
				local inst = delta / dt
				if inst.Magnitude > 400 then inst = glorp.vel end -- телепорт самого Glorp
				glorp.vel = glorp.vel:Lerp(inst, 0.5)
			end
			glorp.pos = pos
			glorp.lastChange = now
		elseif now - glorp.lastChange > 0.3 then
			glorp.vel = glorp.vel * 0.8 -- давно не двигался
		end
	end

	local vel = glorp.vel
	if vel.Magnitude < 1 then
		local hum = model:FindFirstChildOfClass("Humanoid")
		if hum and hum.MoveDirection.Magnitude > 0.1 then
			vel = hum.MoveDirection * hum.WalkSpeed
		end
	end

	-- задержка: мы видим его с опозданием ~ping, и наш тп дойдёт до сервера тоже с опозданием
	local lead = math.clamp(getPing(now) + CFG.glorpLead, 0, CFG.glorpMaxLead)
	local base = pos + vel * lead

	-- Glorp всё ещё есть, а мы уже стояли на текущей позиции достаточно долго => не собрался, пробуем следующую позицию
	local tryTime = CFG.glorpTryInterval + getPing(now) * 2
	if glorp.tryStart and now - glorp.tryStart >= tryTime then
		glorp.attempt = glorp.attempt % #GLORP_PATTERN + 1
		glorp.tryStart = now
		glorp.force = true -- тпшимся даже если уже ближе glorpStopDist
	end

	-- направление его движения (в плоскости XZ); если стоит — берём куда смотрит
	local dir
	if vel.Magnitude > 1 then
		local f = Vector3.new(vel.X, 0, vel.Z)
		if f.Magnitude > 0.01 then dir = f.Unit end
	end
	if not dir then
		local lv = r.CFrame.LookVector
		local f = Vector3.new(lv.X, 0, lv.Z)
		dir = f.Magnitude > 0.01 and f.Unit or Vector3.new(0, 0, -1)
	end
	glorp.dir = dir
	local side = dir:Cross(Vector3.new(0, 1, 0))

	local o = GLORP_PATTERN[glorp.attempt]
	return base + dir * o[1] + side * o[2] + Vector3.new(0, o[3], 0)
end

----------------------------------------------------------------
local function stopFarming(root)
	wasFarming = false
	atTicket = false
	hidePlatforms()
	restoreArea()

	if root then
		local spawnPoint = getRandomSpawn()
		if spawnPoint then
			local ok, pos = pcall(function() return spawnPoint:GetPivot().Position end)
			if ok then
				local dest = CFrame.new(pos + Vector3.new(0, rootOffset() + 2, 0))
				clearArea(dest.Position)
				root.CFrame = dest
				pcall(function()
					root.AssemblyLinearVelocity = Vector3.zero
					root.AssemblyAngularVelocity = Vector3.zero
				end)
				task.delay(0.35, restoreArea)
			end
		end
	end
end

local function onHeartbeat(dt)
	dt = dt or (1/60)
	local farming = _G.FarmEvent == true
	local paused = os.clock() < (_G.FarmPauseUntil or 0)
	local root = getRoot()

	if (not farming) or paused or (not isAlive()) then
		if wasFarming then
			stopFarming((not paused) and isAlive() and root or nil)
		end
		return
	end

	if not root then return end
	wasFarming = true

	local now = os.clock()
	local offset = rootOffset()

	-- каждый кадр обновляем монстров и Glorp
	updateNPCs(now)
	local gTarget = getGlorpTarget(now)
	local scale = gTarget and CFG.glorpDangerScale or 1

	if threatAt(root.Position, scale) or (gTarget and threatAt(gTarget, scale)) then
		dangerUntil = now + CFG.dangerHold
	end
	local danger = now < dangerUntil

	local function goSafe()
		local high = findSafeCFrame()
		safePlatform.CFrame = high - Vector3.new(0, offset + 0.5, 0)
		standPlatform.CFrame = HIDDEN

		if atTicket then
			restoreArea()
			atTicket = false
		end

		-- побег НЕ ограничен большим кулдауном
		if (root.Position - high.Position).Magnitude > 15
			and now - lastTeleport > CFG.escapeCooldown then
			teleport(root, high, false)
		end
	end

	-- 1) монстры рядом / быстро приближаются / телепортируются
	if danger then
		goSafe()
		return
	end

	-- 2) Glorp Cat — приоритет над тикетами
	if gTarget then
		local dest = CFrame.new(gTarget)
		standPlatform.CFrame = dest - Vector3.new(0, offset + 0.5, 0)
		safePlatform.CFrame = HIDDEN

		-- чередуем фазы: tween (тп рядом + плавно догоняем) <-> snap (тпшимся по паттерну)
		local phaseLen = (glorp.phase == "tween") and CFG.glorpTweenTime or CFG.glorpSnapTime
		if now - glorp.phaseStart >= phaseLen then
			glorp.phase = (glorp.phase == "tween") and "snap" or "tween"
			glorp.phaseStart = now
			glorp.arrived = false
			glorp.tryStart = nil
			glorp.attempt = 1
			glorp.force = false
		end

		if glorp.phase == "tween" then
			if not glorp.arrived then
				-- 1) тп рядом с ним, чуть позади
				local start = glorp.real - glorp.dir * CFG.glorpApproach
				teleport(root, CFrame.new(start), true)
				glorp.arrived = true
			else
				-- 2) плавно догоняем его реальную позицию, двигаясь с его скоростью (чтобы касание было "настоящим")
				local target = glorp.real + glorp.vel * math.clamp(getPing(now), 0, 0.3)
				local delta = target - root.Position
				local dist = delta.Magnitude
				local step = CFG.glorpTweenSpeed * dt
				local newPos = (dist <= step) and target or (root.Position + delta.Unit * step)
				clearAreaThrottled(newPos, now)
				root.CFrame = CFrame.new(newPos)
				pcall(function()
					root.AssemblyLinearVelocity = glorp.vel
					root.AssemblyAngularVelocity = Vector3.zero
				end)
				lastTeleport = now
			end
			atTicket = true
		else
			-- snap: старый метод
			if ((root.Position - gTarget).Magnitude > CFG.glorpStopDist or glorp.force)
				and now - lastTeleport > CFG.glorpCooldown then
				teleport(root, dest, true)
				atTicket = true
				glorp.force = false
				if not glorp.tryStart then glorp.tryStart = now end -- начали попытку на этой позиции
			elseif atTicket then
				clearAreaThrottled(gTarget, now)
			end
		end

		-- в обеих фазах пинаем касание/prompt/click
		touchGlorp(root, now)
		return
	end

	-- 3) тикеты
	local ticketPos = getNearestTicket(root.Position)
	if not ticketPos then
		goSafe()
		return
	end

	local ticketDestPos = ticketPos - Vector3.new(0, 4.5, 0)
	if threatAt(ticketDestPos, 1) then
		goSafe()
		return
	end

	local dest = CFrame.new(ticketDestPos)
	standPlatform.CFrame = dest - Vector3.new(0, offset + 0.5, 0)
	safePlatform.CFrame = HIDDEN

	local far = (root.Position - dest.Position).Magnitude > 6

	if far and now - lastTeleport > CFG.teleportCooldown then
		teleport(root, dest, true)
		atTicket = true
	elseif atTicket then
		clearAreaThrottled(dest.Position, now)
	end
end

local errorLimit = 0
table.insert(connections, RunService.Heartbeat:Connect(function(dt)
	local ok = pcall(onHeartbeat, dt)
	if not ok then
		errorLimit += 1
		if errorLimit > 200 then
			_G.FarmEvent = false
		end
	end
end))

table.insert(connections, LP.CharacterAdded:Connect(function()
	task.wait(0.5)
	hidePlatforms()
	restoreArea()
	wasFarming = false
	atTicket = false
	dangerUntil = 0
end))

_G.FarmUnload = function()
	for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
	table.clear(connections)
	table.clear(realCharacters)
	table.clear(tracked)
	table.clear(npcList)
	restoreArea()
	for _, p in ipairs(ownParts) do pcall(function() p:Destroy() end) end
	table.clear(ownParts)
	_G.FarmUnload = nil
end
