local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Fishka132312/MeowlGui/refs/heads/main/source/library.lua"))()
local CheatName = "Evade"

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local scripts = {
  'Autofarm/AutoFarmEvent.lua',
  'Autofarm/XPFARMPV.lua',
  'Main/AvoidNPC.lua',
  'Visual/EspNPC.lua',
  'Visual/TicketESP.lua',
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

local Accent = Color3.fromRGB(0, 162, 255)
local Gradient = Color3.fromRGB(0, 80, 180)

Library.Theme.Accent = Accent
Library.Theme.AccentGradient = Gradient
Library:ChangeTheme("Accent", Accent)
Library:ChangeTheme("AccentGradient", Gradient)
local Window = Library:Window({
    Name = "Evade [🌊]",
    SubName = "Meowl Sploit",
    Logo = "129442179713871"
})

-------------------------Event-----------------------

local EventCat = Window:Category("Main")
local EventPage = Window:Page({
		Name = "Auto Farm (Event)",
		Icon = "7539983773",
		Category = EventCat
})

--Summer Event--
local SummerEventSection = EventPage:Section({Name = "Summer Event", Side = 1})

local EventFarmToggle = SummerEventSection:Toggle({
    Name = "Bubbles Farm",
    Flag = "TicketFarm",
    Default = false,
    Callback = function(Value)
        _G.FarmEvent = Value
    end
})

local EventFarmToggle = SummerEventSection:Toggle({
    Name = "PV FARM (USE IT ON PRIVATE SERVER)",
    Flag = "PVXPFarm",
    Default = false,
    Callback = function(Value)
        _G.XPFARMPV = Value
    end
})

local ThingsToggle = SummerEventSection:Toggle({
    Name = "Esp Bubbles",
    Flag = "EspBubbles",
    Default = false,
    Callback = function(Value)
        _G.EspTickets = Value
    end
})

-------------------------Main-----------------------

local MainCat = Window:Category("Main")
local MainPage = Window:Page({
		Name = "Main",
		Icon = "7539983773",
		Category = MainCat
})

--Things--
local ThingsSection = MainPage:Section({Name = "Things", Side = 2})

local ThingsToggle = ThingsSection:Toggle({
    Name = "Evoid NPC",
    Flag = "EvoidNPC",
    Default = false,
    Callback = function(Value)
        _G.AvoidNPC = Value
    end
})

-------------------------Visual-----------------------

local VisualCat = Window:Category("Main")
local VisualPage = Window:Page({
		Name = "Visual",
		Icon = "7539983773",
		Category = VisualCat
})

--Visual--
local VisualSection = VisualPage:Section({Name = "Visual", Side = 1})

local ThingsToggle = VisualSection:Toggle({
    Name = "Esp NPC",
    Flag = "EspNPC",
    Default = false,
    Callback = function(Value)
        _G.EspNPC = Value
    end
})

local ThingsToggle = VisualSection:Toggle({
    Name = "Esp Downed",
    Flag = "DownedEsp",
    Default = false,
    Callback = function(Value)
        _G.EspDowned = Value
    end
})

--Things--
local VisualSection = VisualPage:Section({Name = "Things", Side = 2})

local ThingsToggle = VisualSection:Toggle({
    Name = "Esp Tickets",
    Flag = "EspTickets",
    Default = false,
    Callback = function(Value)
        _G.EspTickets = Value
    end
})

local SettingsCat = Window:Category("Settings")
local SettingsPage = Library:CreateSettingsPage(Window, KeybindList)
table.insert(SettingsCat.Elements, SettingsPage)
Window:Init()
