_G.XPFARMPV = _G.XPFARMPV or false  --12131
_G.XPFarmStop = false

_G.XPFarmConfig = _G.XPFarmConfig or {}
local cfg = _G.XPFarmConfig

local DEFAULTS = {
	cycleCooldown   = 30,   -- минимальная длина всего цикла (сек)
	map             = "Maze",
	specialRound    = "Plushie Hell",
	mapLoadTimeout  = 30,
	timerDelay      = 2,    -- пауза между !specialround и !timer 0
	timerCommand    = "!timer 0",

	-- конец раунда = Frame PlayerGui.Shared.Popups.Rewards стал Visible = true
	roundEndTimeout = 400,  -- максимум ожидания окна Rewards после !timer 0 (сек)
	postRoundDelay  = 2,    -- пауза после конца раунда перед следующим !map

	watchGui        = false, -- отладка: печатать, какие GUI появились/пропали
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

----------------------------------------------------------------
-- GUI-хелперы
----------------------------------------------------------------
-- PlayerGui.Shared.Popups.Rewards (может не существовать до первого показа)
local function rewardsFrame()
	local shared = LP.PlayerGui:FindFirstChild("Shared")
	local popups = shared and shared:FindFirstChild("Popups")
	return popups and popups:FindFirstChild("Rewards")
end

local function rewardsVisible()
	local r = rewardsFrame()
	return r ~= nil and r.Visible == true
end

-- скрыть окно наград (Visible = false)
local function hideRewards()
	local r = rewardsFrame()
	if r then
		pcall(function() r.Visible = false end)
		return true
	end
	return false
end

-- снимок видимых GUI (глубина до 4) — только для отладки (cfg.watchGui)
local function snapshotGui()
	local snap = {}
	local pgName = LP.PlayerGui:GetFullName()
	local function walk(obj, depth)
		for _, c in ipairs(obj:GetChildren()) do
			if c:IsA("ScreenGui") then
				if c.Enabled then
					snap[c.Name] = true
					walk(c, 1)
				end
			elseif c:IsA("GuiObject") then
				if c.Visible then
					snap[c:GetFullName():sub(#pgName + 2)] = true
					if depth < 4 then walk(c, depth + 1) end
				end
			end
		end
	end
	walk(LP.PlayerGui, 0)
	return snap
end

local function logGuiDiff(prev, cur)
	for k in pairs(cur) do
		if not prev[k] then log("GUI появился/виден:", k) end
	end
	for k in pairs(prev) do
		if not cur[k] then log("GUI пропал/скрыт:", k) end
	end
end

----------------------------------------------------------------
-- ЗАГРУЗКА КАРТЫ
----------------------------------------------------------------
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

	if not waitUntil(gameHud, 5) then
		log("HUD (PlayerGui.Game) не найден — продолжаю без него")
	end
	return active()
end

----------------------------------------------------------------
-- ОЖИДАНИЕ КОНЦА РАУНДА (после !timer 0)
-- конец раунда = Shared.Popups.Rewards.Visible == true
----------------------------------------------------------------
local function waitRoundEnd()
	local t0 = os.clock()
	local prev = cfg.watchGui and snapshotGui() or nil

	-- если окно наград осталось видимым с прошлого раунда — просто прячем, чтобы не принять его за конец нового
	if rewardsVisible() then
		log("Rewards уже виден (остаток прошлого раунда), скрываю")
		hideRewards()
		task.wait(0.1)
	end

	log("жду Rewards.Visible = true (макс " .. cfg.roundEndTimeout .. "с)")

	while active() do
		local elapsed = os.clock() - t0

		if rewardsVisible() then
			log(("Rewards появился через %.1fс — раунд закончен, скрываю окно"):format(elapsed))
			hideRewards()
			return true
		end

		if elapsed >= cfg.roundEndTimeout then
			log("ТАЙМАУТ: Rewards так и не появился")
			return false
		end

		if prev then
			local cur = snapshotGui()
			logGuiDiff(prev, cur)
			prev = cur
		end
		task.wait(0.1)
	end
	return false
end

----------------------------------------------------------------
-- ОСНОВНОЙ ЦИКЛ
----------------------------------------------------------------
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
		if not sleep(cfg.timerDelay) then continue end
		cmd(cfg.timerCommand)

		-- 4) ждём, пока Rewards станет видимым, только потом следующий цикл
		waitRoundEnd()
		if not active() then continue end
		if not sleep(cfg.postRoundDelay) then continue end

		-- 5) добираем до минимальной длины цикла
		local remaining = cfg.cycleCooldown - (os.clock() - cycleStart)
		if remaining > 0 then
			log(("цикл %.1f сек, добираю %.1f"):format(os.clock() - cycleStart, remaining))
			sleep(remaining)
		end
	end

	log("выгружен")
end)
