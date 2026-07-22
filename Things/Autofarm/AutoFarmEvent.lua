if _G.FarmScriptLoaded then 
    print("Скрипт уже запущен!") 
    return 
end
_G.FarmScriptLoaded = true

_G.FarmEvent = false
local wasFarming = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Создаем платформы
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

-- Безопасное укрытие платформ (не отправляем в Void, чтобы движок их не удалял)
local function hidePlatforms()
    safePlatform.CanCollide = false
    safePlatform.CFrame = CFrame.new(0, 20000, 0)
    ticketPlatform.CanCollide = false
    ticketPlatform.CFrame = CFrame.new(0, 20000, 0)
end

hidePlatforms()

local function getCharacterAndRoot()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") then
        if char.Humanoid.Health > 0 then
            return char, char.HumanoidRootPart
        end
    end
    return nil, nil
end

-- Безопасная телепортация со сбросом инерции
local function safeTeleport(char, root, targetCFrame)
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    char:PivotTo(targetCFrame)
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
    local playersFolder = workspace:FindFirstChild("Players") or workspace
    
    for _, model in ipairs(playersFolder:GetChildren()) do
        if model.Name ~= LocalPlayer.Name and model:IsA("Model") then
            local otherRoot = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
            local hum = model:FindFirstChildOfClass("Humanoid")
            if otherRoot and hum and hum.Health > 0 then
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
        local char, root = getCharacterAndRoot()
        if not char or not root then continue end

        -- Если фарм выключился — возвращаем на спавн
        if wasFarming and not _G.FarmEvent then
            wasFarming = false
            hidePlatforms()
            
            local spawnPoint = getRandomSpawn()
            if spawnPoint then
                safeTeleport(char, root, CFrame.new(spawnPoint:GetPivot().Position + Vector3.new(0, 5, 0)))
            end
            continue
        end
        
        wasFarming = _G.FarmEvent

        if _G.FarmEvent then
            local enemyNear = isEnemyNear(root.Position)

            local safeZoneMap = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("SafeZones")
            local safePos = safeZoneMap and safeZoneMap:GetPivot().Position or Vector3.new(0, 300, 0)
            local highCFrame = CFrame.new(safePos + Vector3.new(0, 200, 0))

            -- Если рядом враг — уходим на безопасную высоту
            if enemyNear then
                safePlatform.CanCollide = true
                safePlatform.CFrame = highCFrame - Vector3.new(0, 3, 0)
                
                if (root.Position - highCFrame.Position).Magnitude > 5 then
                    safeTeleport(char, root, highCFrame)
                end
                continue
            end

            -- Ищем билет
            local ticketsFolder = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("Tickets")
            local targetTicket = ticketsFolder and ticketsFolder:GetChildren()[1]

            if targetTicket then
                local ticketPos = targetTicket:GetPivot().Position
                -- Телепортируем НАД билетом, а не ПОД него
                local farmCFrame = CFrame.new(ticketPos + Vector3.new(0, 1.5, 0))
                
                ticketPlatform.CanCollide = true
                ticketPlatform.CFrame = farmCFrame - Vector3.new(0, 3, 0)
                
                if (root.Position - farmCFrame.Position).Magnitude > 4 then
                    safeTeleport(char, root, farmCFrame)
                end
            else
                -- Если билетов нет — ждем в безопасной зоне
                safePlatform.CanCollide = true
                safePlatform.CFrame = highCFrame - Vector3.new(0, 3, 0)
                
                ticketPlatform.CanCollide = false
                ticketPlatform.CFrame = CFrame.new(0, 20000, 0)
                
                if (root.Position - highCFrame.Position).Magnitude > 5 then
                    safeTeleport(char, root, highCFrame)
                end
            end
        end
    end
end)
