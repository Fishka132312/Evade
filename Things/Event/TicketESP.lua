if _G.EspTicketsScriptLoaded then
	return
end
_G.EspTicketsScriptLoaded = true
_G.EspTickets = _G.EspTickets or false

local RunService = game:GetService("RunService")
local ticketsFolder = workspace:WaitForChild("Effects"):WaitForChild("Tickets")
local highlights = {}

local function applyESP(part)
	if highlights[part] then return end
	if not part or not part:IsA("BasePart") then return end
	local hl = Instance.new("Highlight")
	hl.Adornee = part
	hl.FillColor = Color3.fromRGB(0, 100, 255)
	hl.OutlineColor = Color3.fromRGB(0, 170, 255)
	hl.FillTransparency = 0.5
	hl.OutlineTransparency = 0
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Parent = part
	highlights[part] = hl
end

local function removeESP(part)
	if highlights[part] then
		highlights[part]:Destroy()
		highlights[part] = nil
	end
end

local function clearAll()
	for part in pairs(highlights) do
		removeESP(part)
	end
end

local function updateESP()
	if not _G.EspTickets then
		clearAll()
		return
	end
	for _, ticket in ipairs(ticketsFolder:GetChildren()) do
		if ticket.Name == "Visual" then
			for _, desc in ipairs(ticket:GetDescendants()) do
				if desc:IsA("BasePart") then
					applyESP(desc)
				end
			end
		end
	end
	for part in pairs(highlights) do
		if not part.Parent or not part:IsDescendantOf(ticketsFolder) then
			removeESP(part)
		end
	end
end

RunService.Heartbeat:Connect(updateESP)
ticketsFolder.DescendantAdded:Connect(updateESP)
updateESP()
