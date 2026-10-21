_G.XPFARMPV = _G.XPFARMPV or false
_G.XPFarmStop = false

_G.XPFarmConfig = _G.XPFarmConfig or {}
local cfg = _G.XPFarmConfig

-- значения по умолчанию; если в старом конфиге нет нового ключа, он добавится
local DEFAULTS = {
	cycleCooldown      = 30,
	postRoundDelay     = 3,
	map                = "Maze",
	specialRound       = "Plushie Hell",
	mapLoadTimeout     = 30,
	roundTimeout       = 180,
	pollRate           = 0.35,

	timerCommand       = "!timer 0", -- какая команда шлётся, когда появился таймер
	timerAppearTimeout = 60,         -- сколько ждать появления таймера после загрузки карты
	timerRetries       = 6,          -- сколько раз повторять !timer 0, если таймер не упал
	timerConfirmWait   = 3,          -- сколько секунд ждать реакции таймера после команды
	requireVisible     = false,      -- true = считать таймер только если все родители Visible
	logTimer           = true,       -- печатать каждое изменение текста таймера
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

-- print вместо warn + время от начала цикла, чтобы видеть задержки
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
-- ТАЙМЕР
----------------------------------------------------------------
local TIMER_PATH = { "HUD", "Overlay", "RoundOverlay", "RoundTimer", "IngameRoundTimer", "Timer" }

-- возвращает label или nil + причину (на каком элементе пути оборвалось)
local function getTimerLabel()
	local obj = gameHud()
	if not obj then return nil, "нет PlayerGui.Game" end
	for _, name in ipairs(TIMER_PATH) do
		local nxt = obj:FindFirstChild(name)
		if not nxt then
			return nil, "нет '" .. name .. "' внутри " .. obj:GetFullName()
		end
		obj = nxt
	end
	return obj
end

local function isVisibleGui(obj)
	local cur = obj
	while cur and cur ~= LP.PlayerGui do
		if cur:IsA("GuiObject") and not cur.Visible then return false end
		if cur:IsA("ScreenGui") and not cur.Enabled then return false end
		cur = cur.Parent
	end
	return true
end

local lastTimerState = nil

-- секунды до конца раунда или nil; любое изменение состояния таймера логируется
local function secondsLeft()
	local label, why = getTimerLabel()
	local secs, state

	if not label then
		state = "нет (" .. tostring(why) .. ")"
	else
		local text = label.Text
		local vis = isVisibleGui(label)
		if cfg.requireVisible and not vis then
			state = "скрыт, текст '" .. text .. "'"
		else
			local m, s = text:match("(%d+)%s*:%s*(%d+)")
			if m then
				secs = tonumber(m) * 60 + tonumber(s)
			else
				secs = tonumber(text:match("%d+"))
			end
			if secs then
				state = "'" .. text .. "' = " .. secs .. "с" .. (vis and "" or " [не visible]")
			else
				state = "текст '" .. text .. "' не распарсился"
			end
		end
	end

	if state ~= lastTimerState then
		lastTimerState = state
		if cfg.logTimer then log("таймер:", state) end
	end
	return secs
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

	local sawLoading = waitUntil(function()
		local g = loadingGui()
		return g and g.Visible
	end, 5)
	log(sawLoading and "экран загрузки карты появился" or "экран загрузки не появился за 5с (идём дальше)")

	if not waitUntil(function()
		local g = loadingGui()
		return (not g) or (not g.Visible)
	end, cfg.mapLoadTimeout, 0.25) then
		log("ТАЙМАУТ загрузки карты")
	else
		log("карта загрузилась")
	end

	if not waitUntil(gameHud, 10) then
		log("HUD (PlayerGui.Game) не появился")
		return false
	end
	return true
end

----------------------------------------------------------------
-- !timer 0: шлём, когда таймер появился, и проверяем реакцию
----------------------------------------------------------------
local function forceTimerZero()
	for attempt = 1, cfg.timerRetries do
		if not active() then return false end

		local before = secondsLeft()
		if before and before <= 1 then
			log("таймер уже на нуле, команда не нужна")
			return true
		end

		log(("попытка %d/%d: таймер сейчас = %s"):format(attempt, cfg.timerRetries, tostring(before)))
		local t0 = os.clock()
		cmd(cfg.timerCommand)

		local confirmed = waitUntil(function()
			local s = secondsLeft()
			return s == nil or s <= 1 or (before ~= nil and s < before - 5)
		end, cfg.timerConfirmWait, 0.1)

		if confirmed then
			log(("таймер отреагировал за %.2f сек"):format(os.clock() - t0))
			return true
		end
		log("таймер НЕ отреагировал за " .. cfg.timerConfirmWait .. "с, повторяю")
	end

	log("!timer 0 не подтвердился после " .. cfg.timerRetries .. " попыток")
	return false
end

local function waitRoundEnd()
	local t0, sawTimer = os.clock(), false
	while active() do
		local left = secondsLeft()
		if left then
			sawTimer = true
			if left <= 1 then
				log("раунд закончился (таймер <= 1)")
				sleep(1)
				return true
			end
		elseif sawTimer then
			log("раунд закончился (таймер пропал)")
			return true
		end
		if os.clock() - t0 > cfg.roundTimeout then
			log("ТАЙМАУТ раунда")
			return false
		end
		task.wait(cfg.pollRate)
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
		lastTimerState = nil
		cycleNum += 1
		log("=== цикл #" .. cycleNum .. " ===")

		if not gameHud() then
			log("HUD нет, включаю режим игрока")
			pcall(SetPlayerMode.FireServer, SetPlayerMode, true)
			if not sleep(2) then continue end
		end

		cmd("!map " .. cfg.map)
		if not sleep(1) then continue end

		if waitForMapLoad() then
			if not sleep(0.5) then continue end

			cmd("!specialround " .. cfg.specialRound)
			if not sleep(0.7) then continue end

			-- ждём появления таймера, а не фиксированное время
			log("жду появления таймера...")
			local appeared = waitUntil(function()
				return secondsLeft() ~= nil
			end, cfg.timerAppearTimeout, 0.1)

			if appeared then
				log("таймер появился -> сразу шлю " .. cfg.timerCommand)
				forceTimerZero()
			else
				local _, why = getTimerLabel()
				log("ТАЙМЕР НЕ ПОЯВИЛСЯ за " .. cfg.timerAppearTimeout .. "с. Причина: " .. tostring(why))
				log("шлю " .. cfg.timerCommand .. " вслепую один раз")
				cmd(cfg.timerCommand)
			end

			if not active() then continue end
			waitRoundEnd()
			if not sleep(cfg.postRoundDelay) then continue end
		else
			log("карта не загрузилась, жду 5с")
			if not sleep(5) then continue end
		end

		local remaining = cfg.cycleCooldown - (os.clock() - cycleStart)
		if remaining > 0 then
			log(("цикл %.1f сек, добираю %.1f"):format(os.clock() - cycleStart, remaining))
			sleep(remaining)
		end
	end

	log("выгружен")
end)
