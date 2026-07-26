_G.XPFarm = _G.XPFarm or {}
local F = _G.XPFarm

if F.thread then pcall(task.cancel, F.thread) end
F.gen = (F.gen or 0) + 1
F.enabled = false
F.config = {
	cycleCooldown  = 30,
	postRoundDelay = 3,
	map            = "DesertBus",
	specialRound   = "Plushie Hell",
	mapLoadTimeout = 30,
	roundTimeout   = 180,
	pollRate       = 0.35,
}

local cfg   = F.config
local myGen = F.gen

local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")
local LP      = Players.LocalPlayer

local function alive() return F.enabled and F.gen == myGen end

local function log(...) warn("[XPFarm]", ...) end

local Events = RS:WaitForChild("Events", 10)
if not Events then return log("Events не найден") end
local Admin = Events:WaitForChild("Admin", 10)
local AdminCommand = Admin and Admin:WaitForChild("Command", 10)
local SetPlayerMode = Events:WaitForChild("SetPlayerMode", 10)
if not (AdminCommand and SetPlayerMode) then return log("ремоуты не найдены") end

local function cmd(text)
	local ok, err = pcall(AdminCommand.FireServer, AdminCommand, text)
	if not ok then log("ошибка команды", text, err) end
	return ok
end

local function waitUntil(fn, timeout, step)
	local t0 = os.clock()
	while alive() do
		local ok, res = pcall(fn)
		if ok and res then return true end
		if os.clock() - t0 >= timeout then return false end
		task.wait(step or 0.15)
	end
	return false
end

local function sleep(seconds)
	local t0 = os.clock()
	while alive() and os.clock() - t0 < seconds do
		task.wait(0.2)
	end
	return alive()
end

local function gameHud()
	return LP.PlayerGui:FindFirstChild("Game")
end

local function secondsLeft()
	local gui = gameHud()
	if not gui then return nil end
	local ok, text = pcall(function()
		return gui.HUD.Overlay.RoundOverlay.RoundTimer.IngameRoundTimer.Timer.Text
	end)
	if not ok or type(text) ~= "string" then return nil end
	local m, s = text:match("(%d+)%s*:%s*(%d+)")
	if m then return tonumber(m) * 60 + tonumber(s) end
	return tonumber(text:match("%d+"))
end

local function waitForMapLoad()
	local function loadingGui()
		local shared = LP.PlayerGui:FindFirstChild("Shared")
		local popups = shared and shared:FindFirstChild("Popups")
		return popups and popups:FindFirstChild("LoadingMap")
	end

	waitUntil(function()
		local g = loadingGui()
		return g and g.Visible
	end, 5)

	local done = waitUntil(function()
		local g = loadingGui()
		return (not g) or (not g.Visible)
	end, cfg.mapLoadTimeout, 0.25)

	if not done then log("таймаут загрузки карты") end

	if not waitUntil(gameHud, 10) then
		log("HUD не появился")
		return false
	end
	return true
end

local function waitRoundEnd()
	local t0, sawTimer = os.clock(), false
	while alive() do
		local left = secondsLeft()
		if left then
			sawTimer = true
			if left <= 1 then
				sleep(1)
				return true
			end
		elseif sawTimer then
			return true
		end
		if os.clock() - t0 > cfg.roundTimeout then
			log("таймаут раунда, иду на новый цикл")
			return false
		end
		task.wait(cfg.pollRate)
	end
	return false
end

F.thread = task.spawn(function()
	log("запущен, кулдаун цикла:", cfg.cycleCooldown, "сек")

	while alive() do
		local cycleStart = os.clock()

		if not gameHud() then
			pcall(SetPlayerMode.FireServer, SetPlayerMode, true)
			if not sleep(2) then break end
		end

		cmd("!map " .. cfg.map)
		if not sleep(1) then break end

		if waitForMapLoad() then
			if not sleep(1) then break end
			cmd("!specialround " .. cfg.specialRound)
			if not sleep(1.5) then break end
			cmd("!timer 0")
			if not sleep(1.5) then break end

			waitRoundEnd()
			if not sleep(cfg.postRoundDelay) then break end
		else
			if not sleep(5) then break end
		end

		local elapsed = os.clock() - cycleStart
		local remaining = cfg.cycleCooldown - elapsed
		if remaining > 0 then
			log(("цикл занял %.1f сек, жду ещё %.1f"):format(elapsed, remaining))
			if not sleep(remaining) then break end
		end
	end

	log("остановлен")
end)
