_G.AutoRevive = _G.AutoRevive or false

if _G.AutoReviveConnection then
    _G.AutoReviveConnection:Disconnect()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Event = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SetPlayerMode")

local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

local lastRevive = 0
local cooldown = 5

local respawnFrame = nil

local function revive()
    local now = tick()
    if now - lastRevive < cooldown then
        return
    end
    if Event then
        Event:FireServer(true)
        lastRevive = now
    end
end

local function findRespawn()
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
    if not _G.AutoRevive then return end
    
    if not respawnFrame or not respawnFrame.Parent then
        if not findRespawn() then
            return
        end
    end
    
    if respawnFrame.Visible then
        revive()
    end
end)
