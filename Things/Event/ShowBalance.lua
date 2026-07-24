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
    _G.ShowBalance = false
end

local function parseCash(text)
    if not text then return nil end
    local clean = text:gsub("[^%d%.]", "")
    local num = tonumber(clean)
    return num
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BubbleTrackerGui_" .. GEN
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.Parent = PlayerGui
_G.__CashTrackerGui = screenGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 230, 0, 148)
frame.Position = UDim2.new(0, 20, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1.5
stroke.Transparency = 0.1
stroke.Parent = frame

local strokeGradient = Instance.new("UIGradient")
strokeGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 170, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160, 120, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 170, 255)),
})
strokeGradient.Rotation = 45
strokeGradient.Parent = stroke

local bgGradient = Instance.new("UIGradient")
bgGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 22, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 14, 20)),
})
bgGradient.Rotation = 90
bgGradient.Parent = frame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundTransparency = 1
titleBar.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -16, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🫧  Bubble Tracker"
title.TextColor3 = Color3.fromRGB(235, 235, 245)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -24, 0, 1)
divider.Position = UDim2.new(0, 12, 0, 32)
divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
divider.BackgroundTransparency = 0.9
divider.BorderSizePixel = 0
divider.Parent = frame

local function makeRow(yPos, icon, labelText, accentColor)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -24, 0, 22)
    row.Position = UDim2.new(0, 12, 0, yPos)
    row.BackgroundTransparency = 1
    row.Parent = frame

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(0.55, 0, 1, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = icon .. "  " .. labelText
    nameLbl.TextColor3 = Color3.fromRGB(170, 170, 185)
    nameLbl.Font = Enum.Font.Gotham
    nameLbl.TextSize = 12.5
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = row

    local valueLbl = Instance.new("TextLabel")
    valueLbl.Size = UDim2.new(0.45, 0, 1, 0)
    valueLbl.Position = UDim2.new(0.55, 0, 0, 0)
    valueLbl.BackgroundTransparency = 1
    valueLbl.Text = "0"
    valueLbl.TextColor3 = accentColor
    valueLbl.Font = Enum.Font.GothamBold
    valueLbl.TextSize = 13
    valueLbl.TextXAlignment = Enum.TextXAlignment.Right
    valueLbl.Parent = row

    return valueLbl
end

local currentLabel  = makeRow(42, "🫧", "Current",    Color3.fromRGB(140, 190, 255))
local farmedLabel   = makeRow(68, "📈", "Farmed",     Color3.fromRGB(140, 255, 180))
local perMinLabel   = makeRow(94, "⏱", "Per Minute", Color3.fromRGB(255, 210, 130))
local perHourLabel  = makeRow(120, "🕐", "Per Hour",   Color3.fromRGB(255, 150, 150))

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
    currentLabel.Text = formatNum(currentValue or 0)
    farmedLabel.Text  = formatNum(farmedTotal)

    local elapsedMin = (os.clock() - startTime) / 60
    local perMin, perHour = 0, 0
    if elapsedMin > 0.0167 then
        perMin = farmedTotal / elapsedMin
        perHour = perMin * 60
    end

    perMinLabel.Text  = "~" .. formatNum(perMin)
    perHourLabel.Text = "~" .. formatNum(perHour)
end

local function onCashText(text)
    local newVal = parseCash(text)
    if not newVal then return end

    if currentValue == nil then
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

task.spawn(function()
    while _G.__CashTrackerGen == GEN do
        frame.Visible = (_G.ShowBalance ~= false)
        task.wait(0.2)
    end
end)

updateGui()
