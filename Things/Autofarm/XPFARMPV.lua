-- // XP Farm by Grok (Plushie Hell / DesertBus)
_G.XPFARMPV = _G.XPFARMPV or true
_G.XPFarmRunning = true  -- защита от наложения

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
        local popups = LocalPlayer.PlayerGui:WaitForChild("Shared", 8):WaitForChild("Popups", 8)
        local loading = popups:WaitForChild("LoadingMap", 15)
        
        while _G.XPFARMPV and loading.Visible do
            task.wait(0.4)
        end
    end)
end

local function mainLoop()
    while _G.XPFARMPV and _G.XPFarmRunning do
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

        -- Ждём конца раунда (3 минуты)
        while _G.XPFARMPV and _G.XPFarmRunning do
            local timerText = getRoundTimer()
            if timerText and (timerText == "0:00" or timerText == "0:0" or timerText == "00:00") then
                break
            end
            task.wait(2)
        end

        task.wait(2.5) -- пауза перед новым циклом
    end
end

-- Защита от двойного инжекта
if _G.XPFarmConnection then
    _G.XPFarmRunning = false
    task.wait(1)
end

_G.XPFarmRunning = true
_G.XPFarmConnection = task.spawn(mainLoop)

print("✅ XP Farm загружен! Управление: _G.XPFARMPV = true / false")
