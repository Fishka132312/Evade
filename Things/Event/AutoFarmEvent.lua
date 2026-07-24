if _G.FarmScriptLoaded then
    print("already running")
    return
end

_G.FarmScriptLoaded = true
_G.FarmEvent = false

_G.PauseFarm = function(seconds)
    _G.FarmPauseUntil = tick() + (seconds or 5)
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local wasFarming = false
local lastTeleportTime = 0
local TELEPORT_COOLDOWN = 0.4

local _G_FarmPauseUntil = 0

local function getRootPart()
    local char = LocalPlayer.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function isCharacterAlive()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    return hum and hum.Health > 0
end

local function getRandomSpawn()
    local spawns = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Parts") and workspace.Map.Parts:FindFirstChild("Spawns")
    if spawns then
        local children = spawns:GetChildren()
        if #children > 0 then
            return children[math.random(1, #children)]
        end
    end
    return nil
end

local function isEnemyNear(myPos)
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return false end
    for _, model in ipairs(playersFolder:GetChildren()) do
        if model.Name ~= LocalPlayer.Name and model:FindFirstChild("HumanoidRootPart") then
            local dist = (model.HumanoidRootPart.Position - myPos).Magnitude
            if dist <= 22 then
                return true
            end
        end
    end
    return false
end

local safePlatform = Instance.new("Part")
safePlatform.Size = Vector3.new(20, 1, 20)
safePlatform.Anchored = true
safePlatform.Transparency = 0.7
safePlatform.CanCollide = true
safePlatform.Parent = workspace

local ticketPlatform = Instance.new("Part")
ticketPlatform.Size = Vector3.new(10, 1, 10)
ticketPlatform.Anchored = true
ticketPlatform.Transparency = 0.7
ticketPlatform.CanCollide = false
ticketPlatform.Parent = workspace

local standPlatform = Instance.new("Part")
standPlatform.Size = Vector3.new(8, 1, 8)
standPlatform.Anchored = true
standPlatform.Transparency = 0.6
standPlatform.CanCollide = true
standPlatform.Parent = workspace

local function disableNearbyCollisions(centerPos)
    local range = 15
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj.Anchored and (obj.Position - centerPos).Magnitude <= range then
            obj.CanCollide = false
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
end)

RunService.Heartbeat:Connect(function()
    if not isCharacterAlive() then return end
   
    local root = getRootPart()
    if not root then return end

    if _G.FarmPauseUntil and tick() < _G.FarmPauseUntil then
        return
    end

    if wasFarming and not _G.FarmEvent then
        wasFarming = false
        safePlatform.CFrame = CFrame.new(0, -10000, 0)
        ticketPlatform.CFrame = CFrame.new(0, -10000, 0)
        standPlatform.CFrame = CFrame.new(0, -10000, 0)
       
        local spawnPoint = getRandomSpawn()
        if spawnPoint then
            root.CFrame = CFrame.new(spawnPoint:GetPivot().Position + Vector3.new(0, 5, 0))
        end
        return
    end

    wasFarming = _G.FarmEvent
    if not _G.FarmEvent then return end

    local now = tick()
    local enemyNear = isEnemyNear(root.Position)
   
    local safeZoneMap = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("SafeZones")
    local safePos = safeZoneMap and safeZoneMap:GetPivot().Position or Vector3.new(0, 1000, 0)
    local highCFrame = CFrame.new(safePos + Vector3.new(0, 1000, 0))

    if enemyNear then
        safePlatform.CFrame = highCFrame - Vector3.new(0, 3.5, 0)
        ticketPlatform.CFrame = CFrame.new(0, -10000, 0)
        standPlatform.CFrame = CFrame.new(0, -10000, 0)
       
        if (root.Position - highCFrame.Position).Magnitude > 15 and now - lastTeleportTime > TELEPORT_COOLDOWN then
            root.CFrame = highCFrame
            lastTeleportTime = now
        end
    else
        local ticketsFolder = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("Tickets")
        local targetTicket = ticketsFolder and ticketsFolder:GetChildren()[1]
       
        if targetTicket then
            local ticketPos = targetTicket:GetPivot().Position
            local farmCFrame = CFrame.new(ticketPos - Vector3.new(0, 4.5, 0))
           
            ticketPlatform.CFrame = farmCFrame - Vector3.new(0, 3.5, 0)
            standPlatform.CFrame = farmCFrame - Vector3.new(0, 5, 0)  -- платформа под игроком
            
            disableNearbyCollisions(ticketPos)
           
            if (root.Position - farmCFrame.Position).Magnitude > 6 and now - lastTeleportTime > TELEPORT_COOLDOWN then
                root.CFrame = farmCFrame
                lastTeleportTime = now
            end
        else
            safePlatform.CFrame = highCFrame - Vector3.new(0, 3.5, 0)
            ticketPlatform.CFrame = CFrame.new(0, -10000, 0)
            standPlatform.CFrame = CFrame.new(0, -10000, 0)
           
            if (root.Position - highCFrame.Position).Magnitude > 15 and now - lastTeleportTime > TELEPORT_COOLDOWN then
                root.CFrame = highCFrame
                lastTeleportTime = now
            end
        end
    end
end)
