local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TARGET_FOLDER = workspace:WaitForChild("Game"):WaitForChild("Players")
local HIGHLIGHT_NAME = "Downed"

for _, item in pairs(TARGET_FOLDER:GetDescendants()) do
    if item.Name == HIGHLIGHT_NAME then
        item:Destroy()
    end
end

local function updateHighlight(model)
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
    
    if LocalPlayer.Character and model == LocalPlayer.Character then
        return
    end
    
    model.AttributeChanged:Connect(function()
        updateHighlight(model)
    end)
    
    updateHighlight(model)
end

TARGET_FOLDER.ChildAdded:Connect(setupModel)

for _, child in pairs(TARGET_FOLDER:GetChildren()) do
    setupModel(child)
end

task.spawn(function()
    local lastState = _G.EspDowned
    while true do
        if _G.EspDowned ~= lastState then
            lastState = _G.EspDowned
            for _, child in pairs(TARGET_FOLDER:GetChildren()) do
                if child:IsA("Model") then
                    updateHighlight(child)
                end
            end
        end
        task.wait(0.5)
    end
end)

print("ESP Downed Script Loaded (LocalPlayer Ignored)!")
