_G.XPFARMPV = _G.XPFARMPV or false
_G.XPFarmStop = false

_G.XPFarmConfig = _G.XPFarmConfig or {}
local cfg = _G.XPFarmConfig

local DEFAULTS = {
	cycleCooldown   = 30,   -- минимальная длина цикла (сек)
	afterTimerDelay = 5,    -- сколько ждать после !timer 0 (раунд заканчивается)
	map             = "Maze",
	specialRound    = "Plushie Hell",
	mapLoadTimeout  = 30,
	timerDelay      = 2,    -- пауза между !specialround и !timer 0
	timerCommand    = "!timer 0",
}
for k, v in pairs(DEFAULTS) do
	if cfg[k] == nil then cfg[k] = v end
end

if _G.XPFarmThread then pcall(task.cancel, _G.XPFarmThread) end
_G.XPFarmGen = (_G.XPFarmGen or 0) + 1
local myGen = _G.XPFarmGen

local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")
local LP      = Players.LocalPlayer

local cycleStart = os.clock()

local function loaded() return (not _G.XPFarmStop) and _G.XPFarmGen == myGen end
local function active() return loaded() and _G.XPFARMPV == true end

local function log(...)
	print(string.format("[XPFarm +%5.1fs]", os.clock() - cycleStart), ...)
end

local Events = RS:WaitForChild("Events", 10)
if not Events then return log("Events не найден") end
local Admin = Events:WaitForChild("Admin", 10)
local AdminCommand = Admin and Admin:WaitForChild("Command", 10)
local SetPlayerMode = Events:WaitForChild("SetPlayerMode", 10)
if not (AdminCommand and SetPlayerMode) then return log("ремоуты не найдены") end

local function cmd(text)
	log("-> команда:", text)
	local ok, err = pcall(AdminCommand.FireServer, AdminCommand, text)
	if not ok then log("ОШИБКА команды", text, err) end
	return ok
end

local function sleep(seconds)
	local t0 = os.clock()
	while active() and os.clock() - t0 < seconds do
		task.wait(0.1)
	end
	return active()
end

local function waitUntil(fn, timeout, step)
	local t0 = os.clock()
	while active() do
		local ok, res = pcall(fn)
		if ok and res then return true end
		if os.clock() - t0 >= timeout then return false end
		task.wait(step or 0.1)
	end
	return false
end

local function gameHud() return LP.PlayerGui:FindFirstChild("Game") end

-- ждём, пока карта загрузится (экран LoadingMap появился и пропал)
local function waitForMapLoad()
	local function loadingGui()
		local shared = LP.PlayerGui:FindFirstChild("Shared")
		local popups = shared and shared:FindFirstChild("Popups")
		return popups and popups:FindFirstChild("LoadingMap")
	end

	local saw = waitUntil(function()
		local g = loadingGui()
		return g and g.Visible
	end, 5)
	log(saw and "экран загрузки карты появился" or "экран загрузки не появился за 5с (идём дальше)")

	if waitUntil(function()
		local g = loadingGui()
		return (not g) or (not g.Visible)
	end, cfg.mapLoadTimeout, 0.25) then
		log("карта загрузилась")
	else
		log("ТАЙМАУТ загрузки карты (всё равно продолжаю)")
	end

	-- HUD больше не блокирует цикл: просто ждём немного и логируем
	if not waitUntil(gameHud, 5) then
		log("HUD (PlayerGui.Game) не найден — продолжаю без него")
	end
	return active()
end

_G.XPFarmThread = task.spawn(function()
	log("загружен, ждёт _G.XPFARMPV = true")
	local wasActive = false
	local cycleNum = 0

	while loaded() do
		if not active() then
			if wasActive then
				log("пауза (_G.XPFARMPV = false)")
				wasActive = false
			end
			task.wait(0.5)
			continue
		end

		if not wasActive then
			log("старт фарма")
			wasActive = true
		end

		cycleStart = os.clock()
		cycleNum += 1
		log("=== цикл #" .. cycleNum .. " ===")

		if not gameHud() then
			log("HUD нет, включаю режим игрока")
			pcall(SetPlayerMode.FireServer, SetPlayerMode, true)
			if not sleep(2) then continue end
		end

		-- 1) карта
		cmd("!map " .. cfg.map)
		if not sleep(1) then continue end
		if not waitForMapLoad() then continue end

		-- 2) специальный раунд
		cmd("!specialround " .. cfg.specialRound)

		-- 3) через timerDelay секунд — !timer 0
		log("жду " .. cfg.timerDelay .. "с перед таймером")
		if not sleep(cfg.timerDelay) then continue end
		cmd(cfg.timerCommand)

		-- 4) даём раунду закончиться
		if not sleep(cfg.afterTimerDelay) then continue end

		-- 5) добираем до минимальной длины цикла
		local remaining = cfg.cycleCooldown - (os.clock() - cycleStart)
		if remaining > 0 then
			log(("цикл %.1f сек, добираю %.1f"):format(os.clock() - cycleStart, remaining))
			sleep(remaining)
		end
	end

	log("выгружен")
end)
