local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "❤️ Evade🏮", HidePremium = false, SaveConfig = true, ConfigFolder = "🎄Evade🎄"})

local Tab = Window:MakeTab({
	Name = "Event farm 💌",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
	Name = "Event farm"
})

local toggled = false

Tab:AddToggle({
    Name = "Ticket (Use at own risk)",
    Default = false,
    Callback = function(Value)
        toggled = Value

        if toggled then
            task.spawn(function()
                local Players = game:GetService("Players")
                local player = Players.LocalPlayer

                local gameFolder = workspace:WaitForChild("Game")
                local itemSpawns = gameFolder:WaitForChild("Map"):WaitForChild("ItemSpawns")
                local ticketsFolder = gameFolder:WaitForChild("Effects"):WaitForChild("Tickets")
                local playersFolder = gameFolder:WaitForChild("Players")

                local WAIT_AT_ITEM = 1.0
                local DANGER_RADIUS = 20 
                local ESCAPE_TIME = 2.0 

                local platform = workspace:FindFirstChild("SafeZonePlatform") or Instance.new("Part")
                platform.Name = "SafeZonePlatform"
                platform.Size = Vector3.new(20, 1, 20)
                platform.Anchored = true
                platform.CanCollide = true
                platform.Transparency = 0.5 
                platform.BrickColor = BrickColor.new("Bright blue")
                platform.Parent = workspace

                local function getSafeZoneCFrame()
                    return itemSpawns:GetPivot() * CFrame.new(0, 500, 0)
                end

                local function isAnyoneNearby(myPart)
                    for _, otherChar in ipairs(playersFolder:GetChildren()) do
                        if otherChar:IsA("Model") and otherChar.Name ~= player.Name then
                            local healthcare = otherChar:FindFirstChild("Humanoid")
                            if healthcare and healthcare.Health > 0 then
                                local otherRoot = otherChar:FindFirstChild("HumanoidRootPart") or healthcare.RootPart
                                if otherRoot then
                                    local dist = (myPart.Position - otherRoot.Position).Magnitude
                                    if dist < DANGER_RADIUS then
                                        return true
                                    end
                                end
                            end
                        end
                    end
                    return false
                end

                while toggled do 
                    local character = player.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    local humanoid = character and character:FindFirstChild("Humanoid")
                    
                    local safeCFrame = getSafeZoneCFrame()
                    platform.CFrame = safeCFrame * CFrame.new(0, -3.5, 0)

                    if rootPart and humanoid and humanoid.Health > 0 then
                        if isAnyoneNearby(rootPart) then
                            rootPart.CFrame = safeCFrame
                            task.wait(ESCAPE_TIME)
                        else
                            local target = nil
                            for _, child in ipairs(ticketsFolder:GetChildren()) do
                                if child.Name == "Visual" then
                                    target = child
                                    break
                                end
                            end

                            if target then
                                rootPart.CFrame = target:GetPivot()
                                
                                local start = tick()
                                while tick() - start < WAIT_AT_ITEM and toggled do
                                    if isAnyoneNearby(rootPart) then break end
                                    if not target.Parent then break end
                                    task.wait(0.1)
                                end
                            else
                                if (rootPart.Position - safeCFrame.Position).Magnitude > 10 then
                                    rootPart.CFrame = safeCFrame
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end

                if platform then platform.CFrame = CFrame.new(0, -1000, 0) end 
            end)
        end
    end    
})

