if _G.FarmScriptLoaded then 
    print("Скрипт уже запущен!") 
    return 
end
_G.FarmScriptLoaded = true

_G.FarmEvent = false
local wasFarming = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

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
    if char and char:FindFirstChild("HumanoidRootPart") then
        return char.HumanoidRootPart
    end
    return nil
end

local function getRandomSpawn()
    local spawnsFolder = workspace:FindFirstChild("Map") 
        and workspace.Map:FindFirstChild("Parts") 
        and workspace.Map.Parts:FindFirstChild("Spawns")
    
    if spawnsFolder then
        local spawns = spawnsFolder:GetChildren()
        if #spawns > 0 then
            return spawns[math.random(1, #spawns)]
        end
    end
    return nil
end

local function isEnemyNear(myPos)
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return false end
    
    for _, model in ipairs(playersFolder:GetChildren()) do
        if model.Name ~= LocalPlayer.Name and model:IsA("Model") then
            local otherRoot = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
            if otherRoot then
                local distance = (otherRoot.Position - myPos).Magnitude
                if distance <= 20 then
                    return true
                end
            end
        end
    end
    return false
end

task.spawn(function()
    while task.wait(0.1) do
        if wasFarming and not _G.FarmEvent then
            wasFarming = false
            safePlatform.CFrame = CFrame.new(0, -10000, 0)
            ticketPlatform.CFrame = CFrame.new(0, -10000, 0)
            
            local root = getRootPart()
            local spawnPoint = getRandomSpawn()
            if root and spawnPoint then
                root.CFrame = CFrame.new(spawnPoint:GetPivot().Position + Vector3.new(0, 5, 0))
            end
            continue
        end
        
        wasFarming = _G.FarmEvent

        if _G.FarmEvent then
            local root = getRootPart()
            if not root then continue end

            local enemyNear = isEnemyNear(root.Position)

            local safeZoneMap = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("SafeZones")
            local safePos = safeZoneMap and safeZoneMap:GetPivot().Position or Vector3.new(0, 1000, 0)
            local highCFrame = CFrame.new(safePos + Vector3.new(0, 1000, 0))

            if enemyNear then
                safePlatform.CFrame = highCFrame - Vector3.new(0, 3.5, 0)
                if (root.Position - highCFrame.Position).Magnitude > 15 then
                    root.CFrame = highCFrame
                end
                continue
            end

            local ticketsFolder = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("Tickets")
            local targetTicket = ticketsFolder and ticketsFolder:GetChildren()[1]

            if targetTicket then
                local ticketPos = targetTicket:GetPivot().Position
                local farmCFrame = CFrame.new(ticketPos - Vector3.new(0, 5, 0))
                
                ticketPlatform.CFrame = farmCFrame - Vector3.new(0, 3.5, 0)
                
                if (root.Position - farmCFrame.Position).Magnitude > 3 then
                    root.CFrame = farmCFrame
                end
            else
                safePlatform.CFrame = highCFrame - Vector3.new(0, 3.5, 0)
                ticketPlatform.CFrame = CFrame.new(0, -10000, 0) -- Прячем платформу тикетов
                
                if (root.Position - highCFrame.Position).Magnitude > 15 then
                    root.CFrame = highCFrame
                end
            end
        end
    end
end)
