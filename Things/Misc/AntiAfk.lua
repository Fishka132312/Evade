local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
if not player then
	player = Players.PlayerAdded:Wait()
end

local function disableIdledConnections()
	if typeof(getconnections) ~= "function" then
		return false
	end

	local ok, connections = pcall(getconnections, player.Idled)
	if not ok or type(connections) ~= "table" then
		return false
	end

	local disabled = 0
	for _, connection in pairs(connections) do
		local success = pcall(function()
			if connection.Disable then
				connection:Disable()
			elseif typeof(connection.Disable) == "function" then
				connection.Disable(connection)
			elseif connection.Disconnect then
				connection:Disconnect()
			elseif typeof(connection.Disconnect) == "function" then
				connection.Disconnect(connection)
			end
		end)

		if success then
			disabled += 1
		end
	end

	return disabled > 0
end

local function virtualUserFallback()
	player.Idled:Connect(function()
		pcall(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end)
	end)
end

local usedGetConnections = disableIdledConnections()

if not usedGetConnections then
	virtualUserFallback()
	warn("[AntiAFK] getconnections unavailable -> VirtualUser fallback")
else
	print("[AntiAFK] Idled connections disabled via getconnections")
end

task.spawn(function()
	while task.wait(30) do
		if typeof(getconnections) == "function" then
			disableIdledConnections()
		end
	end
end)

print("[AntiAFK] enabled | platform:", player:GetMouse() and "PC/Mouse" or "Mobile/Other")
