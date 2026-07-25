local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Fishka132312/MeowlGui/refs/heads/main/source/library.lua"))() -----2
local CheatName = "Evade"

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local scripts = {
  'Event/AutoFarmEvent.lua',
  'Event/XPFARMPV.lua',
  'Event/ShowBalance.lua',
  'Event/TicketESP.lua',
  'Event/AntiDev.lua',
  'Main/AvoidNPC.lua',
  'Main/AutoRevive.lua',
  'Visual/EspNPC.lua',
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
    Logo = "https://i.postimg.cc/R09KZw72/Bez-imeni-1.png"
})

-------------------------Event-----------------------

local EventCat = Window:Category("Event")
local EventPage = Window:Page({
		Name = "Summer Event",
		Icon = "https://i.postimg.cc/6q7p8GSZ/Bez-imeni-2.png",
		Category = EventCat
})

--AutoFarm Event--
local AutoFarmEventSection = EventPage:Section({Name = "Auto Farm", Side = 1, Icon = "https://i.postimg.cc/gj06NJ76/Bez-imeni-2.png"})

AutoFarmEventSection:Image({
    Id = "https://tr.rbxcdn.com/180DAY-e7de42d5d990a8c737a9720fd5ff31cc/768/432/Image/Webp/noFilter",
    Height = 90,
    Rounded = true
})

AutoFarmEventSection:Paragraph({
    Name = "Summer Event",
    Text = "Bubble farming is recommended only on VIP servers."
})

AutoFarmEventSection:Divider()

local BubblesFarmToggle = AutoFarmEventSection:Toggle({
    Name = "Bubbles Farm",
	Tooltip = "Automatically collects event bubbles on the map",
    Flag = "TicketFarm",
    Default = false,
    Callback = function(Value)
        _G.FarmEvent = Value
    end
})

local XPPVFARMToggle = AutoFarmEventSection:Toggle({
    Name = "PV FARM (USE IT ON PRIVATE SERVER)",
	Tooltip = "Farm XP. ONLY PRIVATE CEPBEP and can be combined with farm bubbles",
    Flag = "PVXPFarm",
    Default = false,
    Callback = function(Value)
        _G.XPFARMPV = Value
    end
})

local ThingsEventSection = EventPage:Section({Name = "Things", Side = 2})

local Disable3dRenderToggle = ThingsEventSection:Toggle({
    Name = "Disable 3d Render",
	Tooltip = "Disables world rendering. FPS boost",
    Flag = "Disable3d",
    Default = false,
    Callback = function(Value)
       local RunService = game:GetService("RunService")
        RunService:Set3dRenderingEnabled(not Value)
    end
})


local EspBubblesToggle = ThingsEventSection:Toggle({
    Name = "Esp Bubbles",
	Tooltip = "Shows bubbles through the walls",
    Flag = "EspBubbles",
    Default = false,
    Callback = function(Value)
        _G.EspTickets = Value
    end
})

local FarmDetailsToggle = ThingsEventSection:Toggle({
    Name = "Farm Details",
	Tooltip = "Shows the amount of bubbles and the collection speed per min, per hour",
    Flag = "FarmDetails",
    Default = false,
    Callback = function(Value)
        _G.ShowBalance = Value
    end
})

local FarmDetailsToggle = ThingsEventSection:Toggle({
    Name = "Anti Dev (USE IT ON PRIVATE SERVER)",
	Tooltip = "When someone joins your PV, your game will crash",
    Flag = "AntiDev",
    Default = false,
    Callback = function(Value)
        _G.AntiDev = Value
    end
})


-------------------------Game-----------------------

local GameCat = Window:Category("Game")
local MainPage = Window:Page({
		Name = "Main",
		Icon = "https://i.postimg.cc/ZYy9YGSk/Bez-imeni-2.png",
		Category = GameCat
})

--Things--
local ThingsMainSection = MainPage:Section({Name = "Things", Side = 2})

