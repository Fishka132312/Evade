local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Fishka132312/MeowlGui/refs/heads/main/source/library.lua"))()
local CheatName = "Violence District"

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local scripts = {
  '',
}

local baseUrl = 'https://raw.githubusercontent.com/Fishka132312/Evade/refs/heads/main/Thing/'

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
		Name = "Main",
		Icon = "7539983773",
		Category = MainCat
})

--PlayerInfo--
local MainSection = MainPage:Section({Name = "Show Player Info", Side = 1})


local SettingsCat = Window:Category("Settings")
local SettingsPage = Library:CreateSettingsPage(Window, KeybindList)
table.insert(SettingsCat.Elements, SettingsPage)
Window:Init()
