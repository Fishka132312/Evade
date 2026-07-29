if _G.AvoidNPCScriptLoaded then
    return
end

_G.AvoidNPCScriptLoaded = true
_G.AvoidNPC = _G.AvoidNPC or false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local lastTeleportTime = 0
local TELEPORT_COOLDOWN = 0.5
local SAFE_DISTANCE = 50

local previousPosition = nil
local returnTime = 0
local isInSafe = false

local safeStandPlatform = Instance.new("Part")
safeStandPlatform.Size = Vector3.new(12, 1, 12)
safeStandPlatform.Anchored = true
safeStandPlatform.Transparency = 0.6
safeStandPlatform.CanCollide = true
safeStandPlatform.Parent = workspace

local function getRootPart()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function isCharacterAlive()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    return hum and hum.Health > 0
end

local function getAllNPCs()
    local npcs = {}
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return npcs end
    
    for _, model in ipairs(playersFolder:GetChildren()) do
        if model ~= LocalPlayer.Character and model:FindFirstChild("HumanoidRootPart") then
            if model:GetAttribute("AI") == true then
                table.insert(npcs, model.HumanoidRootPart.Position)
            end
        end
    end
    return npcs
end

local function isPositionSafe(position, safeDistance)
    local npcs = getAllNPCs()
    for _, npcPos in ipairs(npcs) do
        local dist = (npcPos - position).Magnitude
        if dist <= safeDistance then
            return false
        end
    end
    return true
end

local function findSafeCFrame()
    local safeZoneMap = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("SafeZones")
    local basePos = safeZoneMap and safeZoneMap:GetPivot().Position or Vector3.new(0, 500, 0)
    
    local offsets = {
        Vector3.new(0, 1000, 0),
        Vector3.new(100, 1000, 0),
        Vector3.new(-100, 1000, 0),
        Vector3.new(0, 1000, 100),
        Vector3.new(0, 1000, -100),
        Vector3.new(50, 1200, 50),
        Vector3.new(-50, 1200, -50),
        Vector3.new(0, 1500, 0),
    }
    
    for _, offset in ipairs(offsets) do
        local testPos = basePos + offset
        if isPositionSafe(testPos, SAFE_DISTANCE) then
            return CFrame.new(testPos)
        end
    end
    
    return CFrame.new(basePos + Vector3.new(0, 2000, 0))
end

local function isNPCNearby(root)
    if not root then return false end
   
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return false end
    
    for _, model in ipairs(playersFolder:GetChildren()) do
        if model ~= LocalPlayer.Character and model:FindFirstChild("HumanoidRootPart") then
            if model:GetAttribute("AI") == true then
                local dist = (model.HumanoidRootPart.Position - root.Position).Magnitude
                if dist <= 5 then
                    return true
                end
            end
        end
    end
    return false
end

RunService.Heartbeat:Connect(function()
    if not _G.AvoidNPC then return end
    if not isCharacterAlive() then return end

    local root = getRootPart()
    if not root then return end

    local npcNearby = isNPCNearby(root)
    local now = tick()

    if npcNearby and not isInSafe then
        previousPosition = root.Position
        
        if now - lastTeleportTime > TELEPORT_COOLDOWN then
            local safeCFrame = findSafeCFrame()
            
            safeStandPlatform.CFrame = safeCFrame - Vector3.new(0, 4, 0)
            
            root.CFrame = safeCFrame
            lastTeleportTime = now
            isInSafe = true
            returnTime = now + 5
            
            if _G.PauseFarm then
                _G.PauseFarm(5)
            end
        end

    elseif isInSafe then
        if isNPCNearby(root) then
            local newSafeCFrame = findSafeCFrame()
            root.CFrame = newSafeCFrame
            safeStandPlatform.CFrame = newSafeCFrame - Vector3.new(0, 4, 0)
            returnTime = now + 5
        end
        
        if now >= returnTime then
            if previousPosition and isPositionSafe(previousPosition, SAFE_DISTANCE) then
                root.CFrame = CFrame.new(previousPosition + Vector3.new(0, 5, 0))
                safeStandPlatform.CFrame = CFrame.new(0, -10000, 0)
                isInSafe = false
                previousPosition = nil
            else
                returnTime = now + 3
            end
        end
    end
end)
