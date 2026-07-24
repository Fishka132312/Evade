if _G.EspTicketsScriptLoaded then
    return
end
_G.EspTicketsScriptLoaded = true
_G.EspTickets = _G.EspTickets or false
local RunService = game:GetService("RunService")
local ticketsFolder = workspace:WaitForChild("Effects"):WaitForChild("Tickets")
local highlights = {}
local tierNames = {"Sun: Tier1", "Sun: Tier2", "Sun: Tier3", "Sun: Tier4"}
local function applyESP(mesh)
    if highlights[mesh] then return end
    if not mesh or not mesh:IsA("MeshPart") then return end
    local hl = Instance.new("Highlight")
    hl.Adornee = mesh
    hl.FillColor = Color3.fromRGB(255, 0, 0)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.Parent = mesh
    highlights[mesh] = hl
end
local function removeESP(mesh)
    if highlights[mesh] then
        highlights[mesh]:Destroy()
        highlights[mesh] = nil
    end
end
local function updateESP()
    for _, ticket in ipairs(ticketsFolder:GetChildren()) do
        if ticket.Name == "Visual" then
            local sun
            for _, tierName in ipairs(tierNames) do
                sun = ticket:FindFirstChild(tierName)
                if sun then break end
            end
            if sun then
                for _, name in ipairs({"Bubbles", "CD", "Fih", "Person"}) do
                    local mesh = sun:FindFirstChild(name)
                    if mesh and mesh:IsA("MeshPart") then
                        if _G.EspTickets then
                            applyESP(mesh)
                        else
                            removeESP(mesh)
                        end
                    end
                end
            end
        end
    end
    for mesh, _ in pairs(highlights) do
        if not mesh.Parent then
            removeESP(mesh)
        end
    end
end
RunService.Heartbeat:Connect(function()
    if not _G.EspTickets then
        for mesh, _ in pairs(highlights) do
            removeESP(mesh)
        end
        return
    end
    updateESP()
end)
ticketsFolder.ChildAdded:Connect(updateESP)
ticketsFolder.DescendantAdded:Connect(updateESP)
updateESP()
