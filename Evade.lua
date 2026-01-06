local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "🎄Evade🎄", HidePremium = false, SaveConfig = true, ConfigFolder = "🎄Evade🎄"})

local Tab = Window:MakeTab({
	Name = "Farm",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
	Name = "Rejoint to turn off"
})

Tab:AddButton({
	Name = "Ticket (Use at own risk)",
	Callback = function()
    local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Ссылки на объекты
local gameFolder = workspace:WaitForChild("Game")
local itemSpawns = gameFolder:WaitForChild("Map"):WaitForChild("ItemSpawns")
local ticketsFolder = gameFolder:WaitForChild("Effects"):WaitForChild("Tickets")
local playersFolder = gameFolder:WaitForChild("Players")

-- Настройки
local WAIT_AT_ITEM = 1.0
local DANGER_RADIUS = 20 
local ESCAPE_TIME = 2.0 

local isInSafeZone = false 

local platform = Instance.new("Part")
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
            local otherRoot = otherChar:FindFirstChild("HumanoidRootPart") or otherChar:FindFirstChild("Head")
            if otherRoot then
                local dist = (myPart.Position - otherRoot.Position).Magnitude
                if dist < DANGER_RADIUS then
                    return true
                end
            end
        end
    end
    return false
end

task.spawn(function()
    while true do
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        local safeCFrame = getSafeZoneCFrame()
        platform.CFrame = safeCFrame * CFrame.new(0, -3.5, 0)

        if rootPart then
            if isAnyoneNearby(rootPart) then
                rootPart.CFrame = safeCFrame
                isInSafeZone = true
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
                    isInSafeZone = false
                    rootPart.CFrame = target:GetPivot()
                    
                    local start = tick()
                    while tick() - start < WAIT_AT_ITEM do
                        if isAnyoneNearby(rootPart) then 
                            break 
                        end
                        task.wait(0.1)
                    end
                else
                    if not isInSafeZone then
                        rootPart.CFrame = safeCFrame
                        isInSafeZone = true
                    end
                end
            end
        end
        task.wait(0.1)
    end
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

--------------------------------MISC-----------------------------
local Tab = Window:MakeTab({
	Name = "Misc",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
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
        print("FPS Boost остановлен.")
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
	Name = "AntiAfk (PC Only)",
	Callback = function()
			local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local active = true
local waitTime = 30 -- Интервал между прыжками в секундах

-- Функция для имитации прыжка
local function performJump()
    if not active then return end
    
    -- Имитируем нажатие Пробела (Space)
    -- Это сработает и на ПК, и заставит персонажа прыгнуть на мобилках
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    
    print("Anti-AFK: Прыжок выполнен")
end

-- Отслеживание нажатия Ctrl для остановки
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
        active = false
        print("Anti-AFK: Выключен (нажат Ctrl)")
    end
end)

-- Основной цикл
task.spawn(function()
    print("Anti-AFK запущен. Нажми Ctrl, чтобы остановить.")
    while active do
        task.wait(waitTime)
        if active then
            performJump()
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


local Tab = Window:MakeTab({
	Name = "Test",
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


















