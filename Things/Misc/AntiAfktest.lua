local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
	repeat task.wait() until Players.LocalPlayer
	LocalPlayer = Players.LocalPlayer
end


local CONFIG = {
	KillIdledConnections = true,
	PreferDisableOverDisconnect = true,

	UseVirtualUser = true,

	UseInputPulse = true,
	PulseInterval = 240,
	SkipPulseIfUserActive = true,
	UserActiveWindow = 120,

	UseWorldJiggle = false,
	JiggleInterval = 180,
	JiggleDistance = 0.35,
	JiggleReturn = true,
	JiggleOnlyWhenStill = true,

	WatchdogInterval = 45,

	Notify = true, 
	Debug = false,
	GlobalName = "AntiAFK",
}

local State = {
	running = false,
	startedAt = os.clock(),

	hasGetConnections = false,

	killedTotal = 0,
	stubborn = 0,
	disabledRefs = {},

	ownHandler = nil,
	ownConnection = nil,
	idledFires = 0,
	lastIdledAt = 0,

	pulses = 0,
	lastPulseAt = 0,
	jiggles = 0,
	lastJiggleAt = 0,

	lastRealInputAt = os.clock(),

	threads = {},
	connections = {},
	mode = "none",
	lastReport = "",
}


local function log(...)
	if CONFIG.Debug then
		print("[AntiAFK]", ...)
	end
end

local function warnLog(...)
	warn("[AntiAFK]", ...)
end

local function notify(title, text)
	if not CONFIG.Notify then
		return
	end
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = title,
			Text = text,
			Duration = 5,
		})
	end)
end

local function safeIndex(obj, key)
	local ok, value = pcall(function()
		return obj[key]
	end)
	if ok then
		return value
	end
	return nil
end

local function safeCall(fn, ...)
	if type(fn) ~= "function" then
		return false
	end
	return (pcall(fn, ...))
end

local function track(connection)
	if connection then
		table.insert(State.connections, connection)
	end
	return connection
end

local function spawnTracked(fn)
	local thread = task.spawn(fn)
	table.insert(State.threads, thread)
	return thread
end

local function fmtTime(seconds)
	seconds = math.max(0, math.floor(seconds))
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = seconds % 60
	if h > 0 then
		return string.format("%dh %dm %ds", h, m, s)
	elseif m > 0 then
		return string.format("%dm %ds", m, s)
	end
	return string.format("%ds", s)
end

local IdledKiller = {}

function IdledKiller.isAvailable()
	return type(getconnections) == "function"
end

function IdledKiller.isOurs(connection)
	if connection == State.ownConnection then
		return true
	end
	if State.ownHandler and safeIndex(connection, "Function") == State.ownHandler then
		return true
	end
	return false
end

function IdledKiller.isDead(connection)
	if safeIndex(connection, "Enabled") == false then
		return true
	end
	if safeIndex(connection, "Connected") == false then
		return true
	end
	return false
end

function IdledKiller.kill(connection)
	local order
	if CONFIG.PreferDisableOverDisconnect then
		order = { "Disable", "disable", "Disconnect", "disconnect" }
	else
		order = { "Disconnect", "disconnect", "Disable", "disable" }
	end

	for _, name in ipairs(order) do
		local fn = safeIndex(connection, name)
		if type(fn) == "function" and safeCall(fn, connection) then
			if name == "Disable" or name == "disable" then
				table.insert(State.disabledRefs, connection)
			end
			return true
		end
	end

	if safeIndex(connection, "Enabled") ~= nil then
		pcall(function()
			connection.Enabled = false
		end)
		if IdledKiller.isDead(connection) then
			table.insert(State.disabledRefs, connection)
			return true
		end
	end

	return false
end

