-- ==================== NPC ESP SCRIPT (Видимые части) ====================
if _G.NPCEspScriptLoaded then
    print("✅ NPC ESP скрипт уже запущен!")
    return
end

_G.NPCEspScriptLoaded = true
_G.EspNPC = _G.EspNPC or false

local RunService = game:GetService("RunService")
local highlights = {}  -- [model] = {highlight1, highlight2, ...}

local function isNPC(model)
    if not model or not model:FindFirstChild("HumanoidRootPart") then
        return false
    end
    return model:GetAttribute("AI") == true
end

local function createHighlights(model)
    if highlights[model] then return end
    
    highlights[model] = {}
    local partsHighlighted = 0

    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            -- Пропускаем полностью прозрачные части
            if part.Transparency < 0.95 then
                local highlight = Instance.new("Highlight")
                highlight.Name = "NPCEspHighlight"
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 80, 80)
                highlight.FillTransparency = 0.6
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Adornee = part
                highlight.Parent = model
                
                table.insert(highlights[model], highlight)
                partsHighlighted += 1
            end
        end
    end

    if partsHighlighted == 0 then
        -- Если ничего не нашлось — подсвечиваем хотя бы RootPart
        local root = model:FindFirstChild("HumanoidRootPart")
        if root then
            local highlight = Instance.new("Highlight")
            highlight.Name = "NPCEspHighlight"
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 100, 100)
            highlight.FillTransparency = 0.7
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Adornee = root
            highlight.Parent = model
            table.insert(highlights[model], highlight)
        end
    end
end

local function removeHighlights(model)
    if highlights[model] then
        for _, hl in ipairs(highlights[model]) do
            hl:Destroy()
        end
        highlights[model] = nil
    end
end

local function updateESP()
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return end

    for _, model in ipairs(playersFolder:GetChildren()) do
        if isNPC(model) then
            if _G.EspNPC then
                createHighlights(model)
            else
                removeHighlights(model)
            end
        end
    end

    -- Очистка удалённых NPC
    for model, _ in pairs(highlights) do
        if not model.Parent or not isNPC(model) then
            removeHighlights(model)
        end
    end
end

RunService.Heartbeat:Connect(function()
    if not _G.EspNPC then
        for model, _ in pairs(highlights) do
            removeHighlights(model)
        end
        return
    end
    updateESP()
end)

print("✅ NPC ESP (многочастевой) загружен!")
print("   _G.EspNPC = true / false — управление")
