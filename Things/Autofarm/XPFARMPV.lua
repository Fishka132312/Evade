-- // XP Farm by Grok (Plushie Hell / DesertBus)
_G.XPFARMPV = _G.XPFARMPV or false   -- Изначально ВЫКЛЮЧЕНО
_G.XPFarmRunning = false

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local AdminCommand = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Admin"):WaitForChild("Command")
local SetPlayerModeEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SetPlayerMode")

local function fireCommand(cmd)
    pcall(function()
        AdminCommand:FireServer(cmd)
    end)
end

local function isInLobby()
    return LocalPlayer.PlayerGui:FindFirstChild("Game") ~= nil
end

local function getRoundTimer()
    local success, text = pcall(function()
        local gui = LocalPlayer.PlayerGui:FindFirstChild("Game")
        if not gui then return nil end
        return gui.HUD.Overlay.RoundOverlay.RoundTimer.IngameRoundTimer.Timer.Text
    end)
    return success and text or nil
end

local function waitForMapLoad()
    pcall(function()
        local popups = LocalPlayer.PlayerGui:WaitForChild("Shared", 10):WaitForChild("Popups", 10)
        local loading = popups:WaitForChild("LoadingMap", 20)
        
        while _G.XPFARMPV and loading.Visible do
            task.wait(0.5)
        end
    end)
end

local function mainLoop()
    while _G.XPFarmRunning do
        -- Ждём пока включат фарм
        if not _G.XPFARMPV then
            task.wait(1)
            continue
        end

        -- Если не в лобби — заходим
        if not isInLobby() then
            pcall(function()
                SetPlayerModeEvent:FireServer(true)
            end)
            task.wait(1.5)
        end

        -- Меняем карту
        fireCommand("!map DesertBus")
        task.wait(1.2)

        -- Ждём загрузки карты
        waitForMapLoad()
        task.wait(0.6)

        -- Специал раунд
        fireCommand("!specialround Plushie Hell")
        task.wait(0.6)

        -- Обнуляем таймер
        fireCommand("!timer 0")
        task.wait(1)

        -- === Новый способ окончания раунда ===
        while _G.XPFARMPV and _G.XPFarmRunning do
            local timerText = getRoundTimer()
            
            if timerText then
                -- Если осталось мало времени (0:01, 0:00, 0:0 и т.д.)
                if timerText == "0:01" or 
                   timerText == "0:00" or 
                   timerText == "0:0" or 
                   timerText == "00:00" then
                    
                    task.wait(2)   -- ждём 2 секунды как ты просил
                    break
                end
            end
            
            task.wait(2)
        end

        task.wait(1) -- небольшая пауза перед следующим циклом
    end
end

-- Защита от двойного инжекта
if _G.XPFarmConnection then
    _G.XPFarmRunning = false
    task.wait(0.8)
end

_G.XPFarmRunning = true
_G.XPFarmConnection = task.spawn(mainLoop)

print("✅ XP Farm загружен! (изначально выключен)")
print("Включи командой:  _G.XPFARMPV = true")
