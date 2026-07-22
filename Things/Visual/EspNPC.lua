-- ==================== NPC ESP SCRIPT ====================
if _G.NPCEspScriptLoaded then
    print("✅ NPC ESP скрипт уже запущен!")
    return
end

_G.NPCEspScriptLoaded = true
_G.EspNPC = _G.EspNPC or false  -- ← можно менять из другого скрипта

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local highlights = {}  -- [model] = Highlight

local function isNPC(model)
    if not model or not model:FindFirstChild("HumanoidRootPart") then
        return false
    end
    return model:GetAttribute("AI") == true
end

local function createHighlight(model)
    if highlights[model] then return highlights[model] end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "NPCEspHighlight"
    highlight.FillColor = Color3.fromRGB(255, 0, 0)      -- красный
    highlight.OutlineColor = Color3.fromRGB(255, 100, 100)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = model
    highlight.Parent = model
    
    highlights[model] = highlight
    return highlight
end

local function removeHighlight(model)
    if highlights[model] then
        highlights[model]:Destroy()
        highlights[model] = nil
    end
end

local function updateESP()
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return end

    -- Добавляем подсветку новым NPC
    for _, model in ipairs(playersFolder:GetChildren()) do
        if isNPC(model) then
            if _G.EspNPC then
                createHighlight(model)
            else
                removeHighlight(model)
            end
        end
    end

    -- Удаляем подсветку у тех, кого больше нет
    for model, hl in pairs(highlights) do
        if not model.Parent or not isNPC(model) then
            removeHighlight(model)
        end
    end
end

-- Основной цикл
RunService.Heartbeat:Connect(function()
    if not _G.EspNPC then
        -- Если ESP выключен — чистим всё
        for model, _ in pairs(highlights) do
            removeHighlight(model)
        end
        return
    end

    updateESP()
end)

print("✅ NPC ESP скрипт успешно загружен!")
print("   Используй _G.EspNPC = true / false для включения/выключения")
