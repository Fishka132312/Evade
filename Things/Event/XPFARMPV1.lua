_G.XPFARMPV1 = _G.XPFARMPV1 or false
_G.XPFarmStop = false

_G.XPFarmConfig = _G.XPFarmConfig or {
	map            = "Maze",
	specialRound   = "Plushie Hell",
	mapLoadTimeout = 30,
	afterTimerWait = 1, -- пауза после !timer 0 перед новым !map
}
local cfg = _G.XPFarmConfig

if _G.XPFarmThread then pcall(task.cancel, _G.XPFarmThread) end
_G.XPFarmGen = (_G.XPFarmGen or 0) + 1
local myGen = _G.XPFarmGen

local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")
local LP      = Players.LocalPlayer

local function loaded() return (not _G.XPFarmStop) and _G.XPFarmGen == myGen end
local function active() return loaded() and _G.XPFARMPV1 == true end

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
end

local function sleep(seconds)
	local t0 = os.clock()
	while active() and os.clock() - t0 < seconds do
		task.wait(0.2)
	end
	return active()
end

local function waitUntil(fn, timeout, step)
	local t0 = os.clock()
	while active() do
		local ok, res = pcall(fn)
		if ok and res then return true end
		if os.clock() - t0 >= timeout then return false end
		task.wait(step or 0.15)
	end
	return false
end

local function gameHud() return LP.PlayerGui:FindFirstChild("Game") end

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

	if not waitUntil(function()
		local g = loadingGui()
		return (not g) or (not g.Visible)
	end, cfg.mapLoadTimeout, 0.25) then
		log("таймаут загрузки карты")
	end

	if not waitUntil(gameHud, 10) then
		log("HUD не появился")
		return false
	end
	return true
end

_G.XPFarmThread = task.spawn(function()
	log("загружен, ждёт _G.XPFARMPV1 = true")
	local wasActive = false

	while loaded() do
		if not active() then
			if wasActive then
				log("пауза (_G.XPFARMPV1 = false)")
				wasActive = false
			end
			task.wait(0.5)
			continue
		end

		if not wasActive then
			log("старт фарма")
			wasActive = true
		end

		if not gameHud() then
			pcall(SetPlayerMode.FireServer, SetPlayerMode, true)
			if not sleep(2) then continue end
		end

		cmd("!map " .. cfg.map)
		if not sleep(1) then continue end

		if waitForMapLoad() then
			if not sleep(1) then continue end
			cmd("!specialround " .. cfg.specialRound)
			if not sleep(1.5) then continue end
			cmd("!timer 0")
			-- после !timer 0 ждём 1 сек и сразу заново !map
			if not sleep(cfg.afterTimerWait or 1) then continue end
		else
			if not sleep(5) then continue end
		end
	end

	log("выгружен")
end)
