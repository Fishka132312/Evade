local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Fishka132312/MeowlGui/refs/heads/main/source/library.lua"))()
local CheatName = "Evade"

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local scripts = {
  'Autofarm/AutoFarmEvent.lua',
  'Autofarm/XPFARM.lua',
}

local baseUrl = 'https://raw.githubusercontent.com/Fishka132312/Evade/refs/heads/main/Things/'

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
    
    task.wait(0.5)
end

Library.Folders = {
    Directory = CheatName,
    Configs = CheatName .. "/Configs",
    Assets = CheatName .. "/Assets",
}

local Accent = Color3.fromRGB(255, 65, 85)
local Gradient = Color3.fromRGB(140, 10, 45)

Library.Theme.Accent = Accent
Library.Theme.AccentGradient = Gradient
Library:ChangeTheme("Accent", Accent)
Library:ChangeTheme("AccentGradient", Gradient)
local Window = Library:Window({
    Name = "Violence-District",
    SubName = "Meowl Sploit",
    Logo = "129442179713871"
})

-------------------------Main-----------------------

local MainCat = Window:Category("Main")
local MainPage = Window:Page({
		Name = "Auto Farm (Event)",
		Icon = "7539983773",
		Category = MainCat
})

--Summer Event--
local SummerEventSection = MainPage:Section({Name = "Summer Event", Side = 1})

local EventFarmToggle = SummerEventSection:Toggle({
    Name = "Bubbles Farm",
    Flag = "Ticket Farm",
    Default = false,
    Callback = function(Value)
        _G.FarmEvent = Value
    end
})

local EventFarmToggle = SummerEventSection:Toggle({
    Name = "PV FARM (USE IT ON PRIVATE SERVER)",
    Flag = "Ticket Farm",
    Default = false,
    Callback = function(Value)
        _G.XPFARMPV = Value
    end
})


local SettingsCat = Window:Category("Settings")
local SettingsPage = Library:CreateSettingsPage(Window, KeybindList)
table.insert(SettingsCat.Elements, SettingsPage)
Window:Init()
