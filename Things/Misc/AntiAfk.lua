local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
if not player then
	repeat task.wait() until Players.LocalPlayer
	player = Players.LocalPlayer
end

local CONFIG = {
	RetrySeconds = 60,
	AlsoUseVirtualUser = true,
	Notify = true,
	Debug = false,
}

local state = {
	mode = "none",
	lastCount = -1,
	ownConnection = nil,
}

local ownHandler

local function log(...)
	if CONFIG.Debug then
		print("[AntiAFK]", ...)
	end
end

local function notify(title, text)
	if not CONFIG.Notify then return end
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = title,
			Text = text,
			Duration = 4,
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

local function isOwnConnection(connection)
	if not ownHandler then
		return false
	end
	if connection == state.ownConnection then
		return true
	end
	return safeIndex(connection, "Function") == ownHandler
end

local function isDead(connection)
	local enabled = safeIndex(connection, "Enabled")
	if enabled == false then
		return true
	end
	local connected = safeIndex(connection, "Connected")
	if connected == false then
		return true
	end
	return false
end

local function killConnection(connection)
	for _, name in ipairs({ "Disable", "disable", "Disconnect", "disconnect" }) do
		local fn = safeIndex(connection, name)
		if type(fn) == "function" then
			if pcall(fn, connection) then
				return true
			end
		end
	end

	local ok = pcall(function()
		if safeIndex(connection, "Enabled") ~= nil then
			connection.Enabled = false
		end
	end)
	return ok and isDead(connection)
end

local function disableIdledConnections()
	if type(getconnections) ~= "function" then
		return 0, 0, "no_getconnections"
	end

	local ok, connections = pcall(getconnections, player.Idled)
	if not ok or type(connections) ~= "table" then
		return 0, 0, "getconnections_error"
	end

	local killed, alive = 0, 0
	for _, connection in pairs(connections) do
		local t = typeof(connection)
		if t == "table" or t == "userdata" then
			if isOwnConnection(connection) then
				if isDead(connection) then
					state.ownConnection = nil
					ownHandler = nil
				end
			elseif not isDead(connection) then
				if killConnection(connection) then
					killed += 1
				else
					alive += 1
				end
			end
		end
	end

	return killed, alive, "ok"
end

local function setupVirtualUserFallback()
	if ownHandler and state.ownConnection and not isDead(state.ownConnection) then
		return
	end

	ownHandler = function()
		pcall(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end)
		log("idled -> virtual input sent")
	end

	local ok, conn = pcall(function()
		return player.Idled:Connect(ownHandler)
	end)
	state.ownConnection = ok and conn or nil
	log("virtualuser fallback armed")
end

local function apply(reason)
	local killed, alive, status = disableIdledConnections()

	if status == "ok" then
		state.mode = CONFIG.AlsoUseVirtualUser and "hybrid" or "getconnections"
		if CONFIG.AlsoUseVirtualUser then
			setupVirtualUserFallback()
		end
	else
		state.mode = "virtualuser"
		setupVirtualUserFallback()
	end

	if killed ~= state.lastCount then
		state.lastCount = killed
		log(reason, "| killed:", killed, "| stubborn:", alive, "| mode:", state.mode, "| status:", status)
	end

	return killed
end

apply("init")
notify("Anti Idle", "Anti idle is enabled (" .. state.mode .. ")")

task.spawn(function()
	while task.wait(CONFIG.RetrySeconds) do
		apply("retry")
	end
end)

player.CharacterAdded:Connect(function()
	task.defer(apply, "character")
end)
