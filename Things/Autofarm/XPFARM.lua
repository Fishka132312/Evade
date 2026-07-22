-- === XP FARM СКРИПТ (Исправленная версия) ===

local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Глобальная переменная для управления
_G.XPFARMPV = _G.XPFARMPV or false

-- Очистка предыдущего процесса
if _G.XPFarmConnection then
    _G.XPFarmConnection = nil
end

local function sendMessage(msg)
    task.wait(0.3) -- небольшая задержка для стабильности
    
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral") or
                        TextChatService.TextChannels:FindFirstChild("All") or
                        TextChatService.TextChannels:FindFirstChildWhichIsA("TextChannel")
        
        if channel then
            channel:SendAsync(msg)
            return
        end
    end
    
    -- Старый чат (на всякий случай)
    local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if chatEvents and chatEvents:FindFirstChild("SayMessageRequest") then
        chatEvents.SayMessageRequest:FireServer(msg, "All")
        return
    end
    
    -- Альтернативный способ (иногда помогает)
    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
end

local function getTimerText()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return "" end
    
    local timerObj = pg:FindFirstChild("Shared", true)
        and pg.Shared:FindFirstChild("HUD", true)
        and pg.Shared.HUD:FindFirstChild("Overlay", true)
        and pg.Shared.HUD.Overlay:FindFirstChild("Default", true)
        and pg.Shared.HUD.Overlay.Default:FindFirstChild("RoundOverlay", true)
        and pg.Shared.HUD.Overlay.Default.RoundOverlay:FindFirstChild("Round", true)
        and pg.Shared.HUD.Overlay.Default.RoundOverlay.Round:FindFirstChild("RoundTimer", true)
        and pg.Shared.HUD.Overlay.Default.RoundOverlay.Round.RoundTimer:FindFirstChild("Timer")
    
    return timerObj and timerObj.Text or ""
end

-- Основная функция фарма
local function startXPFarm()
    print("✅ XP FARM: Запущен")
    local isProcessing = false
    local rewardCount = 0

    while _G.XPFARMPV do
        local pg = player:FindFirstChild("PlayerGui")
        local rewardsGui = pg and pg:FindFirstChild("Global") and pg.Global:FindFirstChild("Rewards")
        
        if rewardsGui and rewardsGui.Visible and not isProcessing then
            isProcessing = true
            rewardCount += 1
            
            rewardsGui.Visible = false
            print("🎁 Награда получена! Счётчик: " .. rewardCount)
            
            if rewardCount >= 2 then
                task.wait(1.5)
                sendMessage("!map Maze")
                rewardCount = 0
            end
            
            -- Ждём таймер 0:29
            while _G.XPFARMPV do
                if getTimerText() == "0:29" then
                    break
                end
                task.wait(0.2)
            end
            
            if _G.XPFARMPV then
                sendMessage("!specialround Plushie Hell")
                task.wait(0.8)
                sendMessage("!Timer 1")
                print("🔄 Раунд настроен (Plushie Hell | 1 минута)")
            end
            
            isProcessing = false
        end
        
        task.wait(0.4)
    end
    
    print("⛔ XP FARM: Остановлен")
end

-- === Тоггл ===
_G.XPFARMPV = not _G.XPFARMPV

if _G.XPFARMPV then
    _G.XPFarmConnection = task.spawn(startXPFarm)
else
    print("⛔ XP FARM: Выключен")
end