Tab:AddToggle({
	Name = "XP FARM",
	Default = false,
	Callback = function(Value)
		_G.AutoFarmActive = Value
		
		if _G.AutoFarmActive then
			task.spawn(function()
				local Players = game:GetService("Players")
				local TextChatService = game:GetService("TextChatService")
				local player = Players.LocalPlayer
				
				local IMAGE_ID = "rbxassetid://126150774709719"
				local SAFE_POSITION = Vector3.new(0, 500, 0)
				local isProcessing = false

				local platform = workspace:FindFirstChild("SafeZoneWithDecal")
				if not platform then
					platform = Instance.new("Part")
					platform.Name = "SafeZoneWithDecal"
					platform.Size = Vector3.new(20, 1, 20)
					platform.Position = SAFE_POSITION - Vector3.new(0, 3.5, 0)
					platform.Anchored = true
					platform.CanCollide = true
					platform.BrickColor = BrickColor.new("Bright blue")
					platform.Transparency = 0.5
					platform.Parent = workspace

					local decal = Instance.new("Decal")
					decal.Texture = IMAGE_ID
					decal.Face = Enum.NormalId.Top 
					decal.Parent = platform
				end

				local function getRewardsGui()
					local pg = player:FindFirstChild("PlayerGui")
					local global = pg and pg:FindFirstChild("Global")
					return global and global:FindFirstChild("Rewards")
				end

				local function sendMessage(msg)
					if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
						local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
						if channel then channel:SendAsync(msg) end
					else
						local chatEvent = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
						if chatEvent and chatEvent:FindFirstChild("SayMessageRequest") then
							chatEvent.SayMessageRequest:FireServer(msg, "All")
						end
					end
				end

				print("Autofarm & SafeZone: ON")

				while _G.AutoFarmActive do
					local character = player.Character
					local rootPart = character and character:FindFirstChild("HumanoidRootPart")
					
					if rootPart then
						if (rootPart.Position - SAFE_POSITION).Magnitude > 5 then
							rootPart.CFrame = CFrame.new(SAFE_POSITION)
						end
					end

					local rewardsGui = getRewardsGui()
					if rewardsGui and rewardsGui.Visible == true and not isProcessing then
						isProcessing = true
						print("Награда получена, перезапуск...")
						
						if rewardsGui then rewardsGui.Visible = false end 
						task.wait(2)
						sendMessage("!map Maze")
						task.wait(17)
						sendMessage("!specialround Mimic")
						task.wait(1)
						sendMessage("!Timer 1")
						
						isProcessing = false
					end

					task.wait(1)
				end

				if platform then platform:Destroy() end
				print("Autofarm & SafeZone: OFF")
			end)
		end
	end    
})


Tab:AddButton({
	Name = "MAZE + TEXT",
	Callback = function()
			local TextChatService = game:GetService("TextChatService")

local function sendMessage(msg)
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if channel then channel:SendAsync(msg) end
    else
        local chatEvent = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        if chatEvent and chatEvent:FindFirstChild("SayMessageRequest") then
            chatEvent.SayMessageRequest:FireServer(msg, "All")
        end
    end
end

sendMessage("!map Maze")
task.wait(17)

sendMessage("!specialround Mimic")
task.wait(1)

sendMessage("!Timer 1")

print("Down")
  	end    
})

Tab:AddButton({
	Name = "Shutdown Game if dev join",
	Callback = function()
			local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local isScriptActive = true

local function shutdownServer()
    if isScriptActive and #Players:GetPlayers() > 1 then
        game:Shutdown() 
    end
end

Players.PlayerAdded:Connect(function()
    shutdownServer()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
        isScriptActive = false
    end
end)

shutdownServer()
  	end    
})

----------------------------LVL---------------------------------
local Tab = Window:MakeTab({
	Name = "XP FARM",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
	Name = "PV SERVER FARM (FASTEST)"
})

