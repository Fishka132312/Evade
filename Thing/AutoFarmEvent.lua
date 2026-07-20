if _G.FarmScriptLoaded then 
    print("Скрипт уже запущен!") 
    return 
end
_G.FarmScriptLoaded = true

_G.FarmEvent = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local safePlatform = Instance.new("Part")
safePlatform.Size = Vector3.new(20, 1, 20)
safePlatform.Anchored = true
safePlatform.Transparency = 0.5
safePlatform.Parent = workspace

local ticketPlatform = Instance.new("Part")
ticketPlatform.Size = Vector3.new(10, 1, 10)
ticketPlatform.Anchored = true
ticketPlatform.Transparency = 0.5
ticketPlatform.Parent = workspace

local function getRootPart()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        return char.HumanoidRootPart
    end
    return nil
end

task.spawn(function()
    while task.wait(0.2) do
        if _G.FarmEvent then
            local root = getRootPart()
            if not root then continue end

            local ticketsFolder = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("Tickets")
            
            local targetTicket = nil
            if ticketsFolder then
                local tickets = ticketsFolder:GetChildren()
                if #tickets > 0 then
                    targetTicket = tickets[1]
                end
            end

            if targetTicket then
                local ticketPos = targetTicket:GetPivot().Position
                local farmCFrame = CFrame.new(ticketPos - Vector3.new(0, 5, 0))
                
                ticketPlatform.CFrame = farmCFrame - Vector3.new(0, 3.5, 0)
                root.CFrame = farmCFrame
                
                while targetTicket and targetTicket.Parent == ticketsFolder and _G.FarmEvent do
                    task.wait(0.1)
                    local currentRoot = getRootPart()
                    if currentRoot then
                        currentRoot.CFrame = farmCFrame
                    end
                end
                
                ticketPlatform.CFrame = CFrame.new(0, -10000, 0)
            else
                local safeZoneMap = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("SafeZones")
                if safeZoneMap then
                    local safePos = safeZoneMap:GetPivot().Position
                    local highCFrame = CFrame.new(safePos + Vector3.new(0, 1000, 0))
                    
                    safePlatform.CFrame = highCFrame - Vector3.new(0, 3.5, 0)
                    root.CFrame = highCFrame
                end
            end
        else
            safePlatform.CFrame = CFrame.new(0, -10000, 0)
            ticketPlatform.CFrame = CFrame.new(0, -10000, 0)
        end
    end
end)
