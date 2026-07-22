if _G.FarmScriptLoaded then ---------11
    print("Скрипт уже запущен!")
    return
end

_G.FarmScriptLoaded = true
_G.FarmEvent = false

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local TELEPORT_COOLDOWN = 0.6  -- Основной кулдаун (можно менять)
local lastTeleportTime = 0

local safePlatform = Instance.new("Part")
safePlatform.Size = Vector3.new(20, 1, 20)
safePlatform.Anchored = true
safePlatform.Transparency = 0.5
safePlatform.Parent = workspace

local ticketPlatform = Instance.new("Part")
ticketPlatform.Size = Vector3.new(10, 1, 10)
ticketPlatform.Anchored = true
ticketPlatform.Transparency = 0.5
ticketPlatform.Parent = workspace

local function getRootPart()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
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
        if model.Name ~= LocalPlayer.Name and model:IsA("Model") then
            local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
            if root then
                if (root.Position - myPos).Magnitude <= 25 then
                    return true
                end
            end
        end
    end
    return false
end

local function safeTeleport(root, targetCFrame)
    local now = tick()
    if now - lastTeleportTime < TELEPORT_COOLDOWN then
        return false
    end
    
    -- Плавный твин (меньше шансов на смерть)
    local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    
    lastTeleportTime = now
    return true
end

task.spawn(function()
    while task.wait(0.3) do  -- Увеличил интервал
        local root = getRootPart()
        if not root then continue end

        if wasFarming and not _G.FarmEvent then
            wasFarming = false
            safePlatform.CFrame = CFrame.new(0, -10000, 0)
            ticketPlatform.CFrame = CFrame.new(0, -10000, 0)
            
            local spawnPoint = getRandomSpawn()
            if spawnPoint then
                safeTeleport(root, CFrame.new(spawnPoint:GetPivot().Position + Vector3.new(0, 5, 0)))
            end
            continue
        end

        wasFarming = _G.FarmEvent
        if not _G.FarmEvent then continue end

        local enemyNear = isEnemyNear(root.Position)
        local safeZoneMap = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("SafeZones")
        local safePos = safeZoneMap and safeZoneMap:GetPivot().Position or Vector3.new(0, 1000, 0)

        if enemyNear then
            local highCFrame = CFrame.new(safePos + Vector3.new(0, 1000, 0))
            safePlatform.CFrame = highCFrame - Vector3.new(0, 3.5, 0)
            ticketPlatform.CFrame = CFrame.new(0, -10000, 0)
            
            if (root.Position - highCFrame.Position).Magnitude > 20 then
                safeTeleport(root, highCFrame)
            end
        else
            local ticketsFolder = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("Tickets")
            local targetTicket = ticketsFolder and ticketsFolder:GetChildren()[1]

            if targetTicket then
                local ticketPos = targetTicket:GetPivot().Position
                local farmCFrame = CFrame.new(ticketPos - Vector3.new(0, 4, 0))
                
                ticketPlatform.CFrame = farmCFrame - Vector3.new(0, 3.5, 0)
                safePlatform.CFrame = CFrame.new(0, -10000, 0)
                
                if (root.Position - farmCFrame.Position).Magnitude > 4 then
                    safeTeleport(root, farmCFrame)
                end
            else
                -- Нет тикетов — уходим в безопасную зону
                local highCFrame = CFrame.new(safePos + Vector3.new(0, 1000, 0))
                safePlatform.CFrame = highCFrame - Vector3.new(0, 3.5, 0)
                ticketPlatform.CFrame = CFrame.new(0, -10000, 0)
                
                if (root.Position - highCFrame.Position).Magnitude > 20 then
                    safeTeleport(root, highCFrame)
                end
            end
        end
    end
end)

print("Фарм-скрипт загружен (улучшенная версия)")