function IdledKiller.sweep()
	if not CONFIG.KillIdledConnections or not IdledKiller.isAvailable() then
		return 0, 0, "unavailable"
	end

	local ok, connections = pcall(getconnections, LocalPlayer.Idled)
	if not ok or type(connections) ~= "table" then
		return 0, 0, "error"
	end

	local killed, stubborn = 0, 0

	for _, connection in pairs(connections) do
		local t = typeof(connection)
		if t == "table" or t == "userdata" then
			if IdledKiller.isOurs(connection) then
				if IdledKiller.isDead(connection) then
					State.ownConnection = nil
					State.ownHandler = nil
					log("our fallback was killed externally, will respawn")
				end
			elseif not IdledKiller.isDead(connection) then
				if IdledKiller.kill(connection) then
					killed = killed + 1
				else
					stubborn = stubborn + 1
				end
			end
		end
	end

	State.killedTotal = State.killedTotal + killed
	State.stubborn = stubborn
	return killed, stubborn, "ok"
end

function IdledKiller.restore()
	local restored = 0
	for _, connection in ipairs(State.disabledRefs) do
		for _, name in ipairs({ "Enable", "enable" }) do
			local fn = safeIndex(connection, name)
			if type(fn) == "function" and safeCall(fn, connection) then
				restored = restored + 1
				break
			end
		end
		if safeIndex(connection, "Enabled") == false then
			pcall(function()
				connection.Enabled = true
			end)
		end
	end
	table.clear(State.disabledRefs)
	return restored
end

local VirtualLayer = {}

function VirtualLayer.sendInput()
	local ok = pcall(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end)
	if not ok then
		pcall(function()
			VirtualUser:SetKeyDown("0")
			task.wait(0.05)
			VirtualUser:SetKeyUp("0")
		end)
	end
	return ok
end

function VirtualLayer.isAlive()
	if not State.ownConnection then
		return false
	end
	return not IdledKiller.isDead(State.ownConnection)
end

function VirtualLayer.arm()
	if not CONFIG.UseVirtualUser then
		return false
	end
	if VirtualLayer.isAlive() then
		return true
	end

	State.ownHandler = function()
		State.idledFires = State.idledFires + 1
		State.lastIdledAt = os.clock()
		VirtualLayer.sendInput()
		log("Idled fired -> virtual input sent (total:", State.idledFires, ")")
	end

	local ok, connection = pcall(function()
		return LocalPlayer.Idled:Connect(State.ownHandler)
	end)

	if ok and connection then
		State.ownConnection = connection
		log("VirtualUser layer armed")
		return true
	end

	State.ownHandler = nil
	State.ownConnection = nil
	warnLog("failed to arm VirtualUser layer")
	return false
end

function VirtualLayer.disarm()
	if State.ownConnection then
		pcall(function()
			State.ownConnection:Disconnect()
		end)
	end
	State.ownConnection = nil
	State.ownHandler = nil
end

local PulseLayer = {}

function PulseLayer.userRecentlyActive()
	if not CONFIG.SkipPulseIfUserActive then
		return false
	end
	return (os.clock() - State.lastRealInputAt) < CONFIG.UserActiveWindow
end

function PulseLayer.pulse(force)
	if not force and PulseLayer.userRecentlyActive() then
		log("pulse skipped: real user input detected recently")
		return false
	end

	VirtualLayer.sendInput()
	State.pulses = State.pulses + 1
	State.lastPulseAt = os.clock()
	log("preventive pulse sent (total:", State.pulses, ")")
	return true
end

function PulseLayer.start()
	if not CONFIG.UseInputPulse then
		return
	end

	track(UserInputService.InputBegan:Connect(function(_, gameProcessed)
		if not gameProcessed then
			State.lastRealInputAt = os.clock()
		end
	end))
	track(UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			State.lastRealInputAt = os.clock()
		end
	end))

	spawnTracked(function()
		while State.running do
			task.wait(CONFIG.PulseInterval)
			if State.running then
				PulseLayer.pulse(false)
			end
		end
	end)
end

local JiggleLayer = {}

function JiggleLayer.getRoot()
	local character = LocalPlayer.Character
	if not character then
		return nil, nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
		or (humanoid and humanoid.RootPart)
	return root, humanoid
end

function JiggleLayer.canJiggle()
	local root, humanoid = JiggleLayer.getRoot()
	if not root or not humanoid then
		return false, "no character"
	end
	if humanoid.Health <= 0 then
		return false, "dead"
	end
	if humanoid.Sit then
		return false, "sitting"
	end
	if CONFIG.JiggleOnlyWhenStill and root.AssemblyLinearVelocity.Magnitude > 1 then
		return false, "already moving"
	end
	return true, "ok"