Tab:AddToggle({
	Name = "XP FARM",
	Default = false,
	Callback = function(Value)
		_G.AutoFarmActive = Value
		
		if _G.AutoFarmActive then
			task.spawn(function()
				local Players = game:GetService("Players")
				local TextChatService = game:GetService("TextChatService")
				local player = Players.LocalPlayer
				
				local IMAGE_ID = "rbxassetid://126150774709719"
				local SAFE_POSITION = Vector3.new(0, 500, 0)
				local isProcessing = false

				local platform = workspace:FindFirstChild("SafeZoneWithDecal")
				if not platform then
					platform = Instance.new("Part")
					platform.Name = "SafeZoneWithDecal"
					platform.Size = Vector3.new(20, 1, 20)
					platform.Position = SAFE_POSITION - Vector3.new(0, 3.5, 0)
					platform.Anchored = true
					platform.CanCollide = true
					platform.BrickColor = BrickColor.new("Bright blue")
					platform.Transparency = 0.5
					platform.Parent = workspace

					local decal = Instance.new("Decal")
					decal.Texture = IMAGE_ID
					decal.Face = Enum.NormalId.Top 
					decal.Parent = platform
				end

				local function getRewardsGui()
					local pg = player:FindFirstChild("PlayerGui")
					local global = pg and pg:FindFirstChild("Global")
					return global and global:FindFirstChild("Rewards")
				end

				local function sendMessage(msg)
					if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
						local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
						if channel then channel:SendAsync(msg) end
					else
						local chatEvent = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
						if chatEvent and chatEvent:FindFirstChild("SayMessageRequest") then
							chatEvent.SayMessageRequest:FireServer(msg, "All")
						end
					end
				end

				print("Autofarm & SafeZone: ON")

				while _G.AutoFarmActive do
					local character = player.Character
					local rootPart = character and character:FindFirstChild("HumanoidRootPart")
					
					if rootPart then
						if (rootPart.Position - SAFE_POSITION).Magnitude > 5 then
							rootPart.CFrame = CFrame.new(SAFE_POSITION)
						end
					end

					local rewardsGui = getRewardsGui()
					if rewardsGui and rewardsGui.Visible == true and not isProcessing then
						isProcessing = true
						print("Награда получена, перезапуск...")
						
						if rewardsGui then rewardsGui.Visible = false end 
						task.wait(2)
						sendMessage("!map Maze")
						task.wait(17)
						sendMessage("!specialround Mimic")
						task.wait(1)
						sendMessage("!Timer 1")
						
						isProcessing = false
					end

					task.wait(1)
				end

				if platform then platform:Destroy() end
				print("Autofarm & SafeZone: OFF")
			end)
		end
	end    
})

Tab:AddButton({
	Name = "SET MAZE + TEXT",
	Callback = function()
			local TextChatService = game:GetService("TextChatService")

local function sendMessage(msg)
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if channel then channel:SendAsync(msg) end
    else
        local chatEvent = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        if chatEvent and chatEvent:FindFirstChild("SayMessageRequest") then
            chatEvent.SayMessageRequest:FireServer(msg, "All")
        end
    end
end

sendMessage("!map Maze")
task.wait(17)

sendMessage("!specialround Mimic")
task.wait(1)

sendMessage("!Timer 1")

print("Down")
  	end    
})

local Section = Tab:AddSection({
	Name = "PUBLIC SERVER FARM"
})

Tab:AddToggle({
    Name = "XP FARM",
    Default = false,
    Callback = function(Value)
        _G.SafeZoneEnabled = Value

        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        local IMAGE_ID = "rbxassetid://126150774709719"
        local SAFE_POSITION = Vector3.new(0, 500, 0)

        if Value then
            if not workspace:FindFirstChild("SafeZoneWithDecal") then
                local platform = Instance.new("Part")
                platform.Name = "SafeZoneWithDecal"
                platform.Size = Vector3.new(20, 1, 20)
                platform.Position = SAFE_POSITION - Vector3.new(0, 3.5, 0)
                platform.Anchored = true
                platform.CanCollide = true
                platform.BrickColor = BrickColor.new("Bright blue")
                platform.Transparency = 0.5
                platform.Parent = workspace

                local decal = Instance.new("Decal")
                decal.Name = "PlatformLogo"
                decal.Texture = IMAGE_ID
                decal.Face = Enum.NormalId.Top 
                decal.Parent = platform
            end

            task.spawn(function()
                while _G.SafeZoneEnabled do
                    local character = player.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        character.HumanoidRootPart.CFrame = CFrame.new(SAFE_POSITION)
                    end
                    task.wait(0.1)
                end
            end)
        else
            local oldPlatform = workspace:FindFirstChild("SafeZoneWithDecal")
            if oldPlatform then
                oldPlatform:Destroy()
            end
        end
    end    
})

local Section = Tab:AddSection({
	Name = "FUN"
})


