local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "🎄Evade🎄", HidePremium = false, SaveConfig = true, ConfigFolder = "🎄Evade🎄"})

local Tab = Window:MakeTab({
	Name = "Farm",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

Tab:AddButton({
	Name = "GBreads🍪",
	Callback = function()
    local RunService = game:GetService("RunService")
	print("123")
  	end    
})

Tab:AddButton({
	Name = "GBreads🍪 PV (SAFEST METHOD)",
	Callback = function()
    local RunService = game:GetService("RunService")
	local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- НАСТРОЙКИ
local BASE_SPEED = 16 
local REACH_DISTANCE = 3.5 -- Чуть увеличил, чтобы он точно подбирал, даже если стоит сбоку
local isRunning = true

print("--- Легитный 'Пробегающий' автосбор запущен ---")
print("Остановка: CTRL или C")

-- Остановка на CTRL и C
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
        task.wait(0.05)
        
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local ticketsFolder = getTicketsFolder()

        if not rootPart or not ticketsFolder or not isRunning then continue end

        -- Поиск ближайшего
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
            local targetPos = target:GetPivot().Position
            
            -- РАНДОМНОЕ СМЕЩЕНИЕ (от 2 до 5 студов)
            -- Выбираем случайный угол и случайную дистанцию
            local angle = math.rad(math.random(0, 360))
            local randomDist = math.random(2, 5) 
            local offset = Vector3.new(math.cos(angle) * randomDist, 0, math.sin(angle) * randomDist)
            
            local finalGoal = targetPos + offset
            
            local distance = (rootPart.Position - finalGoal).Magnitude
            local currentSpeed = BASE_SPEED + (math.random(-15, 15) / 10)
            local duration = distance / currentSpeed
            
            -- Используем Sine для мягкости
            local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
            
            -- Летим не в сам Visual, а в точку рядом
            local tween = TweenService:Create(rootPart, tweenInfo, {
                CFrame = CFrame.new(finalGoal, targetPos) -- Летит в бок, но смотрит на билет
            })
            
            tween:Play()
            
            local startWait = tick()
            repeat 
                task.wait(0.05)
                -- Условие подбора: если МЫ подошли к билету ближе чем на REACH_DISTANCE
            until not target.Parent or not isRunning or (tick() - startWait) > duration or (rootPart.Position - targetPos).Magnitude < REACH_DISTANCE
            
            tween:Cancel()
        end
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
	Name = "Fps boost",
	Callback = function()
    local RunService = game:GetService("RunService")
local lighting = game:GetService("Lighting")
local terrain = workspace:FindFirstChildOfClass("Terrain")

lighting.GlobalShadows = false
lighting.FogEnd = 9e9
settings().Rendering.QualityLevel = 1

for _, v in pairs(lighting:GetChildren()) do
    if v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") then
        v.Enabled = false
    end
end

for _, v in pairs(game:GetDescendants()) do
    if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
        v.Material = Enum.Material.SmoothPlastic
        v.Reflectance = 0
    elseif v:IsA("Decal") or v:IsA("Texture") then
        v:Destroy()
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v.Enabled = false
    end
end

if terrain then
    terrain.WaterWaveSize = 0
    terrain.WaterWaveSpeed = 0
    terrain.WaterReflectance = 0
    terrain.WaterTransparency = 0
end
  	end    
})


Tab:AddButton({
	Name = "Infinite Yield",
	Callback = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Fishka132312/ignore-it/refs/heads/main/infiniteyield'))()
  	end    
})
OrionLib:Init()

