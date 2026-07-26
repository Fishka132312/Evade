if _G.FarmUnload then pcall(_G.FarmUnload) end

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP         = Players.LocalPlayer

if _G.FarmEvent == nil then _G.FarmEvent = false end
_G.FarmPauseUntil = 0

_G.PauseFarm  = function(sec) _G.FarmPauseUntil = os.clock() + (sec or 5) end
_G.ResumeFarm = function() _G.FarmPauseUntil = 0 end

local CFG = {
	enemyRadius      = 22,
	teleportCooldown = 0.4,
	scanInterval     = 0.25,
	collisionRange   = 15,
	safeHeight       = 1000,
}

local connections, parts = {}, {}
local wasFarming, lastTeleport, lastScan = false, 0, 0
local enemyNearCached = false
local collisionMemory = {}

local HIDDEN = CFrame.new(0, -10000, 0)

local function makePlatform(size, collide, transparency)
	local p = Instance.new("Part")
	p.Size        = size
	p.Anchored    = true
	p.CanCollide  = collide
	p.Transparency= transparency
	p.CastShadow  = false
	p.CanQuery    = false
	p.Locked      = true
	p.CFrame      = HIDDEN
	p.Parent      = workspace
	table.insert(parts, p)
	return p
end

local safePlatform  = makePlatform(Vector3.new(20, 1, 20), true, 0.7)
local standPlatform = makePlatform(Vector3.new(8, 1, 8),  true, 0.6)

local function hidePlatforms()
	safePlatform.CFrame  = HIDDEN
	standPlatform.CFrame = HIDDEN
end

local function restoreCollisions()
	for part, original in pairs(collisionMemory) do
		if part.Parent then
			pcall(function() part.CanCollide = original end)
		end
	end
	table.clear(collisionMemory)
end

local function disableNearbyCollisions(centerPos)
	local ok, found = pcall(function()
		return workspace:GetPartBoundsInRadius(centerPos, CFG.collisionRange)
	end)
	if not ok or not found then return end

	for _, obj in ipairs(found) do
		if obj:IsA("BasePart") and not obj.Anchored and obj.CanCollide
			and not obj:IsDescendantOf(LP.Character or workspace)
			and collisionMemory[obj] == nil then
			collisionMemory[obj] = obj.CanCollide
			obj.CanCollide = false
		end
	end
end

local function getRoot()
	local char = LP.Character
	return char and char:FindFirstChild("HumanoidRootPart") or nil
end

local function isAlive()
	local char = LP.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	return hum ~= nil and hum.Health > 0
end

local function teleport(root, cframe)
	root.CFrame = cframe
	pcall(function()
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end)
	lastTeleport = os.clock()
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

local function safeCFrame()
	local map = workspace:FindFirstChild("Map")
	local zones = map and map:FindFirstChild("SafeZones")
	local base = Vector3.new(0, 0, 0)
	if zones and zones:IsA("PVInstance") then
		local ok, pivot = pcall(function() return zones:GetPivot().Position end)
		if ok then base = pivot end
	end
	return CFrame.new(base + Vector3.new(0, CFG.safeHeight, 0))
end

local function stopFarming(root)
	wasFarming = false
	hidePlatforms()
	restoreCollisions()
	if root then
		local spawnPoint = getRandomSpawn()
		if spawnPoint then
			local ok, pos = pcall(function() return spawnPoint:GetPivot().Position end)
			if ok then teleport(root, CFrame.new(pos + Vector3.new(0, 5, 0))) end
		end
	end
end

local function onHeartbeat()
	local farming = _G.FarmEvent == true
	local paused  = os.clock() < (_G.FarmPauseUntil or 0)
	local root    = getRoot()

	if (not farming) or paused or (not isAlive()) then
		if wasFarming then
			stopFarming((not paused) and isAlive() and root or nil)
		end
		return
	end

	if not root then return end
	wasFarming = true

	local now = os.clock()
	local high = safeCFrame()

	if now - lastScan >= CFG.scanInterval then
		lastScan = now
		enemyNearCached = isEnemyNear(root.Position)
	end

	local function goSafe()
		safePlatform.CFrame  = high - Vector3.new(0, 3.5, 0)
		standPlatform.CFrame = HIDDEN
		if (root.Position - high.Position).Magnitude > 15
			and now - lastTeleport > CFG.teleportCooldown then
			teleport(root, high)
		end
	end

	if enemyNearCached then
		restoreCollisions()
		goSafe()
		return
	end

	local ticketPos = getNearestTicket(root.Position)
	if not ticketPos then
		goSafe()
		return
	end

	local farmCFrame = CFrame.new(ticketPos - Vector3.new(0, 4.5, 0))
	standPlatform.CFrame = farmCFrame - Vector3.new(0, 5, 0)
	safePlatform.CFrame  = HIDDEN

	if now - lastScan < 0.01 then
		disableNearbyCollisions(ticketPos)
	end

	if (root.Position - farmCFrame.Position).Magnitude > 6
		and now - lastTeleport > CFG.teleportCooldown then
		teleport(root, farmCFrame)
	end
end

local errorCount = 0
table.insert(connections, RunService.Heartbeat:Connect(function()
	local ok, err = pcall(onHeartbeat)
	if not ok then
		errorCount += 1
		if errorCount <= 5 then warn("[Farm] ошибка:", err) end
	end
end))

table.insert(connections, LP.CharacterAdded:Connect(function()
	task.wait(0.5)
	hidePlatforms()
	restoreCollisions()
	wasFarming = false
end))

_G.FarmUnload = function()
	for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
	table.clear(connections)
	restoreCollisions()
	for _, p in ipairs(parts) do pcall(function() p:Destroy() end) end
	table.clear(parts)
	_G.FarmUnload = nil
end