Tab:AddButton({
	Name = "TP OUTSIDE MAP 1",
	Callback = function()
			local Players = game:GetService("Players")
local player = Players.LocalPlayer
local itemSpawns = workspace.Game.Map.ItemSpawns

local function checkAndExitZone()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local charPos = hrp.Position
    
    local modelCFrame, modelSize = itemSpawns:GetBoundingBox()
    
    local relativePos = modelCFrame:PointToObjectSpace(charPos)
    
    local isInside = math.abs(relativePos.X) <= modelSize.X / 2
                 and math.abs(relativePos.Y) <= modelSize.Y / 2
                 and math.abs(relativePos.Z) <= modelSize.Z / 2

    if isInside then
					
        local offsetX = (modelSize.X / 2) + 5
        if relativePos.X < 0 then offsetX = -offsetX end
        
        local newRelativePos = Vector3.new(offsetX, relativePos.Y, relativePos.Z)
        local targetWorldPos = modelCFrame:PointToWorldSpace(newRelativePos)
        
        hrp.CFrame = CFrame.new(targetWorldPos)
    else
        print("error")
    end
end

checkAndExitZone()
  	end    
})

Tab:AddButton({
	Name = "TP OUTSIDE MAP 2",
	Callback = function()
			local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

local IMAGE_ID = "rbxassetid://126150774709719"
local SAFE_POSITION = Vector3.new(0, 500, 0)

local platform = Instance.new("Part")
platform.Name = "SafeZoneWithDecal"
platform.Size = Vector3.new(20, 1, 20)
platform.Position = SAFE_POSITION - Vector3.new(0, 3.5, 0)
platform.Anchored = true
platform.CanCollide = true
platform.BrickColor = BrickColor.new("Bright blue")
platform.Transparency = 0.5
platform.Parent = workspace

local decal = Instance.new("Decal")
decal.Name = "PlatformLogo"
decal.Texture = IMAGE_ID
decal.Face = Enum.NormalId.Top 
decal.Parent = platform

rootPart.CFrame = CFrame.new(SAFE_POSITION)
  	end    
})

Tab:AddButton({
	Name = "Remove invis parts",
	Callback = function()
			local folder = workspace.Game.Map.InvisParts

local function monitorPart(part)
	if part:IsA("BasePart") then
		part.CanCollide = false
		
		part:GetPropertyChangedSignal("CanCollide"):Connect(function()
			if part.CanCollide == true then
				part.CanCollide = false
			end
		end)
	end
end

local function processAll(parent)
	for _, child in ipairs(parent:GetChildren()) do
		monitorPart(child) 
		processAll(child)
	end
end

processAll(folder)

folder.DescendantAdded:Connect(function(descendant)
	monitorPart(descendant)
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
	Name = "better dont click it!",
	Callback = function()
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local SoundService = game:GetService("SoundService")

-- Настройки
local IMAGE_ID = "rbxassetid://102775636999671"
local SOUND_ID = "rbxassetid://91054348924048"
local SKY_ID   = "rbxassetid://102775636999671"
local SKY_NAME = "CustomSky"

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "IntroGui"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, 0, 1, 0)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.Parent = screenGui

local imageLabel = Instance.new("ImageLabel")
imageLabel.Size = UDim2.new(0.5, 0, 0.5, 0) 
imageLabel.Position = UDim2.new(0.25, 0, 0.25, 0)
imageLabel.BackgroundTransparency = 1
imageLabel.Image = IMAGE_ID
imageLabel.Parent = frame

local sound = Instance.new("Sound")
sound.SoundId = SOUND_ID
sound.Volume = 1
sound.Parent = SoundService

local function setCustomSky()
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("Sky") then
            obj:Destroy()
        end
    end

    local newSky = Instance.new("Sky")
    newSky.Name = SKY_NAME
    newSky.SkyboxBk = SKY_ID
    newSky.SkyboxDn = SKY_ID
    newSky.SkyboxFt = SKY_ID
    newSky.SkyboxLf = SKY_ID
    newSky.SkyboxRt = SKY_ID
    newSky.SkyboxUp = SKY_ID
    newSky.SunTextureId = ""
    newSky.MoonTextureId = ""
    newSky.Parent = Lighting
    warn("Система: Небо обновлено на " .. SKY_NAME)
end

task.spawn(function()
    ContentProvider:PreloadAsync({imageLabel, sound})
end)

sound:Play()

local timer = 0
repeat 
    task.wait(0.1)
    timer = timer + 0.1
until (sound.TimePosition >= sound.TimeLength and sound.TimeLength > 0) or timer > 10

screenGui:Destroy()
sound:Destroy()
setCustomSky()

task.spawn(function()
    while true do
        task.wait(math.random(5, 10)) 
        
        local currentSky = Lighting:FindFirstChild(SKY_NAME)
        
        local skyCount = 0
        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:IsA("Sky") then
                skyCount = skyCount + 1
            end
        end

        if not currentSky or skyCount > 1 then
            setCustomSky()
        end
    end
end)
  	end    
})

