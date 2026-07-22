if _G.FarmScriptLoaded then
    print("Скрипт уже запущен!")
    return
end

_G.FarmScriptLoaded = true
_G.FarmEvent = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

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

local lastTeleport = 0
local TELEPORT_COOLDOWN = 0.8  -- секунды между телепортами

task.spawn(function()
    while task.wait(0.3) do  -- увеличил интервал, меньше спама
        if not _G.FarmEvent then
            -- Выключили фарм — возвращаемся на спавн
            local root = getRootPart()
            local spawnPoint = getRandomSpawn()
            if root and spawnPoint and tick() - lastTeleport > TELEPORT_COOLDOWN then
                root.CFrame = CFrame.new(spawnPoint:GetPivot().Position + Vector3.new(0, 5, 0))
                lastTeleport = tick()
            end
            continue
        end

        local root = getRootPart()
        if not root then continue end

        local currentTime = tick()
        if currentTime - lastTeleport < TELEPORT_COOLDOWN then
            continue
        end

        -- Ищем тикет
        local ticketsFolder = workspace:FindFirstChild("Effects") 
            and workspace.Effects:FindFirstChild("Tickets")
        
        local targetTicket = ticketsFolder and ticketsFolder:GetChildren()[1]

        if targetTicket then
            -- === ТЕЛЕПОРТ К ТИКЕТУ ===
            local ticketPos = targetTicket:GetPivot().Position
            local farmCFrame = CFrame.new(ticketPos + Vector3.new(0, 3, 0))  -- чуть выше
            
            root.CFrame = farmCFrame
            lastTeleport = currentTime
            print("Телепорт к тикету")
            
        else
            -- === ТЕЛЕПОРТ В БЕЗОПАСНУЮ ЗОНУ ===
            local safeZoneMap = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("SafeZones")
            local safePos = safeZoneMap and safeZoneMap:GetPivot().Position or Vector3.new(0, 500, 0)
            
            local highCFrame = CFrame.new(safePos + Vector3.new(0, 50, 0))
            
            if (root.Position - highCFrame.Position).Magnitude > 20 then
                root.CFrame = highCFrame
                lastTeleport = currentTime
                print("Телепорт в безопасную зону")
            end
        end
    end
end)

print("✅ Фарм-скрипт загружен (упрощённая версия)")
