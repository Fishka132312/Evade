_G.XPFARMPV = _G.XPFARMPV or false
_G.XPFarmRunning = false

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local AdminCommand = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Admin"):WaitForChild("Command")
local SetPlayerModeEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SetPlayerMode")

local function fireCommand(cmd)
    pcall(function()
        AdminCommand:FireServer(cmd)
    end)
end

local function isInLobby()
    return LocalPlayer.PlayerGui:FindFirstChild("Game") ~= nil
end

local function getRoundTimer()
    local success, text = pcall(function()
        local gui = LocalPlayer.PlayerGui:FindFirstChild("Game")
        if not gui then return nil end
        return gui.HUD.Overlay.RoundOverlay.RoundTimer.IngameRoundTimer.Timer.Text
    end)
    return success and text or nil
end

-- "1:23" -> 83 секунды, мусор -> nil
local function parseTimer(text)
    if type(text) ~= "string" then return nil end
    local m, s = text:match("(%d+):(%d+)")
    if not m then return nil end
    return tonumber(m) * 60 + tonumber(s)
end

local function waitForMapLoad()
    pcall(function()
        local popups = LocalPlayer.PlayerGui:WaitForChild("Shared", 10):WaitForChild("Popups", 10)
        local loading = popups:WaitForChild("LoadingMap", 20)

        -- 1) ждём ПОЯВЛЕНИЯ экрана загрузки (максимум 5 сек)
        local deadline = os.clock() + 5
        while _G.XPFARMPV and not loading.Visible and os.clock() < deadline do
            task.wait(0.1)
        end

        -- 2) ждём пока он пропадёт (максимум 45 сек, чтобы не зависнуть навсегда)
        deadline = os.clock() + 45
        while _G.XPFARMPV and loading.Visible and os.clock() < deadline do
            task.wait(0.25)
        end
    end)
end

-- ждём пока таймер станет > 0, то есть раунд реально пошёл
local function waitForRoundStart(timeout)
    local deadline = os.clock() + (timeout or 10)

    while os.clock() < deadline do
        local seconds = parseTimer(getRoundTimer())
        if seconds and seconds > 0 then
            return true
        end
        task.wait(0.2)
    end

    return false
end

local function mainLoop(MyToken)
    local function alive()
        return _G.XPFarmRunning and _G.XPFarmToken == MyToken
    end

    while alive() do
        if not _G.XPFARMPV then
            task.wait(1)
            continue
        end

        if not isInLobby() then
            pcall(function()
                SetPlayerModeEvent:FireServer(true)
            end)
            task.wait(1.5)
        end

        fireCommand("!map DesertBus")
        task.wait(0.6)

        waitForMapLoad()
        task.wait(0.6)

        fireCommand("!specialround Plushie Hell")
        task.wait(0.6)

            -- сначала убеждаемся что раунд стартовал, и только потом рубим таймер
    if not waitForRoundStart(10) then
        -- раунд так и не начался - идём на новый круг, карту ставим заново
        task.wait(1)
        continue
    end

    fireCommand("!timer 0")

    -- страховка от вечного зависания на одном раунде
    local roundDeadline = os.clock() + 60

    while _G.XPFARMPV and _G.XPFarmRunning and os.clock() < roundDeadline do
        local seconds = parseTimer(getRoundTimer())

        if seconds and seconds <= 1 then
            task.wait(0.6)
            break
        end

        task.wait(0.3)
    end

    task.wait(0.6)
end
end

-- каждый запуск получает свой номер; старые копии умирают сами
_G.XPFarmToken = (_G.XPFarmToken or 0) + 1
_G.XPFarmRunning = true

local MyToken = _G.XPFarmToken

_G.XPFarmConnection = task.spawn(function()
    mainLoop(MyToken)
end)