Tab:AddButton({
	Name = "Fps boost",
	Callback = function()
    local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lighting = game:GetService("Lighting")
local terrain = workspace:FindFirstChildOfClass("Terrain")

local active = true

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
        active = false
        print("FPS Boost turned")
    end
end)

settings().Rendering.QualityLevel = 1
lighting.GlobalShadows = false
lighting.FogEnd = 9e9
lighting.Brightness = 1 

if terrain then
    terrain.WaterWaveSize = 0
    terrain.WaterWaveSpeed = 0
    terrain.WaterReflectance = 0
    terrain.WaterTransparency = 0
    terrain.Decoration = false 
end

local function cleanUp(v)
    if not active then return end
    
    if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
        v.Material = Enum.Material.SmoothPlastic
        v.Reflectance = 0
    elseif v:IsA("Decal") or v:IsA("Texture") then
        v:Destroy()
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Explosion") then
        v.Enabled = false
    elseif v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") then
        v.Enabled = false
    end
end

for _, v in pairs(game:GetDescendants()) do
    cleanUp(v)
end
game.DescendantAdded:Connect(function(v)
    if active then
        cleanUp(v)
    end
end)
  	end    
})

Tab:AddButton({
	Name = "Infinite Yield",
	Callback = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Fishka132312/ignore-it/refs/heads/main/infiniteyield'))()
  	end    
})


local Tab = Window:MakeTab({
	Name = "Outdated",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
	Name = "Test"
})

local Section = Tab:AddSection({
	Name = "Farm c to turn off"
})

Tab:AddButton({
	Name = "Ticket (SAFEST METHOD)",
	Callback = function()
    local RunService = game:GetService("RunService")
	local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local BASE_SPEED = 16
local REACH_DISTANCE = 3.5 
local APPEAR_DELAY = {min = 1, max = 2}
local isRunning = true

print("--- Легитный автосбор (с задержкой реакции) запущен ---")
print("Остановка: CTRL или C")

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and (input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.C) then
        isRunning = false
        print("!!! СКРИПТ ОСТАНОВЛЕН !!!")
    end
end)

local function getTicketsFolder()
    return workspace:FindFirstChild("Game") 
        and workspace.Game:FindFirstChild("Effects") 
        and workspace.Game.Effects:FindFirstChild("Tickets")
end

task.spawn(function()
    while isRunning do
        task.wait(0.1)
        
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local ticketsFolder = getTicketsFolder()

        if not rootPart or not ticketsFolder or not isRunning then continue end

        local target = nil
        local minDistance = math.huge
        for _, child in ipairs(ticketsFolder:GetChildren()) do
            if child.Name == "Visual" then
                local success, pos = pcall(function() return child:GetPivot().Position end)
                if success then
                    local dist = (rootPart.Position - pos).Magnitude
                    if dist < minDistance then
                        minDistance = dist
                        target = child
                    end
                end
            end
        end

        if target and isRunning then
            local reactionTime = math.random(APPEAR_DELAY.min * 10, APPEAR_DELAY.max * 10) / 10
            task.wait(reactionTime)
            
            if not target.Parent or not isRunning then continue end

            local targetPos = target:GetPivot().Position
            
            local angle = math.rad(math.random(0, 360))
            local randomDist = math.random(2, 5) 
            local offset = Vector3.new(math.cos(angle) * randomDist, 0, math.sin(angle) * randomDist)
            local finalGoal = targetPos + offset
            
            local distance = (rootPart.Position - finalGoal).Magnitude
            local currentSpeed = BASE_SPEED + (math.random(-15, 15) / 10)
            local duration = distance / currentSpeed
            
            local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            
            local tween = TweenService:Create(rootPart, tweenInfo, {
                CFrame = CFrame.new(finalGoal, targetPos)
            })
            
            tween:Play()
            
            local startWait = tick()
            repeat 
                task.wait(0.05)
            until not target.Parent or not isRunning or (tick() - startWait) > duration or (rootPart.Position - targetPos).Magnitude < REACH_DISTANCE
            
            tween:Cancel()
        end
    end
end)
  	end    
})


