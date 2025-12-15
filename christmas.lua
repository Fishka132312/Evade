local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Murder Mystery 2", HidePremium = false, SaveConfig = true, ConfigFolder = "Murder Mystery 2"})

local Tab = Window:MakeTab({
	Name = "Farm",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

Tab:AddButton({
	Name = "Add Speed",
	Callback = function()
    local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer

RunService.RenderStepped:Connect(function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 30
    end
end)
  	end    
})





--------------------------------MISC-----------------------------
local Tab = Window:MakeTab({
	Name = "Misc",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

Tab:AddButton({
	Name = "Add Speed",
	Callback = function()
    local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer

RunService.RenderStepped:Connect(function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 30
    end
end)
  	end    
})


Tab:AddButton({
	Name = "Infinite Yield",
	Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
  	end    
})
OrionLib:Init()