end

function JiggleLayer.jiggle(force)
	if not force then
		local can, reason = JiggleLayer.canJiggle()
		if not can then
			log("jiggle skipped:", reason)
			return false
		end
	end

	local root, humanoid = JiggleLayer.getRoot()
	if not root or not humanoid then
		return false
	end

	local origin = root.CFrame
	local distance = CONFIG.JiggleDistance

	local ok = pcall(function()
		local direction = Vector3.new(math.random() - 0.5, 0, math.random() - 0.5)
		if direction.Magnitude < 0.05 then
			direction = Vector3.new(1, 0, 0)
		end
		direction = direction.Unit

		humanoid:Move(direction, false)
		task.wait(0.18)
		humanoid:Move(Vector3.zero, false)

		if CONFIG.JiggleReturn then
			task.wait(0.12)
			humanoid:Move(-direction, false)
			task.wait(0.18)
			humanoid:Move(Vector3.zero, false)
		end

		if CONFIG.JiggleReturn then
			local current = root.CFrame
			local drift = (current.Position - origin.Position).Magnitude
			if drift > distance * 4 then
				root.CFrame = origin
				log("jiggle drift corrected:", string.format("%.2f studs", drift))
			end
		end
	end)

	if ok then
		State.jiggles = State.jiggles + 1
		State.lastJiggleAt = os.clock()
		log("world jiggle done (total:", State.jiggles, ")")
	end
	return ok
end

function JiggleLayer.start()
	spawnTracked(function()
		while State.running do
			task.wait(CONFIG.JiggleInterval)
			if State.running and CONFIG.UseWorldJiggle then
				if not PulseLayer.userRecentlyActive() then
					JiggleLayer.jiggle(false)
				end
			end
		end
	end)
end

local Watchdog = {}

function Watchdog.tick(reason)
	local killed, stubborn, status = IdledKiller.sweep()
	local armed = VirtualLayer.arm()

	if status == "ok" then
		State.mode = armed and "hybrid" or "getconnections"
	else
		State.mode = armed and "virtualuser" or "broken"
	end

	local report = string.format("%s|%d|%d|%s", State.mode, killed, stubborn, status)
	if report ~= State.lastReport then
		State.lastReport = report
		log(reason, "| mode:", State.mode, "| killed:", killed, "| stubborn:", stubborn)
	end

	if State.mode == "broken" then
		warnLog("ВСЕ СЛОИ НЕ СРАБОТАЛИ — антиафк не активен!")
	end

	return State.mode
end

function Watchdog.start()
	spawnTracked(function()
		while State.running do
			task.wait(CONFIG.WatchdogInterval)
			if State.running then
				Watchdog.tick("watchdog")
			end
		end
	end)
end

local AntiAFK = {}
AntiAFK.Config = CONFIG
AntiAFK.Version = "2.0"

function AntiAFK:Status()
	local now = os.clock()
	return {
		running = State.running,
		mode = State.mode,
		uptime = now - State.startedAt,
		hasGetConnections = State.hasGetConnections,
		connectionsKilled = State.killedTotal,
		stubborn = State.stubborn,
		virtualUserAlive = VirtualLayer.isAlive(),
		idledFires = State.idledFires,
		lastIdledAgo = State.lastIdledAt > 0 and (now - State.lastIdledAt) or -1,
		pulses = State.pulses,
		lastPulseAgo = State.lastPulseAt > 0 and (now - State.lastPulseAt) or -1,
		jiggles = State.jiggles,
		jiggleEnabled = CONFIG.UseWorldJiggle,
		secondsSinceRealInput = now - State.lastRealInputAt,
	}
end