Tab:AddButton({
	Name = "Ticket (SAFEST METHOD FASTER)",
	Callback = function()
    local RunService = game:GetService("RunService")
	local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local BASE_SPEED = 30 
local REACH_DISTANCE = 3.5 
local APPEAR_DELAY = {min = 0.5, max = 1}
local isRunning = true

print("--- Легитный автосбор (с задержкой реакции) запущен ---")
print("Остановка: CTRL или C")

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and (input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.C) then
        isRunning = false
        print("!!! СКРИПТ ОСТАНОВЛЕН !!!")
    end
end)

local function getTicketsFolder()
    return workspace:FindFirstChild("Game") 
        and workspace.Game:FindFirstChild("Effects") 
        and workspace.Game.Effects:FindFirstChild("Tickets")
end

task.spawn(function()
    while isRunning do
        task.wait(0.1)
        
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local ticketsFolder = getTicketsFolder()

        if not rootPart or not ticketsFolder or not isRunning then continue end

        local target = nil
        local minDistance = math.huge
        for _, child in ipairs(ticketsFolder:GetChildren()) do
            if child.Name == "Visual" then
                local success, pos = pcall(function() return child:GetPivot().Position end)
                if success then
                    local dist = (rootPart.Position - pos).Magnitude
                    if dist < minDistance then
                        minDistance = dist
                        target = child
                    end
                end
            end
        end

        if target and isRunning then
            local reactionTime = math.random(APPEAR_DELAY.min * 10, APPEAR_DELAY.max * 10) / 10
            task.wait(reactionTime)
            
            if not target.Parent or not isRunning then continue end

            local targetPos = target:GetPivot().Position
            
            local angle = math.rad(math.random(0, 360))
            local randomDist = math.random(2, 5) 
            local offset = Vector3.new(math.cos(angle) * randomDist, 0, math.sin(angle) * randomDist)
            local finalGoal = targetPos + offset
            
            local distance = (rootPart.Position - finalGoal).Magnitude
            local currentSpeed = BASE_SPEED + (math.random(-15, 15) / 10)
            local duration = distance / currentSpeed
            
            local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            
            local tween = TweenService:Create(rootPart, tweenInfo, {
                CFrame = CFrame.new(finalGoal, targetPos)
            })
            
            tween:Play()
            
            local startWait = tick()
            repeat 
                task.wait(0.05)
            until not target.Parent or not isRunning or (tick() - startWait) > duration or (rootPart.Position - targetPos).Magnitude < REACH_DISTANCE
            
            tween:Cancel()
        end
    end
end)
  	end    
})

Tab:AddButton({
	Name = "Stop Farm if dev join (Only in pc)",
	Callback = function()
			local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local isScriptActive = true

local function pressKeyC()
    if isScriptActive and #Players:GetPlayers() > 1 then
        print("Игрок зашел! Имитирую нажатие 'C'...")
        
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.C, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, game)
    end
end

Players.PlayerAdded:Connect(function()
    pressKeyC()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
        isScriptActive = false
    end
end)

if #Players:GetPlayers() > 1 then
    pressKeyC()
end
  	end    
})


Tab:AddButton({
	Name = "Copy Cordinates",
	Callback = function()
			local player = game.Players.LocalPlayer
local pos = player.Character.HumanoidRootPart.Position

local x, y, z = math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z)
local message = x .. ", " .. y .. ", " .. z

game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync("My cord: " .. message)

if setclipboard then
    setclipboard(message)
    print("Copied")
else
    print("Executor doesnt suppord copy")
end
  	end    
})

























































