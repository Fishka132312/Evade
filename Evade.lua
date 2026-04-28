local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "MeowlSploit", HidePremium = false, SaveConfig = true, ConfigFolder = "EvadeMeowlSploit"})


local scripts = {
    'Visuals/Esp.lua',
}

local baseUrl = 'https://raw.githubusercontent.com/Fishka132312/Evade/refs/heads/main/Thing/'

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
	Name = "No event rn"
})


----------------------------LVL---------------------------------
local Tab = Window:MakeTab({
	Name = "Visuals",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

Tab:AddToggle({
	Name = "Downed Players Esp",
	Default = false,
	Callback = function(Value)
		_G.EspDowned = Value
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
            if piece:IsA("BasePart") and table.find(bodyPartsNames, piece.Name) then
                local targetPart = char:FindFirstChild(piece.Name)
                if targetPart then
                    local clone = piece:Clone()
                    clone.CanCollide = false
                    clone.CanTouch = false
                    clone.CanQuery = false
                    clone.Massless = true
                    clone.Transparency = 1
                    
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
                    
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = clone
                    weld.Part1 = targetPart
                    weld.Parent = clone
                end
            
            else
                local clone = piece:Clone()
                clone.Parent = visualFolder
                
                if clone:IsA("BasePart") then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
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

    for _, child in ipairs(source:GetChildren()) do
        if (child:IsA("Folder") or child:IsA("Model")) and string.sub(child.Name, 1, 9) == "Character" then
            processFolder(child)
        end
    end
end

player.CharacterAdded:Connect(function(newChar)
    newChar:WaitForChild("Humanoid")
    task.wait(0.6)
    if _G.EquipCosmetic then
        applyVisualSkin()
    end
end)

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
        local targetName = Value:match("^%s*(.-)%s*$"):lower()
        if targetName == "" then return end

        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        local emotesRoot = game:GetService("ReplicatedStorage").Items.Emotes
        local emoteFolder = nil

        for _, folder in pairs(emotesRoot:GetChildren()) do
            if folder.Name:lower() == targetName then
                emoteFolder = folder
                break
            end
        end

        if emoteFolder then
            local animObject = nil
            
            local animDir = emoteFolder:FindFirstChild("Animations")
            local searchIn = animDir or emoteFolder

            if humanoid.RigType == Enum.HumanoidRigType.R15 then
                animObject = searchIn:FindFirstChild("Animation") or searchIn:FindFirstChild("R15")
            else
                animObject = searchIn:FindFirstChild("AnimationClassic") or searchIn:FindFirstChild("R6")
            end

            if animObject and animObject:IsA("Animation") then
                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                    track:Stop(0.1)
                end

                local track = humanoid:LoadAnimation(animObject)
                track.Priority = Enum.AnimationPriority.Action
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
        local activeTracks = humanoid:GetPlayingAnimationTracks()
        
        for _, t in pairs(activeTracks) do
            t:Stop()
            
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
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Fishka132312/coolgui/refs/heads/main/Things/Shaders/coolthing.lua'))()
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
