local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TARGET_FOLDER = workspace:WaitForChild("Game"):WaitForChild("Players")
local HIGHLIGHT_NAME = "Downed"

-- ==================== ЗАЩИТА ОТ ПОВТОРНОГО ЗАПУСКА ====================
if _G.DownedESPHandler then
    print("ESP Downed уже запущен. Перезагружаем...")
    _G.DownedESPHandler:Disconnect()
end

-- Очистка старых хайлайтов
for _, item in pairs(TARGET_FOLDER:GetDescendants()) do
    if item.Name == HIGHLIGHT_NAME then
        item:Destroy()
    end
end

-- ==================== ОСНОВНАЯ ЛОГИКА ====================
local function updateHighlight(model)
    if not model or not model:IsA("Model") then return end
    if LocalPlayer.Character and model == LocalPlayer.Character then
        return
    end

    local isDowned = model:GetAttribute("Downed") == true
    local isCarried = model:GetAttribute("Carried") == true

    local highlight = model:FindFirstChild(HIGHLIGHT_NAME)

    if _G.EspDowned and isDowned and not isCarried then
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = HIGHLIGHT_NAME
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Parent = model
        end
    else
        if highlight then
            highlight:Destroy()
        end
    end
end

local function setupModel(model)
    if not model:IsA("Model") then return end
    if LocalPlayer.Character and model == LocalPlayer.Character then return end

    -- Удаляем старые коннекты, если есть
    if model:FindFirstChild("DownedESPConnection") then
        model.DownedESPConnection:Destroy()
    end

    local conn = model.AttributeChanged:Connect(function()
        updateHighlight(model)
    end)

    -- Сохраняем коннект внутри модели для удобства очистки
    local connValue = Instance.new("ObjectValue")
    connValue.Name = "DownedESPConnection"
    connValue.Value = conn
    connValue.Parent = model

    updateHighlight(model)
end

-- Подключаемся к новым игрокам
local childAddedConn = TARGET_FOLDER.ChildAdded:Connect(setupModel)

-- Настраиваем уже существующих
for _, child in pairs(TARGET_FOLDER:GetChildren()) do
    setupModel(child)
end

-- Мониторинг включения/выключения ESP
local stateMonitor = task.spawn(function()
    local lastState = _G.EspDowned
    while true do
        if _G.EspDowned ~= lastState then
            lastState = _G.EspDowned
            for _, child in pairs(TARGET_FOLDER:GetChildren()) do
                updateHighlight(child)
            end
        end
        task.wait(0.5)
    end
end)

-- Сохраняем всё для возможности отключения
_G.DownedESPHandler = childAddedConn

print("✅ ESP Downed Script Loaded (LocalPlayer Ignored)!")

-- Команда для ручного отключения (если нужно)
_G.DisableDownedESP = function()
    if _G.DownedESPHandler then
        _G.DownedESPHandler:Disconnect()
        _G.DownedESPHandler = nil
    end
    for _, item in pairs(TARGET_FOLDER:GetDescendants()) do
        if item.Name == HIGHLIGHT_NAME or item.Name == "DownedESPConnection" then
            item:Destroy()
        end
    end
    print("ESP Downed отключён.")
end
