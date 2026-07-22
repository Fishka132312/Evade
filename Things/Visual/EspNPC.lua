-- ==================== NPC ESP SCRIPT (Улучшенный) ====================
if _G.NPCEspScriptLoaded then
    print("✅ NPC ESP скрипт уже запущен!")
    return
end

_G.NPCEspScriptLoaded = true
_G.EspNPC = _G.EspNPC or false

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

    local root = model:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "NPCEspHighlight"
    highlight.FillColor = Color3.fromRGB(255, 50, 50)
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    -- Главное изменение — подсвечиваем HumanoidRootPart
    highlight.Adornee = root
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

    for _, model in ipairs(playersFolder:GetChildren()) do
        if isNPC(model) then
            if _G.EspNPC then
                createHighlight(model)
            else
                removeHighlight(model)
            end
        end
    end

    -- Очистка
    for model, hl in pairs(highlights) do
        if not model.Parent or not isNPC(model) then
            removeHighlight(model)
        end
    end
end

RunService.Heartbeat:Connect(function()
    if not _G.EspNPC then
        for model, _ in pairs(highlights) do
            removeHighlight(model)
        end
        return
    end
    updateESP()
end)

print("✅ NPC ESP скрипт обновлён (MeshPart версия)")
print("   _G.EspNPC = true / false — для управления")
