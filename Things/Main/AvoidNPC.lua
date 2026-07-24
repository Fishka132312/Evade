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

local function getSafeCFrame()
    local safeZoneMap = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("SafeZones")
    local safePos = safeZoneMap and safeZoneMap:GetPivot().Position or Vector3.new(0, 1000, 0)
    return CFrame.new(safePos + Vector3.new(0, 1000, 0))
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
            local safeCFrame = getSafeCFrame()
            
            safeStandPlatform.CFrame = safeCFrame - Vector3.new(0, 4, 0)
            
            root.CFrame = safeCFrame
            lastTeleportTime = now
            isInSafe = true
            returnTime = now + 5
            
            if _G.PauseFarm then
                _G.PauseFarm(5)
            end
            
        end

    elseif isInSafe and now >= returnTime then
        if previousPosition then
            root.CFrame = CFrame.new(previousPosition + Vector3.new(0, 5, 0))
        end
        
        safeStandPlatform.CFrame = CFrame.new(0, -10000, 0)
        isInSafe = false
        previousPosition = nil
    end
end)
