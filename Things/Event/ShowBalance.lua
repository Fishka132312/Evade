local GEN = (_G.__CashTrackerGen or 0) + 1
_G.__CashTrackerGen = GEN

if _G.__CashTrackerGui then
	pcall(function() _G.__CashTrackerGui:Destroy() end)
end
if _G.__CashTrackerConn then
	pcall(function() _G.__CashTrackerConn:Disconnect() end)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if _G.ShowBalance == nil then
	_G.ShowBalance = false
end

local WARMUP_SECONDS = 5
local MAX_GAIN_PER_PICKUP = 10
local PICKUP_WINDOW = 0.45

local function parseCash(text)
	if not text then return nil end

	local s = tostring(text)
	local mult = 1
	local up = s:upper()
	if up:find("K") then mult = 1e3
	elseif up:find("M") then mult = 1e6
	elseif up:find("B") then mult = 1e9
	end

	local clean = s:gsub("[^%d%.,]", "")
	if clean == "" then return nil end

	if mult > 1 then
		clean = clean:gsub(",", ".")
	else
		clean = clean:gsub("[%.,]", "")
	end

	local n = tonumber(clean)
	if not n then return nil end
	return n * mult
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BubbleTrackerGui_" .. GEN
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.Parent = PlayerGui
_G.__CashTrackerGui = screenGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 230, 0, 190)
frame.Position = UDim2.new(0, 20, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1.5
stroke.Transparency = 0.1
stroke.Parent = frame

local strokeGradient = Instance.new("UIGradient")
strokeGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 170, 255)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160, 120, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 170, 255)),
})
strokeGradient.Rotation = 45
strokeGradient.Parent = stroke

local bgGradient = Instance.new("UIGradient")
bgGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 22, 30)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 14, 20)),
})
bgGradient.Rotation = 90
bgGradient.Parent = frame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundTransparency = 1
titleBar.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -16, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🫧 Bubble Tracker"
title.TextColor3 = Color3.fromRGB(235, 235, 245)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -24, 0, 1)
divider.Position = UDim2.new(0, 12, 0, 32)
divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
divider.BackgroundTransparency = 0.9
divider.BorderSizePixel = 0
divider.Parent = frame

local function makeRow(yPos, icon, labelText, accentColor)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -24, 0, 22)
	row.Position = UDim2.new(0, 12, 0, yPos)
	row.BackgroundTransparency = 1
	row.Parent = frame

	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size = UDim2.new(0.55, 0, 1, 0)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Text = icon .. " " .. labelText
	nameLbl.TextColor3 = Color3.fromRGB(170, 170, 185)
	nameLbl.Font = Enum.Font.Gotham
	nameLbl.TextSize = 12.5
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.Parent = row

	local valueLbl = Instance.new("TextLabel")
	valueLbl.Size = UDim2.new(0.45, 0, 1, 0)
	valueLbl.Position = UDim2.new(0.55, 0, 0, 0)
	valueLbl.BackgroundTransparency = 1
	valueLbl.Text = "0"
	valueLbl.TextColor3 = accentColor
	valueLbl.Font = Enum.Font.GothamBold
	valueLbl.TextSize = 13
	valueLbl.TextXAlignment = Enum.TextXAlignment.Right
	valueLbl.Parent = row

	return valueLbl
end

local currentLabel = makeRow(42, "🫧", "Current", Color3.fromRGB(140, 190, 255))
local farmedLabel  = makeRow(68, "📈", "Farmed", Color3.fromRGB(140, 255, 180))
local perMinLabel  = makeRow(94, "⏱", "Per Minute", Color3.fromRGB(255, 210, 130))
local perHourLabel = makeRow(120, "🕐", "Per Hour", Color3.fromRGB(255, 150, 150))

local reportBtn = Instance.new("TextButton")
reportBtn.Size = UDim2.new(1, -24, 0, 26)
reportBtn.Position = UDim2.new(0, 12, 0, 150)
reportBtn.BackgroundColor3 = Color3.fromRGB(46, 42, 72)
reportBtn.BorderSizePixel = 0
reportBtn.AutoButtonColor = true
reportBtn.Text = "📋 Report"
reportBtn.TextColor3 = Color3.fromRGB(220, 210, 255)
reportBtn.Font = Enum.Font.GothamBold
reportBtn.TextSize = 13
reportBtn.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = reportBtn

