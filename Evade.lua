local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "MeowlSploit", HidePremium = false, SaveConfig = true, ConfigFolder = "EvadeMeowlSploit"})


local scripts = {
    'CustomCharacter/CustomCharacter.lua',
}

local baseUrl = 'https://raw.githubusercontent.com/Fishka132312/coolgui/refs/heads/main/Things/'

task.spawn(function()
    for i, scriptName in ipairs(scripts) do
        local fullUrl = baseUrl .. scriptName
        
        local success, err = pcall(function()
            local code = game:HttpGet(fullUrl)
            if code then
                loadstring(code)()
            else
                warn("Не удалось получить код для: " .. scriptName)
            end
        end)
        
        if not success then
            warn("Ошибка при загрузке " .. scriptName .. ": " .. tostring(err))
        end
        
        task.wait(0.7) 
    end
end)

local Tab = Window:MakeTab({
	Name = "Event farm 💌",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
	Name = "Ticket Farm"
})

Tab:AddToggle({
    Name = "Ticket Farm 1 (TP)",
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

                local platform = workspace:FindFirstChild("SafeZonePlatform1") or Instance.new("Part")
                platform.Name = "SafeZonePlatform1"
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
    Name = "Ticket Farm 2 (TP)",
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

                local platform = workspace:FindFirstChild("SafeZonePlatform2") or Instance.new("Part")
                platform.Name = "SafeZonePlatform2"
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
	Name = "Ticket Farm 3 (TWEEN)",
	Default = false,
	Callback = function(Value)
		_G.TicketFarmEnabled = Value
		
		if not Value then
			if _G.SafeZonePart then
				_G.SafeZonePart:Destroy()
				_G.SafeZonePart = nil
			end
			return
		end

		task.spawn(function()
			local TweenService = game:GetService("TweenService")
			local player = game:GetService("Players").LocalPlayer
			
			local function smoothMove(targetCFrame)
				local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					local tween = TweenService:Create(hrp, TweenInfo.new(1, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
					tween:Play()
					return tween
				end
			end

			if not _G.SafeZonePart then
				_G.SafeZonePart = Instance.new("Part")
				_G.SafeZonePart.Size = Vector3.new(12, 1, 12)
				_G.SafeZonePart.Anchored = true
				_G.SafeZonePart.Transparency = 0.5
				_G.SafeZonePart.BrickColor = BrickColor.new("Bright green")
				_G.SafeZonePart.Parent = workspace
			end

			while _G.TicketFarmEnabled do
				local char = player.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				local hum = char and char:FindFirstChildOfClass("Humanoid")

				if hrp and hum and hum.Health > 0 then
					local gameFolder = workspace:WaitForChild("Game")
					local itemSpawns = gameFolder:WaitForChild("Map"):WaitForChild("ItemSpawns")
					local ticketsFolder = gameFolder:WaitForChild("Effects"):WaitForChild("Tickets")

					local targetTicket = ticketsFolder:FindFirstChildWhichIsA("BasePart") or ticketsFolder:FindFirstChildOfClass("Model")

					if targetTicket then
						local ticketPos = targetTicket:GetPivot().Position
						local targetPos = ticketPos + Vector3.new(0, -10, 0)

						_G.SafeZonePart.CFrame = CFrame.new(targetPos - Vector3.new(0, 1.5, 0))
						local tw = smoothMove(CFrame.new(targetPos))
						if tw then tw.Completed:Wait() end

						task.wait(math.random(2, 4))
					else
						local closestSpawn = itemSpawns:FindFirstChildWhichIsA("BasePart")
						if closestSpawn then
							local spawnPos = closestSpawn.Position
							local waitPos = spawnPos + Vector3.new(0, -10, 0)

							if (hrp.Position - waitPos).Magnitude > 5 then
								_G.SafeZonePart.CFrame = CFrame.new(waitPos - Vector3.new(0, 1.5, 0))
								local tw = smoothMove(CFrame.new(waitPos))
								if tw then tw.Completed:Wait() end
							end
						end
						task.wait(0.5)
					end
				else
					task.wait(2)
				end
				task.wait(0.1)
			end
		end)
	end    
})


local Section = Tab:AddSection({
	Name = "XP Farm"
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
                
                local isProcessing = false
                local rewardCount = 0

                local function getTimerText()
                    local pg = player:FindFirstChild("PlayerGui")
                    local timerObj = pg and pg:FindFirstChild("Shared") 
                        and pg.Shared:FindFirstChild("HUD")
                        and pg.Shared.HUD:FindFirstChild("Overlay")
                        and pg.Shared.HUD.Overlay:FindFirstChild("Default")
                        and pg.Shared.HUD.Overlay.Default:FindFirstChild("RoundOverlay")
                        and pg.Shared.HUD.Overlay.Default.RoundOverlay:FindFirstChild("Round")
                        and pg.Shared.HUD.Overlay.Default.RoundOverlay.Round:FindFirstChild("RoundTimer")
                        and pg.Shared.HUD.Overlay.Default.RoundOverlay.Round.RoundTimer:FindFirstChild("Timer")
                    
                    return timerObj and timerObj.Text or ""
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

                print("Autofarm: ON. Ожидание GUI наград...")

                while XPFARMPV do
                    local pg = player:FindFirstChild("PlayerGui")
                    local rewardsGui = pg and pg:FindFirstChild("Global") and pg.Global:FindFirstChild("Rewards")

                    if rewardsGui and rewardsGui.Visible == true and not isProcessing then
                        isProcessing = true
                        rewardCount = rewardCount + 1
                        rewardsGui.Visible = false
                        print("Награда получена! Счетчик: " .. rewardCount)

                        if rewardCount >= 2 then
                            task.wait(2)
                            sendMessage("!map Maze")
                            rewardCount = 0 
                        else
                            print("waiting	")
                        end

                        while XPFARMPV do
                            local currentTimer = getTimerText()
                            if currentTimer == "0:29" then
                                break 
                            end
                            task.wait(0.1)
                        end

                        if XPFARMPV then
                            sendMessage("!specialround Plushie Hell")
                            task.wait(1)
                            sendMessage("!Timer 1")
                            print("Раунд настроен на 0:29")
                        end

                        isProcessing = false
                    end

                    task.wait(0.5)
                end
                
                print("Autofarm: OFF")
            end)
        end
    end     
})

local Section = Tab:AddSection({
	Name = "Things"
})

Tab:AddButton({
    Name = "MAZE",
    Callback = function()
        local Players = game:GetService("Players")
        local TextChatService = game:GetService("TextChatService")
        local player = Players.LocalPlayer

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

        local function getTimerText()
            local pg = player:FindFirstChild("PlayerGui")
            local timerObj = pg and pg:FindFirstChild("Shared") 
                and pg.Shared:FindFirstChild("HUD")
                and pg.Shared.HUD:FindFirstChild("Overlay")
                and pg.Shared.HUD.Overlay:FindFirstChild("Default")
                and pg.Shared.HUD.Overlay.Default:FindFirstChild("RoundOverlay")
                and pg.Shared.HUD.Overlay.Default.RoundOverlay:FindFirstChild("Round")
                and pg.Shared.HUD.Overlay.Default.RoundOverlay.Round:FindFirstChild("RoundTimer")
                and pg.Shared.HUD.Overlay.Default.RoundOverlay.Round.RoundTimer:FindFirstChild("Timer")
            
            return timerObj and timerObj.Text or ""
        end

        task.spawn(function()
            sendMessage("!map Maze")

            while true do
                local currentTimer = getTimerText()
                if currentTimer == "0:29" then
                    break
                end
                task.wait(0.1)
            end

            sendMessage("!specialround Plushie Hell")
            task.wait(1)
            sendMessage("!Timer 1")
        end)
        
    end    
})

Tab:AddToggle({
    Name = "Fps Cap (POWER Saver)",
    Default = false,
    Callback = function(Value)
        if Value then
            setfpscap(10)
        else
            setfpscap(60)
        end
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

local Section = Tab:AddSection({
	Name = "IMPORTANT"
})

Tab:AddToggle({
    Name = "Disable 3D Rendering IMPORTANT",
    Default = false,
    Callback = function(Value)
        if Value then
            game:GetService("RunService"):Set3dRenderingEnabled(false)
        else
            game:GetService("RunService"):Set3dRenderingEnabled(true)
        end
    end    
})

Tab:AddButton({
	Name = "Ghost Mode👻",
	Callback = function()
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer

local function notify(msg)
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if channel then channel:DisplaySystemMessage("[SECURITY]: " .. msg) end
    else
        game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
            Text = "[SECURITY]: " .. msg,
            Color = Color3.fromRGB(255, 170, 0),
            Font = Enum.Font.SourceSansBold
        })
    end
end

notify("The protection system is active.")

local function performSecurityCheck()
    local s, isScreenshotEnabled = pcall(function()
        return settings():GetFFlag("ReportAnythingScreenshot")
    end)
    
    if s and isScreenshotEnabled == true then
        LocalPlayer:Kick("\n🚨 THE SCREENSHOT SYSTEM IS ACTIVATED\nRoblox has started monitoring the screen. The farm is stopped for safety.")
        return true
    end

    local s2, isRAEnabled = pcall(function()
        return settings():GetFFlag("ForceReportAnythingAnnotationEnabled")
    end)
    
    if s2 and isRAEnabled == true then
        LocalPlayer:Kick("\n🚨 IXP MONITORING IS ENABLED\nDeep environment check (Report Anything) is detected.")
        return true
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local success, rank = pcall(function() return player:GetRankInGroup(game.CreatorId) end)
            
            if (success and rank >= 200) or player.UserId < 0 then
                LocalPlayer:Kick("\n🚨 ADMIN DETECTED: " .. player.Name .. "\nThe farm was interrupted to avoid manual reporting.")
                return true
            end
        end
    end

    local RobloxGui = game:GetService("CoreGui"):FindFirstChild("RobloxGui")
    if RobloxGui then
        local trustAndSafety = RobloxGui:FindFirstChild("TrustAndSafety")
        if trustAndSafety and trustAndSafety.Enabled then
             LocalPlayer:Kick("\n🚨 THE SECURITY WINDOW IS OPEN\nThe reporting system was initiated from the outside.")
             return true
        end
    end

    return false
end

task.spawn(function()
    while true do
        if performSecurityCheck() then break end
        task.wait(3)
    end
end)

Players.PlayerAdded:Connect(function(player)
    task.wait(1)
    performSecurityCheck()
end)
  	end    
})

Tab:AddButton({
	Name = "Shutdown Game if dev join IMPORTANT",
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
    Name = "XP FARM PV",
    Default = false,
    Callback = function(Value)
        XPFARMPV2 = Value
        
        if XPFARMPV2 then
            task.spawn(function()
                local Players = game:GetService("Players")
                local TextChatService = game:GetService("TextChatService")
                local player = Players.LocalPlayer
                
                local isProcessing = false
                local rewardCount = 0

                local gameFolder = workspace:WaitForChild("Game")
                local itemSpawns = gameFolder:WaitForChild("Map"):WaitForChild("ItemSpawns")
                
                local safePos = itemSpawns.WorldPivot.Position + Vector3.new(-50, 5, 0) 

                local platform = workspace:FindFirstChild("FarmSafeZone")
                if not platform then
                    platform = Instance.new("Part")
                    platform.Name = "FarmSafeZone"
                    platform.Size = Vector3.new(15, 1, 15)
                    platform.Position = safePos - Vector3.new(0, 3, 0)
                    platform.Anchored = true
                    platform.BrickColor = BrickColor.new("Bright blue")
                    platform.Transparency = 0.5
                    platform.Parent = workspace
                end

                local function getTimerText()
                    local pg = player:FindFirstChild("PlayerGui")
                    local timerObj = pg and pg:FindFirstChild("Shared") 
                        and pg.Shared:FindFirstChild("HUD")
                        and pg.Shared.HUD:FindFirstChild("Overlay")
                        and pg.Shared.HUD.Overlay:FindFirstChild("Default")
                        and pg.Shared.HUD.Overlay.Default:FindFirstChild("RoundOverlay")
                        and pg.Shared.HUD.Overlay.Default.RoundOverlay:FindFirstChild("Round")
                        and pg.Shared.HUD.Overlay.Default.RoundOverlay.Round:FindFirstChild("RoundTimer")
                        and pg.Shared.HUD.Overlay.Default.RoundOverlay.Round.RoundTimer:FindFirstChild("Timer")
                    
                    return timerObj and timerObj.Text or ""
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

                print("Autofarm: ON. Сейф-зона создана.")

                while XPFARMPV2 do
                    local character = player.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        if (rootPart.Position - safePos).Magnitude > 5 then
                            rootPart.CFrame = CFrame.new(safePos)
                        end
                    end

                    local pg = player:FindFirstChild("PlayerGui")
                    local rewardsGui = pg and pg:FindFirstChild("Global") and pg.Global:FindFirstChild("Rewards")

                    if rewardsGui and rewardsGui.Visible == true and not isProcessing then
                        isProcessing = true
                        rewardCount = rewardCount + 1
                        rewardsGui.Visible = false
                        print("Награда получена! Счетчик: " .. rewardCount)

                        if rewardCount >= 2 then
                            task.wait(1)
                            sendMessage("!map Maze")
                            rewardCount = 0 
                        end

                        while XPFARMPV2 do
                            local currentTimer = getTimerText()
                            if currentTimer == "0:29" then
                                break 
                            end
                            task.wait(0.1)
                        end

                        if XPFARMPV2 then
                            sendMessage("!specialround Plushie Hell")
                            task.wait(1)
                            sendMessage("!Timer 1")
                        end

                        isProcessing = false
                    end

                    task.wait(0.1)
                end
                
                if platform then platform:Destroy() end
                print("Autofarm: OFF")
            end)
        end
    end     
})


Tab:AddButton({
    Name = "MAZE",
    Callback = function()
        local Players = game:GetService("Players")
        local TextChatService = game:GetService("TextChatService")
        local player = Players.LocalPlayer

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

        local function getTimerText()
            local pg = player:FindFirstChild("PlayerGui")
            local timerObj = pg and pg:FindFirstChild("Shared") 
                and pg.Shared:FindFirstChild("HUD")
                and pg.Shared.HUD:FindFirstChild("Overlay")
                and pg.Shared.HUD.Overlay:FindFirstChild("Default")
                and pg.Shared.HUD.Overlay.Default:FindFirstChild("RoundOverlay")
                and pg.Shared.HUD.Overlay.Default.RoundOverlay:FindFirstChild("Round")
                and pg.Shared.HUD.Overlay.Default.RoundOverlay.Round:FindFirstChild("RoundTimer")
                and pg.Shared.HUD.Overlay.Default.RoundOverlay.Round.RoundTimer:FindFirstChild("Timer")
            
            return timerObj and timerObj.Text or ""
        end

        task.spawn(function()
            sendMessage("!map Maze")

            while true do
                local currentTimer = getTimerText()
                if currentTimer == "0:29" then
                    break
                end
                task.wait(0.1)
            end

            sendMessage("!specialround Plushie Hell")
            task.wait(1)
            sendMessage("!Timer 1")
            print("MAZE Setup Complete")
        end)
        
    end    
})

local Section = Tab:AddSection({
	Name = "PUBLIC SERVER FARM"
})

Tab:AddToggle({
    Name = "XP FARM PB",
    Default = false,
    Callback = function(Value)
        XPFARMPV2 = Value
        
        if XPFARMPV2 then
            task.spawn(function()
                local Players = game:GetService("Players")
                local player = Players.LocalPlayer
                
                local gameFolder = workspace:WaitForChild("Game")
                local itemSpawns = gameFolder:WaitForChild("Map"):WaitForChild("ItemSpawns")
                
                local safePos = itemSpawns.WorldPivot.Position + Vector3.new(-500, 500, 0) 

                local platform = workspace:FindFirstChild("FarmSafeZonePublic")
                if not platform then
                    platform = Instance.new("Part")
                    platform.Name = "FarmSafeZonePublic"
                    platform.Size = Vector3.new(15, 1, 15)
                    platform.Position = safePos - Vector3.new(0, 3, 0)
                    platform.Anchored = true
                    platform.BrickColor = BrickColor.new("Bright blue")
                    platform.Transparency = 0.5
                    platform.Parent = workspace
                end

                print("Autofarm: ON. Сейф-зона активна.")

                while XPFARMPV2 do
                    local character = player.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        if (rootPart.Position - safePos).Magnitude > 5 then
                            rootPart.CFrame = CFrame.new(safePos)
                        end
                    end

                    local pg = player:FindFirstChild("PlayerGui")
                    local rewardsGui = pg and pg:FindFirstChild("Global") and pg.Global:FindFirstChild("Rewards")

                    if rewardsGui and rewardsGui.Visible == true then
                        rewardsGui.Visible = false
                        print("GUI наград скрыто")
                    end

                    task.wait(0.1)
                end
                
                if platform then platform:Destroy() end
                print("Autofarm: OFF")
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

--------------------freecosmetics-----------------


local Tab = Window:MakeTab({
	Name = "Free Cosmetics/Emates",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local cosmeticsFolder = ReplicatedStorage:WaitForChild("Items"):WaitForChild("Cosmetics")
local player = Players.LocalPlayer
local folderNameInChar = "VisualCosmetic_Attached"

_G.SelectedCosmetic = "" 
_G.EquipCosmetic = false 

-- Список стандартных имен для жесткой сцепки
local bodyPartsNames = {
    "Head", "Torso", "UpperTorso", "LowerTorso", "HumanoidRootPart",
    "Left Arm", "Right Arm", "Left Leg", "Right Leg",
    "LeftUpperArm", "LeftLowerArm", "LeftHand",
    "RightUpperArm", "RightLowerArm", "RightHand",
    "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
    "RightUpperLeg", "RightLowerLeg", "RightFoot"
}

local function clearVisualSkin()
    local char = player.Character
    if char then
        local oldFolder = char:FindFirstChild(folderNameInChar)
        if oldFolder then oldFolder:Destroy() end
    end
end

local function applyVisualSkin()
    clearVisualSkin()
    
    if not _G.EquipCosmetic or _G.SelectedCosmetic == "" then return end
    
    local source = cosmeticsFolder:FindFirstChild(_G.SelectedCosmetic)
    local char = player.Character
    if not (source and char) then return end

    local visualFolder = Instance.new("Model")
    visualFolder.Name = folderNameInChar
    visualFolder.Parent = char

    local function processFolder(folder)
        for _, piece in ipairs(folder:GetChildren()) do
            -- 1. ЕСЛИ ЭТО БАЗОВАЯ ЧАСТЬ ТЕЛА
            if piece:IsA("BasePart") and table.find(bodyPartsNames, piece.Name) then
                local targetPart = char:FindFirstChild(piece.Name)
                if targetPart then
                    local clone = piece:Clone()
                    clone.CanCollide = false
                    clone.CanTouch = false
                    clone.CanQuery = false
                    clone.Massless = true
                    clone.Transparency = 1 -- Коробка-основа всегда невидима
                    
                    -- Умная очистка скриптов (не трогаем те, что отвечают за вращение/spins)
                    for _, extra in ipairs(clone:GetDescendants()) do
                        if extra:IsA("Script") or extra:IsA("LocalScript") then
                            local isAnimScript = false
                            local p = extra.Parent
                            while p and p ~= clone do
                                if p.Name:lower():find("spin") or p.Name:lower():find("anim") then
                                    isAnimScript = true
                                    break
                                end
                                p = p.Parent
                            end
                            if not isAnimScript then extra:Destroy() end
                        end
                    end

                    clone.Parent = visualFolder
                    clone.CFrame = targetPart.CFrame
                    
                    -- Жесткая сварка для основных частей
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = clone
                    weld.Part1 = targetPart
                    weld.Parent = clone
                end
            
            -- 2. ЕСЛИ ЭТО ДЕКОР (летающие штуки, папки с эффектами)
            else
                local clone = piece:Clone()
                clone.Parent = visualFolder
                
                -- Если это деталь, которая должна летать рядом
                if clone:IsA("BasePart") then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        -- Используем обычный Weld, чтобы скрипты вращения могли работать
                        local weld = Instance.new("Weld")
                        weld.Part0 = root
                        weld.Part1 = clone
                        weld.C0 = root.CFrame:Inverse() * clone.CFrame
                        weld.Parent = clone
                    end
                end
            end
        end
    end

    -- Проходим по всем папкам Character...
    for _, child in ipairs(source:GetChildren()) do
        if (child:IsA("Folder") or child:IsA("Model")) and string.sub(child.Name, 1, 9) == "Character" then
            processFolder(child)
        end
    end
end

-- Авто-надевание при респавне
player.CharacterAdded:Connect(function(newChar)
    newChar:WaitForChild("Humanoid")
    task.wait(0.6) -- Чуть больше задержка для прогрузки анимаций
    if _G.EquipCosmetic then
        applyVisualSkin()
    end
end)

-- Проверка наличия контента для списка
local function hasVisualParts(item)
    for _, child in ipairs(item:GetChildren()) do
        if string.sub(child.Name, 1, 9) == "Character" then
            return true
        end
    end
    return false
end

local cosmeticNames = {}
for _, item in ipairs(cosmeticsFolder:GetChildren()) do
    if hasVisualParts(item) then table.insert(cosmeticNames, item.Name) end
end

-- UI
Tab:AddDropdown({
    Name = "Choose Cosmetics",
    Default = "",
    Options = cosmeticNames,
    Callback = function(Value)
        _G.SelectedCosmetic = Value
        if _G.EquipCosmetic then applyVisualSkin() end
    end    
})

Tab:AddToggle({
    Name = "Turn on cosmetics",
    Default = false,
    Callback = function(Value)
        _G.EquipCosmetic = Value
        if _G.EquipCosmetic then 
            applyVisualSkin() 
        else 
            clearVisualSkin() 
        end
    end    
})

Tab:AddDropdown({
	Name = "Choose Carry Cosmetics",
	Default = "1",
	Options = {"1", "2"},
	Callback = function(Value)
		print(Value)
	end    
})

Tab:AddToggle({
	Name = "Turn On Carry Cosmetics",
	Default = false,
	Callback = function(Value)
		print(Value)
	end    
})

Tab:AddTextbox({
    Name = "Type Emote",
    Default = "",
    TextDisappear = true,
    Callback = function(Value)
        -- 1. Очищаем ввод: убираем лишние пробелы в начале/конце и переводим в нижний регистр для сравнения
        local targetName = Value:match("^%s*(.-)%s*$"):lower()
        if targetName == "" then return end

        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        local emotesRoot = game:GetService("ReplicatedStorage").Items.Emotes
        local emoteFolder = nil

        -- 2. Ищем папку, игнорируя регистр букв
        for _, folder in pairs(emotesRoot:GetChildren()) do
            if folder.Name:lower() == targetName then
                emoteFolder = folder
                break
            end
        end

        if emoteFolder then
            local animObject = nil
            
            -- Проверяем наличие подпапки Animations (как в ValentineComputer)
            local animDir = emoteFolder:FindFirstChild("Animations")
            local searchIn = animDir or emoteFolder

            -- 3. Выбираем анимацию в зависимости от типа Rig (R15 или R6)
            if humanoid.RigType == Enum.HumanoidRigType.R15 then
                animObject = searchIn:FindFirstChild("Animation") or searchIn:FindFirstChild("R15")
            else
                animObject = searchIn:FindFirstChild("AnimationClassic") or searchIn:FindFirstChild("R6")
            end

            if animObject and animObject:IsA("Animation") then
                -- Останавливаем текущие анимации
                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                    track:Stop(0.1)
                end

                -- 4. Загружаем и запускаем
                local track = humanoid:LoadAnimation(animObject)
                track.Priority = Enum.AnimationPriority.Action -- Приоритет выше обычных движений
                track.Looped = true
                track:Play()
                
                print("Успешно запущено: " .. emoteFolder.Name)
            else
                warn("Объект Animation не найден в папке '" .. emoteFolder.Name .. "'")
            end
        else
            warn("Эмоция '" .. Value .. "' не найдена. Проверь правильность названия.")
        end
    end     
})

Tab:AddButton({
	Name = "Stop Emote",
	Callback = function()
      		local character = game.Players.LocalPlayer.Character
if character then
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        -- Находим все анимации, которые проигрываются в данный момент
        local activeTracks = humanoid:GetPlayingAnimationTracks()
        
        for _, t in pairs(activeTracks) do
            -- Можно остановить вообще всё
            t:Stop()
            
            -- Или, если хочешь остановить только свою (по ID):
            -- if t.Animation.AnimationId == "rbxassetid://ТВОЙ_ID" then t:Stop() end
        end
        print("Все локальные анимации остановлены!")
    end
end
  	end    
})
--------------------------------Shaders-----------------------------

local Tab = Window:MakeTab({
	Name = "Shaders",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
	Name = "Shaders"
})

Tab:AddButton({
	Name = "Meowl Shaders",
	Callback = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Fishka132312/coolgui/refs/heads/main/Things/Shaders/MeowlShaders.lua'))()  
  	end    
})

Tab:AddButton({
	Name = "Shaders",
	Callback = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Fishka132312/coolgui/refs/heads/main/Things/shaders.lua'))()  
  	end    
})

Tab:AddButton({
	Name = "Cool Thing",
	Callback = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Fishka132312/coolgui/refs/heads/main/Things/coolthing.lua'))()  
  	end    
})

--------------------------------MISC-----------------------------
local Tab = Window:MakeTab({
	Name = "Misc",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
	Name = "Tools"
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
	Name = "Infinite Yield",
	Callback = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Fishka132312/ignore-it/refs/heads/main/infiniteyield'))()
  	end    
})

local Section = Tab:AddSection({
	Name = "Fps Boost"
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

Tab:AddToggle({
    Name = "Disable 3D Rendering",
    Default = false,
    Callback = function(Value)
        if Value then
            game:GetService("RunService"):Set3dRenderingEnabled(false)
        else
            game:GetService("RunService"):Set3dRenderingEnabled(true)
        end
    end    
})

local Section = Tab:AddSection({
	Name = "Avoid ban"
})

Tab:AddButton({
	Name = "Ghost Mode👻",
	Callback = function()
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer

local function notify(msg)
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if channel then channel:DisplaySystemMessage("[SECURITY]: " .. msg) end
    else
        game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
            Text = "[SECURITY]: " .. msg,
            Color = Color3.fromRGB(255, 170, 0),
            Font = Enum.Font.SourceSansBold
        })
    end
end

notify("The protection system is active.")

local function performSecurityCheck()
    local s, isScreenshotEnabled = pcall(function()
        return settings():GetFFlag("ReportAnythingScreenshot")
    end)
    
    if s and isScreenshotEnabled == true then
        LocalPlayer:Kick("\n🚨 THE SCREENSHOT SYSTEM IS ACTIVATED\nRoblox has started monitoring the screen. The farm is stopped for safety.")
        return true
    end

    local s2, isRAEnabled = pcall(function()
        return settings():GetFFlag("ForceReportAnythingAnnotationEnabled")
    end)
    
    if s2 and isRAEnabled == true then
        LocalPlayer:Kick("\n🚨 IXP MONITORING IS ENABLED\nDeep environment check (Report Anything) is detected.")
        return true
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local success, rank = pcall(function() return player:GetRankInGroup(game.CreatorId) end)
            
            if (success and rank >= 200) or player.UserId < 0 then
                LocalPlayer:Kick("\n🚨 ADMIN DETECTED: " .. player.Name .. "\nThe farm was interrupted to avoid manual reporting.")
                return true
            end
        end
    end

    local RobloxGui = game:GetService("CoreGui"):FindFirstChild("RobloxGui")
    if RobloxGui then
        local trustAndSafety = RobloxGui:FindFirstChild("TrustAndSafety")
        if trustAndSafety and trustAndSafety.Enabled then
             LocalPlayer:Kick("\n🚨 THE SECURITY WINDOW IS OPEN\nThe reporting system was initiated from the outside.")
             return true
        end
    end

    return false
end

task.spawn(function()
    while true do
        if performSecurityCheck() then break end
        task.wait(3)
    end
end)

Players.PlayerAdded:Connect(function(player)
    task.wait(1)
    performSecurityCheck()
end)
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

local Section = Tab:AddSection({
	Name = "Other"
})


Tab:AddToggle({
    Name = "Fps Cap (POWER Saver)",
    Default = false,
    Callback = function(Value)
        if Value then
            setfpscap(10)
        else
            setfpscap(60)
        end
    end    
})

OrionLib:Init()