function AntiAFK:Print()
	local s = self:Status()
	print("==================== ANTI-AFK v" .. AntiAFK.Version .. " ====================")
	print("  Состояние    :", s.running and "АКТИВЕН" or "ОСТАНОВЛЕН")
	print("  Режим        :", s.mode)
	print("  Время работы :", fmtTime(s.uptime))
	print("  getconnections:", s.hasGetConnections and "есть" or "НЕТ (только VirtualUser)")
	print("  Убито Idled   :", s.connectionsKilled, "| упрямых:", s.stubborn)
	print("  VirtualUser   :", s.virtualUserAlive and "жив" or "не активен")
	print("  Idled сработал:", s.idledFires, "раз")
	print("  Импульсов     :", s.pulses, s.lastPulseAgo >= 0 and ("(" .. fmtTime(s.lastPulseAgo) .. " назад)") or "")
	print("  Jiggle        :", s.jiggleEnabled and ("вкл, выполнен " .. s.jiggles .. " раз") or "выкл")
	print("  Без ввода     :", fmtTime(s.secondsSinceRealInput))
	print("===========================================================")
	return s
end

function AntiAFK:Test()
	print("[AntiAFK] тест: дёргаю все слои...")
	local mode = Watchdog.tick("manual test")
	PulseLayer.pulse(true)
	if CONFIG.UseWorldJiggle then
		JiggleLayer.jiggle(true)
	end
	print("[AntiAFK] тест завершён, режим:", mode)
	return self:Print()
end

function AntiAFK:SetJiggle(enabled)
	CONFIG.UseWorldJiggle = enabled and true or false
	notify("Anti-AFK", "World jiggle: " .. (CONFIG.UseWorldJiggle and "вкл" or "выкл"))
	return CONFIG.UseWorldJiggle
end

function AntiAFK:SetDebug(enabled)
	CONFIG.Debug = enabled and true or false
	return CONFIG.Debug
end

function AntiAFK:Stop()
	if not State.running then
		return false
	end
	State.running = false

	for _, thread in ipairs(State.threads) do
		pcall(task.cancel, thread)
	end
	table.clear(State.threads)

	for _, connection in ipairs(State.connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	table.clear(State.connections)

	VirtualLayer.disarm()
	local restored = IdledKiller.restore()

	State.mode = "stopped"
	notify("Anti-AFK", "Отключён. Восстановлено соединений: " .. restored)
	print("[AntiAFK] остановлен, восстановлено соединений:", restored)
	return true
end

local function bootstrap()
	local env = (type(getgenv) == "function") and getgenv() or nil
	if env then
		local previous = env[CONFIG.GlobalName]
		if type(previous) == "table" and type(previous.Stop) == "function" then
			pcall(function()
				previous:Stop()
			end)
			print("[AntiAFK] старый экземпляр остановлен")
		end
	end

	State.running = true
	State.startedAt = os.clock()
	State.hasGetConnections = IdledKiller.isAvailable()

	Watchdog.tick("init")

	Watchdog.start()
	PulseLayer.start()
	JiggleLayer.start()

	track(LocalPlayer.CharacterAdded:Connect(function()
		task.defer(function()
			if State.running then
				Watchdog.tick("respawn")
			end
		end)
	end))

	track(UserInputService.WindowFocused:Connect(function()
		State.lastRealInputAt = os.clock()
	end))
	track(UserInputService.WindowFocusReleased:Connect(function()
		if State.running then
			task.defer(function()
				Watchdog.tick("focus lost")
			end)
		end
	end))

	if env then
		env[CONFIG.GlobalName] = AntiAFK
	end

	local layers = {}
	if State.mode == "hybrid" or State.mode == "getconnections" then
		table.insert(layers, "IdledKiller")
	end
	if VirtualLayer.isAlive() then
		table.insert(layers, "VirtualUser")
	end
	if CONFIG.UseInputPulse then
		table.insert(layers, "Pulse")
	end
	if CONFIG.UseWorldJiggle then
		table.insert(layers, "Jiggle")
	end

	local summary = table.concat(layers, " + ")
	if summary == "" then
		summary = "НЕТ АКТИВНЫХ СЛОЁВ"
	end

	print("[AntiAFK] v" .. AntiAFK.Version .. " запущен | слои: " .. summary)
	if env then
		print("[AntiAFK] управление: " .. CONFIG.GlobalName .. ":Print() / :Test() / :Stop()")
	end
	notify("Anti-AFK v" .. AntiAFK.Version, "Активен: " .. summary)
end

bootstrap()

return AntiAFK
