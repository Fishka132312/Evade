_G.AutoRevive = _G.AutoRevive or false

if _G.AutoReviveConnection then
    _G.AutoReviveConnection:Disconnect()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Event = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SetPlayerMode")

local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

local function revive()
    if Event then
        Event:FireServer(true)
    end
end

local respawnFrame = nil

local function checkGui()
    local gameGui = pg:FindFirstChild("Game")
    if gameGui then
        local respawn = gameGui:FindFirstChild("Respawn")
        if respawn then
            respawnFrame = respawn
            return true
        end
    end
    return false
end

_G.AutoReviveConnection = game:GetService("RunService").Heartbeat:Connect(function()
    if not _G.AutoRevive then
        return
    end
    
    if not respawnFrame or not respawnFrame.Parent then
        if not checkGui() then
            return
        end
    end
    
    if respawnFrame.Visible then
        revive()
    end
end)
