if _G.NPCEspScriptLoaded then
    print("already running")
    return
end

_G.NPCEspScriptLoaded = true
_G.EspNPC = _G.EspNPC or false

local RunService = game:GetService("RunService")
local highlights = {}

local function isNPC(model)
    if not model then return false end
    local root = model:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    return model:GetAttribute("AI") == true
end

local function applyESP(model)
    if highlights[model] then return end
    
    local root = model:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local billboard = root:FindFirstChild("BillboardGui")
    if not billboard then return end
    
    local icon = billboard:FindFirstChild("Icon")
    if not icon then return end
    
    local stroke = Instance.new("UIStroke")
    stroke.Name = "EspStroke"
    stroke.Color = Color3.fromRGB(255, 0, 0)
    stroke.Thickness = 2.5
    stroke.Transparency = 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = icon
    
    icon.ImageColor3 = Color3.fromRGB(255, 100, 100)
    
    highlights[model] = true
end

local function removeESP(model)
    if not highlights[model] then return end
    
    local root = model:FindFirstChild("HumanoidRootPart")
    if root then
        local billboard = root:FindFirstChild("BillboardGui")
        if billboard then
            local icon = billboard:FindFirstChild("Icon")
            if icon then
                local stroke = icon:FindFirstChild("EspStroke")
                if stroke then stroke:Destroy() end
                icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
            end
        end
    end
    
    highlights[model] = nil
end

local function updateESP()
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return end

    for _, model in ipairs(playersFolder:GetChildren()) do
        if isNPC(model) then
            if _G.EspNPC then
                applyESP(model)
            else
                removeESP(model)
            end
        end
    end

    for model, _ in pairs(highlights) do
        if not model.Parent or not isNPC(model) then
            removeESP(model)
        end
    end
end

RunService.Heartbeat:Connect(function()
    if not _G.EspNPC then
        for model, _ in pairs(highlights) do
            removeESP(model)
        end
        return
    end
    updateESP()
end)