local btnStroke = Instance.new("UIStroke")
btnStroke.Thickness = 1
btnStroke.Transparency = 0.5
btnStroke.Color = Color3.fromRGB(160, 130, 255)
btnStroke.Parent = reportBtn

local currentValue = nil
local startBalance = nil
local baselineSet = false
local farmedTotal = 0
local gains = {}
local pickupCounts = {}
local totalPickups = 0

local scriptStart = os.clock()
local startTimestamp = os.time()
local warmupUntil = scriptStart + WARMUP_SECONDS

local pendingAmount = 0
local pendingLastTime = 0

local function formatNum(n)
	n = math.floor((n or 0) + 0.5)
	local formatted = tostring(n)
	local k
	while true do
		formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then break end
	end
	return formatted
end

local function updateGui()
	currentLabel.Text = formatNum(currentValue or 0)
	farmedLabel.Text = formatNum(farmedTotal)

	local now = os.clock()
	local perMin, perHour = 0, 0

	while #gains > 0 and now - gains[1].time >= 3600 do
		table.remove(gains, 1)
	end

	for _, gain in ipairs(gains) do
		local age = now - gain.time
		if age < 60 then
			perMin += gain.amount
		end
		if age < 3600 then
			perHour += gain.amount
		end
	end

	perMinLabel.Text = formatNum(perMin)
	perHourLabel.Text = formatNum(perHour)
end

local function commitGain(amount)
	if amount <= 0 then return end
	if not baselineSet then return end
	if amount > MAX_GAIN_PER_PICKUP then return end

	local rounded = math.floor(amount + 0.5)
	farmedTotal += rounded
	table.insert(gains, {time = os.clock(), amount = rounded})
	pickupCounts[rounded] = (pickupCounts[rounded] or 0) + 1
	totalPickups += 1
end

local function flushPending(force)
	if pendingAmount <= 0 then
		pendingAmount = 0
		return
	end
	if force or (os.clock() - pendingLastTime) >= PICKUP_WINDOW then
		commitGain(pendingAmount)
		pendingAmount = 0
	end
end

local function addDelta(delta)
	if pendingAmount > 0 and (pendingAmount + delta) > MAX_GAIN_PER_PICKUP then
		flushPending(true)
	end
	pendingAmount += delta
	pendingLastTime = os.clock()

	if pendingAmount >= MAX_GAIN_PER_PICKUP then
		flushPending(true)
	end
end

local function onCashText(text)
	local newVal = parseCash(text)
	if not newVal then return end

	if currentValue == nil then
		currentValue = newVal
		startBalance = newVal
		updateGui()
		return
	end

	if os.clock() < warmupUntil then
		currentValue = newVal
		startBalance = newVal
		updateGui()
		return
	end

	if not baselineSet then
		baselineSet = true
		startBalance = startBalance or newVal
	end

	local delta = newVal - currentValue
	currentValue = newVal

	if delta > 0 then
		if delta > MAX_GAIN_PER_PICKUP then
			flushPending(true)
		else
			addDelta(delta)
		end
	elseif delta < 0 then
		flushPending(true)
	end

	updateGui()
end

local function formatDuration(seconds)
	seconds = math.floor(seconds)
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = seconds % 60
	if h > 0 then
		return string.format("%dh %02dm %02ds", h, m, s)
	elseif m > 0 then
		return string.format("%dm %02ds", m, s)
	else
		return string.format("%ds", s)
	end
end

local BAR_SEGMENTS = 16

local function makeBar(pct)
	local filled = math.floor(pct / 100 * BAR_SEGMENTS + 0.5)
	if filled < 0 then filled = 0 end
	if filled > BAR_SEGMENTS then filled = BAR_SEGMENTS end
	return string.rep("█", filled) .. string.rep("░", BAR_SEGMENTS - filled)
end