ThingsMainSection:Paragraph({
    Name = "Main",
    Text = "Basic survival functions. Enable Auto Revive if you're playing solo"
})

ThingsMainSection:Divider()

local ThingsToggle = ThingsMainSection:Toggle({
    Name = "Evoid NPC",
	Tooltip = "If nextbot is in 10 studs, teleport to the safe zone and return in 5 seconds",
    Flag = "EvoidNPC",
    Default = false,
    Callback = function(Value)
        _G.AvoidNPC = Value
    end
})

local ThingsToggle = ThingsMainSection:Toggle({
    Name = "Auto Revive (Self)",
	Tooltip = "Automatically revives when you're down",
    Flag = "AutoReviveSelf",
    Default = false,
    Callback = function(Value)
        _G.AutoRevive = Value
    end
})

-------------------------Visual-----------------------

local VisualPage = Window:Page({
		Name = "Visual",
		Icon = "https://i.postimg.cc/8zCNcv6R/Bez-imeni-2.png",
		Category = GameCat
})

--Visual--
local VisualSection = VisualPage:Section({Name = "Visual", Side = 1, Icon = "https://i.postimg.cc/8zCNcv6R/Bez-imeni-2.png"})

local EspNpcToggle = VisualSection:Toggle({
    Name = "Esp NPC",
	Tooltip = "Shows nextbots through the walls",
    Flag = "EspNPC",
    Default = false,
    Callback = function(Value)
        _G.EspNPC = Value
    end
})

local EspDownedToggle = VisualSection:Toggle({
    Name = "Esp Downed",
	Tooltip = "Shows the people through the walls who got downed",
    Flag = "DownedEsp",
    Default = false,
    Callback = function(Value)
        _G.EspDowned = Value
    end
})

--Things--
local ThingsVisualSection = VisualPage:Section({Name = "Things", Side = 2})

local EspTicketsToggle = ThingsVisualSection:Toggle({
    Name = "ad",
    Flag = "EspTickets",
    Default = false,
    Callback = function(Value)
    end
})

-------------------------Misc-----------------------

local MiscPage = Window:Page({
		Name = "Misc",
		Icon = "https://i.postimg.cc/CxnfNm71/Bez-imeni-1.png",
		Category = GameCat
})

--Misc--
local MiscSection = MiscPage:Section({Name = "Misc", Side = 1, Icon = "https://i.postimg.cc/CxnfNm71/Bez-imeni-1.png"})

MiscSection:Button({
    Name = "Anti Afk",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Fishka132312/Evade/refs/heads/main/Things/Misc/AntiAfk.lua'))()
    end
})

MiscSection:Button({
    Name = "Anti Lag",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Fishka132312/Evade/refs/heads/main/Things/Misc/AntiLag.lua'))()
    end
})

MiscSection:Button({
    Name = "Remote Spy",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Fishka132312/Evade/refs/heads/main/Things/Misc/RemoteSpy.lua'))()
    end
})

MiscSection:Slider({
    Name = "FPS Cap",
    Tooltip = "Frame limit. Apply using the button below",
    Flag = "FpsCap",
    Min = 25,
    Max = 240,
    Default = 60,
    Suffix = " fps",
    Decimals = 1
})

MiscSection:Button({
    Name = "Apply FPS Cap",
    Tooltip = "Apply the selected FPS Cap",
    Callback = function()
        local Value = Library.Flags["FpsCap"]

        if setfpscap then
            setfpscap(Value)

            Library:Notification({
                Title = "Performance",
                Description = "FPS cap set to " .. Value,
                Duration = 3
            })
        else
            Library:Notification({
                Title = "Error",
                Description = "Exec dont support setfpscap",
                Duration = 4
            })
        end
    end
})

local SettingsCat = Window:Category("Settings")

local UiPage = Library:CreateUiPage(Window)
table.insert(SettingsCat.Elements, UiPage)
local SettingsPage = Library:CreateSettingsPage(Window, KeybindList)
table.insert(SettingsCat.Elements, SettingsPage)
Window:Init()
