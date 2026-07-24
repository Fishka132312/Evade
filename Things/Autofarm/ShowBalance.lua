-- === Cash Tracker Overlay (LocalScript) ===

-- Защита от повторного наложения при повторном запуске скрипта
local GEN = (_G.__CashTrackerGen or 0) + 1
_G.__CashTrackerGen = GEN

if _G.__CashTrackerGui then
    pcall(function() _G.__CashTrackerGui:Destroy() end)
end
if _G.__CashTrackerConn then
    pcall(function() _G.__CashTrackerConn:Disconnect() end)
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if _G.ShowBalance == nil then
    _G.ShowBalance = true
end

-- Парсинг текста в число (убирает запятые, буквы, оставляет цифры и точку)
local function parseCash(text)
    if not text then return nil end
    local clean = text:gsub("[^%d%.]", "")
    local num = tonumber(clean)
    return num
end

-- === GUI ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CashTrackerGui_" .. GEN
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.Parent = PlayerGui
_G.__CashTrackerGui = screenGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 130)
frame.Position = UDim2.new(0, 20, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(80, 200, 120)
stroke.Thickness = 1
stroke.Transparency = 0.3
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 26)
title.BackgroundTransparency = 1
title.Text = "💰 Cash Tracker"
title.TextColor3 = Color3.fromRGB(120, 255, 160)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.Parent = frame

local function makeLabel(yPos)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 0, 20)
    lbl.Position = UDim2.new(0, 8, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    return lbl
end

local currentLabel  = makeLabel(30)
local farmedLabel   = makeLabel(52)
local perMinLabel   = makeLabel(74)
local perHourLabel  = makeLabel(96)

-- === Состояние ===
local currentValue = nil
local farmedTotal = 0
local startTime = os.clock()

local function formatNum(n)
    n = math.floor(n or 0)
    local formatted = tostring(n)
    local k
    while true do
        formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return formatted
end

local function updateGui()
    currentLabel.Text = "Сейчас: " .. formatNum(currentValue or 0)
    farmedLabel.Text  = "Нафармлено: " .. formatNum(farmedTotal)

    local elapsedMin = (os.clock() - startTime) / 60
    local perMin, perHour = 0, 0
    if elapsedMin > 0.0167 then -- защита от деления на почти ноль (первая секунда)
        perMin = farmedTotal / elapsedMin
        perHour = perMin * 60
    end

    perMinLabel.Text  = "В минуту: ~" .. formatNum(perMin)
    perHourLabel.Text = "В час: ~" .. formatNum(perHour)
end

local function onCashText(text)
    local newVal = parseCash(text)
    if not newVal then return end

    if currentValue == nil then
        -- первый раз увидели текст — просто запоминаем базу
        currentValue = newVal
        startTime = os.clock()
        farmedTotal = 0
    else
        if newVal > currentValue then
            farmedTotal += (newVal - currentValue)
        end
        currentValue = newVal
    end

    updateGui()
end

-- === Поиск и подключение к лейблу кэша (с ожиданием, если GUI ещё не создан) ===
local function tryGetCashLabel()
    local ok, obj = pcall(function()
        return LocalPlayer.PlayerGui.Game.HUD.Overlay.CharacterStatus.BottomLeft.Tickets.Cash
    end)
    if ok and obj and obj:IsA("TextLabel") then
        return obj
    end
    return nil
end

task.spawn(function()
    local connectedLabel = nil

    while _G.__CashTrackerGen == GEN do
        local label = tryGetCashLabel()

        if label then
            if label ~= connectedLabel then
                connectedLabel = label

                if _G.__CashTrackerConn then
                    pcall(function() _G.__CashTrackerConn:Disconnect() end)
                end

                onCashText(label.Text)

                _G.__CashTrackerConn = label:GetPropertyChangedSignal("Text"):Connect(function()
                    onCashText(label.Text)
                end)

                -- если объект удалится из иерархии — переподключимся заново
                label.AncestryChanged:Connect(function(_, parent)
                    if not parent and connectedLabel == label then
                        connectedLabel = nil
                    end
                end)
            end
        else
            connectedLabel = nil
        end

        task.wait(1)
    end
end)

-- === Видимость через _G.ShowBalance ===
task.spawn(function()
    while _G.__CashTrackerGen == GEN do
        frame.Visible = (_G.ShowBalance ~= false)
        task.wait(0.2)
    end
end)

updateGui()
