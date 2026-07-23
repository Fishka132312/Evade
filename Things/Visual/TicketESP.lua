if _G.TicketsEspScriptLoaded then
    print("✅ Tickets ESP уже запущен!")
    return
end

_G.TicketsEspScriptLoaded = true
_G.EspTickets = _G.EspTickets or false

local RunService = game:GetService("RunService")
local highlights = {}  -- [visualModel] = Highlight

local function isTicketVisual(model)
    if not model or model.Name ~= "Visual" then return false end
    return model:FindFirstChild("HumanoidRootPart")
end

local function createFullESP(visual)
    if highlights[visual] then return end

    local root = visual:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "TicketESP"
    highlight.Adornee = root
    highlight.FillTransparency = 0.85
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = Color3.fromRGB(255, 0, 100)     -- ярко-розовый
    highlight.FillColor = Color3.fromRGB(255, 100, 200)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = visual

    highlights[visual] = highlight
end

local function removeESP(visual)
    if highlights[visual] then
        highlights[visual]:Destroy()
        highlights[visual] = nil
    end
end

local function updateTicketsESP()
    local ticketsFolder = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("Tickets")
    if not ticketsFolder then return end

    -- Создаём ESP
    for _, visual in ipairs(ticketsFolder:GetChildren()) do
        if isTicketVisual(visual) then
            if _G.EspTickets then
                createFullESP(visual)
            else
                removeESP(visual)
            end
        end
    end

    -- Чистка удалённых тикетов
    for visual, _ in pairs(highlights) do
        if not visual.Parent or not isTicketVisual(visual) then
            removeESP(visual)
        end
    end
end

RunService.Heartbeat:Connect(function()
    if not _G.EspTickets then
        for visual, _ in pairs(highlights) do
            removeESP(visual)
        end
        return
    end
    updateTicketsESP()
end)

print("✅ Tickets Full ESP (Highlight) загружен!")
print("   Управление: _G.EspTickets = true / false")
