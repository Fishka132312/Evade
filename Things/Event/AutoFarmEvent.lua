if _G.FarmUnload then pcall(_G.FarmUnload) end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

if _G.FarmEvent == nil then _G.FarmEvent = false end
_G.FarmPauseUntil = 0
_G.PauseFarm = function(sec) _G.FarmPauseUntil = os.clock() + (sec or 5) end
_G.ResumeFarm = function() _G.FarmPauseUntil = 0 end

local CFG = {
	enemyRadius = 22,
	npcSafeDistance = 50,
	teleportCooldown = 0.4,
	scanInterval = 0.25,
	clearRadius = 18,
	safeHeight = 1000,
}

local HIDDEN = CFrame.new(0, -10000, 0)
local connections, ownParts = {}, {}
local collisionMemory = {}
local wasFarming, lastTeleport, lastScan, enemyNear = false, 0, 0, false
local atTicket = false

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

local function teleport(root, cframe, clear)
	if clear then
		clearArea(cframe.Position)
	else
		restoreArea()
	end

	root.CFrame = cframe
	pcall(function()
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end)
	lastTeleport = os.clock()
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

local function getAllNPCs()
	local npcs = {}
	local folder = workspace:FindFirstChild("Players")
	if not folder then return npcs end
	
	for _, model in ipairs(folder:GetChildren()) do
		if model ~= LP.Character and model:FindFirstChild("HumanoidRootPart") then
			if model:GetAttribute("AI") == true or model.Name ~= LP.Name then
				local hum = model:FindFirstChildOfClass("Humanoid")
				if not hum or hum.Health > 0 then
					table.insert(npcs, model.HumanoidRootPart.Position)
				end
			end
		end
	end
	return npcs
end

local function isPositionSafeFromNPC(position, safeDistance)
	local npcs = getAllNPCs()
	for _, npcPos in ipairs(npcs) do
		local dist = (npcPos - position).Magnitude
		if dist <= safeDistance then
			return false
		end
	end
	return true
end

local function isEnemyNear(myPos)
	local folder = workspace:FindFirstChild("Players")
	if not folder then return false end

	for _, model in ipairs(folder:GetChildren()) do
		if model ~= LP.Character and model.Name ~= LP.Name then
			local r = model:FindFirstChild("HumanoidRootPart")
			local hum = model:FindFirstChildOfClass("Humanoid")
			if r and (not hum or hum.Health > 0)
				and (r.Position - myPos).Magnitude <= CFG.enemyRadius then
				return true
			end
		end
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
		if isPositionSafeFromNPC(testPos, CFG.npcSafeDistance) then
			return CFrame.new(testPos)
		end
	end
	
	return CFrame.new(base + Vector3.new(0, CFG.safeHeight + 1000, 0))
end

local function safeCFrame()
	return findSafeCFrame()
end

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

local function onHeartbeat()
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
	local doScan = now - lastScan >= CFG.scanInterval

	if doScan then
		lastScan = now
		enemyNear = isEnemyNear(root.Position)
	end

	local function goSafe()
		local high = safeCFrame()
		safePlatform.CFrame = high - Vector3.new(0, offset + 0.5, 0)
		standPlatform.CFrame = HIDDEN

		if atTicket then
			restoreArea()
			atTicket = false
		end

		if (root.Position - high.Position).Magnitude > 15
			and now - lastTeleport > CFG.teleportCooldown then
			teleport(root, high, false)
		end
	end

	if enemyNear then
		goSafe()
		return
	end

	local ticketPos = getNearestTicket(root.Position)
	if not ticketPos then
		goSafe()
		return
	end

	local ticketDestPos = ticketPos - Vector3.new(0, 4.5, 0)
	if not isPositionSafeFromNPC(ticketDestPos, CFG.npcSafeDistance) then
		goSafe()
		return
	end

	local dest = CFrame.new(ticketDestPos)
	standPlatform.CFrame = dest - Vector3.new(0, offset + 0.5, 0)
	safePlatform.CFrame = HIDDEN

	local far = (root.Position - dest.Position).Magnitude > 6

	if far and now - lastTeleport > CFG.teleportCooldown then
		if isPositionSafeFromNPC(dest.Position, CFG.npcSafeDistance) then
			teleport(root, dest, true)
			atTicket = true
		else
			goSafe()
		end
	elseif atTicket and doScan then
		if not isPositionSafeFromNPC(root.Position, CFG.npcSafeDistance) then
			goSafe()
		else
			clearArea(dest.Position)
		end
	end
end

local errorLimit = 0
table.insert(connections, RunService.Heartbeat:Connect(function()
	local ok = pcall(onHeartbeat)
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
end))

_G.FarmUnload = function()
	for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
	table.clear(connections)
	restoreArea()
	for _, p in ipairs(ownParts) do pcall(function() p:Destroy() end) end
	table.clear(ownParts)
	_G.FarmUnload = nil
end
