-- _G.AntiDev = _G.AntiDev or false
-- _G.__AntiDevSession = (_G.__AntiDevSession or 0) + 1

-- local session = _G.__AntiDevSession
-- local Players = game:GetService("Players")
-- local RunService = game:GetService("RunService")

-- local baseline = #Players:GetPlayers()
-- local armed = false

-- local function crash()
-- 	pcall(function()
-- 		Players.LocalPlayer.Character = nil
-- 	end)
-- 	while true do
-- 		local t = {}
-- 		for i = 1, 1e7 do
-- 			t[#t + 1] = string.rep("x", 1024)
-- 		end
-- 	end
-- end

-- local conns = {}

-- local function disconnectAll()
-- 	for _, c in ipairs(conns) do
-- 		pcall(function()
-- 			c:Disconnect()
-- 		end)
-- 	end
-- 	conns = {}
-- end

-- local function onChange()
-- 	if _G.__AntiDevSession ~= session then
-- 		return
-- 	end
-- 	if not _G.AntiDev or not armed then
-- 		return
-- 	end
-- 	if #Players:GetPlayers() ~= baseline then
-- 		crash()
-- 	end
-- end

-- table.insert(conns, Players.PlayerAdded:Connect(onChange))
-- table.insert(conns, Players.PlayerRemoving:Connect(function()
-- 	task.defer(onChange)
-- end))
-- table.insert(conns, Players.ChildAdded:Connect(onChange))
-- table.insert(conns, Players.ChildRemoved:Connect(function()
-- 	task.defer(onChange)
-- end))

-- task.spawn(function()
-- 	while true do
-- 		RunService.Heartbeat:Wait()
-- 		if _G.__AntiDevSession ~= session then
-- 			disconnectAll()
-- 			break
-- 		end
-- 		if _G.AntiDev then
-- 			if not armed then
-- 				baseline = #Players:GetPlayers()
-- 				armed = true
-- 			else
-- 				if #Players:GetPlayers() ~= baseline then
-- 					crash()
-- 				end
-- 			end
-- 		else
-- 			armed = false
-- 			baseline = #Players:GetPlayers()
-- 		end
-- 	end
-- end)
