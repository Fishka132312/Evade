-- ==================== AVOID NPC SCRIPT ====================
if _G.AvoidNPCScriptLoaded then
    print("✅ Avoid NPC скрипт уже запущен!")
    return
end

_G.AvoidNPCScriptLoaded = true
_G.AvoidNPC = _G.AvoidNPC or false  -- по умолчанию выключен

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local lastTeleportTime = 0
local TELEPORT_COOLDOWN = 0.5

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
            -- Проверяем, что это NPC с включенным AI
            if model:GetAttribute("AI") == true then
                local dist = (model.HumanoidRootPart.Position - root.Position).Magnitude
                if dist <= 5 then
                    return true, model
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
    
    if npcNearby then
        local now = tick()
        
        -- Вызываем паузу фарма
        if _G.PauseFarm then
            _G.PauseFarm(5)
        end
        
        -- Телепорт в безопасную зону
        if now - lastTeleportTime > TELEPORT_COOLDOWN then
            local safeCFrame = getSafeCFrame()
            root.CFrame = safeCFrame
            lastTeleportTime = now
            print("⚠️ NPC с AI рядом! Телепорт в safe zone + пауза фарма")
        end
    end
end)

print("✅ Avoid NPC скрипт загружен! Управляй через _G.AvoidNPC = true / false")