local function buildReport()
	flushPending(true)

	local nowClock = os.clock()
	local elapsed = math.max(nowClock - scriptStart, 1)
	local avgPerMin = farmedTotal / (elapsed / 60)
	local avgPerHour = farmedTotal / (elapsed / 3600)

	local lines = {}
	local function add(s) table.insert(lines, s) end

	add("╔═══════════════════════════════════════════╗")
	add("║           🫧  BUBBLE TRACKER               ║")
	add("╚═══════════════════════════════════════════╝")
	add("")
	add("⏱  SESSION")
	add("Started      " .. os.date("%d %b %Y · %H:%M:%S", startTimestamp))
	add("Now          " .. os.date("%d %b %Y · %H:%M:%S", os.time()))
	add("Farmed For   " .. formatDuration(elapsed))
	add("")
	add("🎟  TICKETS")
	add("Starting     " .. formatNum(startBalance or 0))
	add("Current      " .. formatNum(currentValue or 0))
	add("Farmed       +" .. formatNum(farmedTotal))
	add("")
	add("📈  RATE")
	add(string.format("Per minute   %.1f", avgPerMin))
	add(string.format("Per hour     %.1f", avgPerHour))
	add("Drops        " .. totalPickups)
	add("")

	local amounts = {}
	for amount in pairs(pickupCounts) do
		table.insert(amounts, amount)
	end
	table.sort(amounts)

	add("──────────────  DROP LOG  ──────────────")
	if totalPickups == 0 then
		add("no drops yet")
	else
		for _, amount in ipairs(amounts) do
			local count = pickupCounts[amount]
			add(string.format("+%-3d ×%-3d →   %s tickets",
				amount, count, formatNum(amount * count)))
		end

		add("")
		add("──────────────  DROP RATE  ─────────────")
		for _, amount in ipairs(amounts) do
			local pct = pickupCounts[amount] / totalPickups * 100
			add(string.format("+%-4d %5.1f%%   %s", amount, pct, makeBar(pct)))
		end
	end

	add("")
	add("════════════════════════════════════════")
	return table.concat(lines, "\n")
end

local function copyToClipboard(text)
	local fn = (setclipboard or toclipboard or set_clipboard or (syn and syn.write_clipboard))
	if fn then
		local ok = pcall(fn, text)
		return ok
	end
	return false
end

reportBtn.MouseButton1Click:Connect(function()
	local report = buildReport()

	print("\n" .. report)

	local copied = copyToClipboard(report)
	local oldText = "📋 Report"
	reportBtn.Text = copied and "✅ Copied" or "⚠️ Check F9"
	task.delay(1.5, function()
		if reportBtn and reportBtn.Parent then
			reportBtn.Text = oldText
		end
	end)
end)

_G.BubbleReport = function()
	local r = buildReport()
	print("\n" .. r)
	copyToClipboard(r)
	return r
end

local function tryGetCashLabel()
	local ok, obj = pcall(function()
		return LocalPlayer.PlayerGui.Game.HUD.Overlay.CharacterStatus.BottomLeft.Tickets.Cash
	end)
	if ok and obj and obj:IsA("TextLabel") then
		return obj
	end
	return nil
end

local activeLabel = nil

task.spawn(function()
	local connectedLabel = nil
	while _G.__CashTrackerGen == GEN do
		local label = tryGetCashLabel()
		if label then
			if label ~= connectedLabel then
				connectedLabel = label
				activeLabel = label
				if _G.__CashTrackerConn then
					pcall(function() _G.__CashTrackerConn:Disconnect() end)
				end
				warmupUntil = os.clock() + WARMUP_SECONDS
				currentValue = nil
				baselineSet = false
				pendingAmount = 0
				onCashText(label.Text)
				_G.__CashTrackerConn = label:GetPropertyChangedSignal("Text"):Connect(function()
					onCashText(label.Text)
				end)
				label.AncestryChanged:Connect(function(_, parent)
					if not parent and connectedLabel == label then
						connectedLabel = nil
						activeLabel = nil
					end
				end)
			end
		else
			connectedLabel = nil
			activeLabel = nil
		end
		task.wait(1)
	end
end)

local heartbeatConn
heartbeatConn = RunService.Heartbeat:Connect(function()
	if _G.__CashTrackerGen ~= GEN then
		heartbeatConn:Disconnect()
		return
	end
	if activeLabel and activeLabel.Parent then
		onCashText(activeLabel.Text)
	end
	flushPending(false)
end)

task.spawn(function()
	while _G.__CashTrackerGen == GEN do
		frame.Visible = (_G.ShowBalance ~= false)
		updateGui()
		task.wait(0.2)
	end
end)

updateGui()
