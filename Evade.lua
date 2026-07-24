local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Fishka132312/MeowlGui/refs/heads/main/source/library.lua"))()
local CheatName = "Evade"

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local scripts = {
  'Event/AutoFarmEvent.lua',
  'Event/XPFARMPV.lua',
  'Event/ShowBalance.lua',
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

local EventCat = Window:Category("Event")
local EventPage = Window:Page({
		Name = "Summer Event 🫧",
		Icon = "7539983773",
		Category = EventCat
})

--AutoFarm Event--
local AutoFarmEventSection = EventPage:Section({Name = "Auto Farm", Side = 1})

local BubblesFarmToggle = AutoFarmEvent:Toggle({
    Name = "Bubbles Farm",
    Flag = "TicketFarm",
    Default = false,
    Callback = function(Value)
        _G.FarmEvent = Value
    end
})

local XPPVFARMToggle = AutoFarmEvent:Toggle({
    Name = "PV FARM (USE IT ON PRIVATE SERVER)",
    Flag = "PVXPFarm",
    Default = false,
    Callback = function(Value)
        _G.XPFARMPV = Value
    end
})

local ThingsEventSection = EventPage:Section({Name = "Things", Side = 2})

local Disable3dRenderToggle = ThingsEventSection:Toggle({
    Name = "Disable 3d Render",
    Flag = "Disable3d",
    Default = false,
    Callback = function(Value)
       local RunService = game:GetService("RunService")
        RunService:Set3dRenderingEnabled(not Value)
    end
})


local EspBubblesToggle = ThingsEventSection:Toggle({
    Name = "Esp Bubbles",
    Flag = "EspBubbles",
    Default = false,
    Callback = function(Value)
        _G.EspTickets = Value
    end
})

local FarmDetailsToggle = ThingsEventSection:Toggle({
    Name = "Farm Details",
    Flag = "FarmDetails",
    Default = false,
    Callback = function(Value)
        _G.ShowBalance = Value
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
local ThingsMainSection = MainPage:Section({Name = "Things", Side = 2})

local ThingsToggle = ThingsMainSection:Toggle({
    Name = "Evoid NPC",
    Flag = "EvoidNPC",
    Default = false,
    Callback = function(Value)
        _G.AvoidNPC = Value
    end
})

-------------------------Visual-----------------------

local VisualPage = Window:Page({
		Name = "Visual",
		Icon = "7539983773",
		Category = MainCat
})

--Visual--
local VisualSection = VisualPage:Section({Name = "Visual", Side = 1})

local EspNpcToggle = VisualSection:Toggle({
    Name = "Esp NPC",
    Flag = "EspNPC",
    Default = false,
    Callback = function(Value)
        _G.EspNPC = Value
    end
})

local EspDownedToggle = VisualSection:Toggle({
    Name = "Esp Downed",
    Flag = "DownedEsp",
    Default = false,
    Callback = function(Value)
        _G.EspDowned = Value
    end
})

--Things--
local ThingsVisualSection = VisualPage:Section({Name = "Things", Side = 2})

local EspTicketsToggle = ThingsVisualSection:Toggle({
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
