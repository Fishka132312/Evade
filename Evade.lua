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

Tab:AddToggle({
    Name = "Ticket Farm 1",
    Default = false,
    Callback = function(Value)
        TICKETFARM1 = Value

        if TICKETFARM1 then
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

                while TICKETFARM1 do 
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
                                while tick() - start < WAIT_AT_ITEM and TICKETFARM1 do
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
    Name = "Ticket Farm 2",
    Default = false,
    Callback = function(Value)
        TICKETFARM2 = Value

        if TICKETFARM2 then
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
                
                local DISTANCE_BELOW = 8 

                local platform = workspace:FindFirstChild("SafeZonePlatform") or Instance.new("Part")
                platform.Name = "SafeZonePlatform"
                platform.Size = Vector3.new(15, 1, 15)
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

                while TICKETFARM2 do 
                    local character = player.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    local humanoid = character and character:FindFirstChild("Humanoid")
                    
                    local safeCFrame = getSafeZoneCFrame()

                    if rootPart and humanoid and humanoid.Health > 0 then
                        if isAnyoneNearby(rootPart) then
                            platform.CFrame = safeCFrame * CFrame.new(0, -3.5, 0)
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
                                local targetPos = target:GetPivot().Position
                                local finalPosition = Vector3.new(targetPos.X, targetPos.Y - DISTANCE_BELOW, targetPos.Z)
                                
                                rootPart.CFrame = CFrame.new(finalPosition)
                                
                                platform.CFrame = CFrame.new(finalPosition - Vector3.new(0, 3.5, 0))
                                
                               local start = tick()
                                while tick() - start < WAIT_AT_ITEM and TICKETFARM2 do
                                    if isAnyoneNearby(rootPart) then break end
                                    if not target.Parent then break end
                                    
                                    platform.CFrame = CFrame.new(finalPosition - Vector3.new(0, 3.5, 0))
                                    task.wait(0.1)
                                end
                            else
                                platform.CFrame = safeCFrame * CFrame.new(0, -3.5, 0)
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
    Name = "Ticket Farm 2 (Fixed)",
    Default = false,
    Callback = function(Value)
        TICKETFARMTWEEN = Value

        if TICKETFARMTWEEN then
            task.spawn(function()
                local Players = game:GetService("Players")
                local TweenService = game:GetService("TweenService")
                local player = Players.LocalPlayer
                
                local gameFolder = workspace:WaitForChild("Game")
                local itemSpawns = gameFolder:WaitForChild("Map"):WaitForChild("ItemSpawns")
                local ticketsFolder = gameFolder:WaitForChild("Effects"):WaitForChild("Tickets")
                
                local DISTANCE_BELOW = 10 
                local TWEEN_SPEED = 0.8 

                local platform = workspace:FindFirstChild("SafeZonePlatform")
                if not platform then
                    platform = Instance.new("Part")
                    platform.Name = "SafeZonePlatform"
                    platform.Size = Vector3.new(15, 1, 15)
                    platform.Anchored = true
                    platform.CanCollide = true
                    platform.Transparency = 0.5
                    platform.BrickColor = BrickColor.new("Bright blue")
                    platform.Parent = workspace
                end

                local currentTarget = nil -- Переменная, чтобы знать, где мы сейчас стоим

                local function smoothMove(targetPosition)
                    local character = player.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    if not rootPart then return end

                    local charTargetPos = Vector3.new(targetPosition.X, targetPosition.Y - DISTANCE_BELOW, targetPosition.Z)
                    local platTargetPos = charTargetPos - Vector3.new(0, 3.5, 0)

                    local tweenInfo = TweenInfo.new(TWEEN_SPEED, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                    
                    local charTween = TweenService:Create(rootPart, tweenInfo, {CFrame = CFrame.new(charTargetPos)})
                    local platTween = TweenService:Create(platform, tweenInfo, {CFrame = CFrame.new(platTargetPos)})
                    
                    charTween:Play()
                    platTween:Play()
                    charTween.Completed:Wait()
                end

                while TICKETFARMTWEEN do
                    local character = player.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    
                    if rootPart then
                        -- Ищем тикет
                        local ticket = nil
                        for _, child in ipairs(ticketsFolder:GetChildren()) do
                            if child.Name == "Visual" then
                                ticket = child
                                break
                            end
                        end

                        if ticket then
                            -- Если мы еще НЕ летим к этому тикету
                            if currentTarget ~= ticket then
                                currentTarget = ticket
                                
                                -- Ждем от 2 до 3 секунд перед началом движения
                                task.wait(math.random(2, 3))
                                
                                -- Если скрипт всё еще включен и тикет не исчез
                                if TICKETFARMTWEEN and ticket.Parent then
                                    smoothMove(ticket:GetPivot().Position)
                                end
                            end
                        else
                            -- Если тикетов нет, проверяем, стоим ли мы уже под спавном
                            if currentTarget ~= "Spawn" then
                                currentTarget = "Spawn"
                                smoothMove(itemSpawns:GetPivot().Position)
                            end
                        end
                    end
                    task.wait(0.5) -- Спокойная проверка раз в полсекунды
                end

                if platform then
                    platform.CFrame = CFrame.new(0, -5000, 0)
                    currentTarget = nil
                end
            end)
        end
    end    
})
 

Tab:AddToggle({
    Name = "XP FARM",
    Default = false,
    Callback = function(Value)
        XPFARMFOREVENT = Value
        
        if XPFARMFOREVENT then
            task.spawn(function()
                local Players = game:GetService("Players")
                local TextChatService = game:GetService("TextChatService")
                local player = Players.LocalPlayer
                local isProcessing = false
                local rewardCount = 0

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

                local function runCommands(rewardsGui)
                    isProcessing = true 
                    rewardCount = rewardCount + 1
                    
                    if rewardsGui then rewardsGui.Visible = false end 
                    
                    if rewardCount == 2 then
                        task.wait(8)
                        sendMessage("!specialround Plushie Hell")
                        task.wait(1)
                        sendMessage("!Timer 1")
                    else
                        task.wait(1)
                        sendMessage("!map Maze")
                        task.wait(17)
                        sendMessage("!specialround Plushie Hell")
                        task.wait(1)
                        sendMessage("!Timer 1")
                    end
                    
                    isProcessing = false
                end

                while XPFARMFOREVENT do
                    local rewardsGui = getRewardsGui()
                    
                    if rewardsGui and rewardsGui.Visible == true and not isProcessing then
                        runCommands(rewardsGui)
                    end
                    
                    task.wait(0.5)
                end
                
                print("Autofarm Stopped")
            end)
        else
            print("Autofarm turned off")
        end
    end     
})

Tab:AddButton({
	Name = "MAZE",
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

sendMessage("!specialround Plushie Hell")
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

Tab:AddToggle({
    Name = "Disable 3D Rendering (CPU Saver)",
    Default = false,
    Callback = function(Value)
        if Value then
            game:GetService("RunService"):Set3dRenderingEnabled(false)
        else
            game:GetService("RunService"):Set3dRenderingEnabled(true)
        end
    end    
})

Tab:AddToggle({
    Name = "Fps Cap (POWER Saver)",
    Default = false,
    Callback = function(Value)
        if Value then
            game:GetService("RunService"):Set3dRenderingEnabled(false)
            
            if setfpscap then
                setfpscap(10) 
            end
            
            print("on")
        else
            game:GetService("RunService"):Set3dRenderingEnabled(true)
            if setfpscap then
                setfpscap(60)
            end
            print("off")
        end
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
		XPFARMPV = Value
		
		if XPFARMPV then
			task.spawn(function()
				local Players = game:GetService("Players")
				local TextChatService = game:GetService("TextChatService")
				local player = Players.LocalPlayer
				
				local IMAGE_ID = "rbxassetid://126150774709719"
				local SAFE_POSITION = Vector3.new(0, 500, 0)
				local isProcessing = false
				local rewardCount = 0

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

				while XPFARMPV do
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
						rewardCount = rewardCount + 1
						
						print("Награда #" .. rewardCount .. " получена")
						rewardsGui.Visible = false
						
						if rewardCount == 2 then
							task.wait(8)
							sendMessage("!specialround Plushie Hell")
							task.wait(1)
							sendMessage("!Timer 1")
						else
							task.wait(1)
							sendMessage("!map Maze")
							task.wait(17)
							sendMessage("!specialround Plushie Hell")
							task.wait(1)
							sendMessage("!Timer 1")
						end
						
						isProcessing = false
					end

					task.wait(0.5)
				end

				if platform then platform:Destroy() end
				print("Autofarm & SafeZone: OFF")
			end)
		end
	end    
})

Tab:AddButton({
	Name = "SET MAZE",
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

sendMessage("!specialround Plushie Hell")
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
        XPFARMPB = Value

        if XPFARMPB then
            task.spawn(function()
                local Players = game:GetService("Players")
                local player = Players.LocalPlayer

                local gameFolder = workspace:WaitForChild("Game")
                local itemSpawns = gameFolder:WaitForChild("Map"):WaitForChild("ItemSpawns")

                local platform = workspace:FindFirstChild("SafeZonePlatform")
                if not platform then
                    platform = Instance.new("Part")
                    platform.Name = "SafeZonePlatform"
                    platform.Size = Vector3.new(20, 1, 20)
                    platform.Anchored = true
                    platform.CanCollide = true
                    platform.Transparency = 0.5 
                    platform.BrickColor = BrickColor.new("Bright blue")
                    platform.Parent = workspace
                end

                local function getSafeZoneCFrame()
                    return itemSpawns:GetPivot() * CFrame.new(0, 500, 0)
                end

                while XPFARMPB do 
                    local character = player.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    local humanoid = character and character:FindFirstChild("Humanoid")
                    
                    local safeCFrame = getSafeZoneCFrame()
                    
                    platform.CFrame = safeCFrame * CFrame.new(0, -3.5, 0)

                    if rootPart and humanoid and humanoid.Health > 0 then
                        if (rootPart.Position - safeCFrame.Position).Magnitude > 5 then
                            rootPart.CFrame = safeCFrame
                        end
                    end
                    task.wait(0.5)
                end

                if platform then 
                    platform.CFrame = CFrame.new(0, -1000, 0) 
                end 
            end)
        end
    end    
})

local Section = Tab:AddSection({
	Name = "FUN"
})

Tab:AddButton({
	Name = "TP OUTSIDE MAP x1",
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

Tab:AddToggle({
    Name = "Disable 3D Rendering (CPU Saver)",
    Default = false,
    Callback = function(Value)
        if Value then
            game:GetService("RunService"):Set3dRenderingEnabled(false)
        else
            game:GetService("RunService"):Set3dRenderingEnabled(true)
        end
    end    
})

Tab:AddToggle({
    Name = "Fps Cap (POWER Saver",
    Default = false,
    Callback = function(Value)
        if Value then
            game:GetService("RunService"):Set3dRenderingEnabled(false)
            
            if setfpscap then
                setfpscap(10) 
            end
            
            print("on")
        else
            game:GetService("RunService"):Set3dRenderingEnabled(true)
            if setfpscap then
                setfpscap(60)
            end
            print("off")
        end
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
