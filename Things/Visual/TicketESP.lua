if _G.TicketsEspScriptLoaded then
    print("✅ Tickets ESP уже запущен!")
    return
end

_G.TicketsEspScriptLoaded = true
_G.EspTickets = _G.EspTickets or false  -- вкл/выкл через эту переменную

local RunService = game:GetService("RunService")
local highlights = {}  -- [ticketModel] = BillboardGui

local function isTicket(model)
    if not model or not model:IsA("Model") then return false end
    return model.Parent and model.Parent.Name == "Tickets" and 
           model:FindFirstChild("HumanoidRootPart")
end

local function createESP(ticket)
    if highlights[ticket] then return end

    local root = ticket:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Создаём BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "TicketESP"
    billboard.Adornee = root
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 80, 0, 80)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = root

    -- Иконка (можно заменить на свою)
    local image = Instance.new("ImageLabel")
    image.Name = "Icon"
    image.Size = UDim2.new(1, 0, 1, 0)
    image.BackgroundTransparency = 1
    image.Image = "rbxassetid://6031097225"  -- золотая звезда/тикета иконка
    image.ImageColor3 = Color3.fromRGB(255, 215, 0)  -- золотой цвет
    image.Parent = billboard

    -- Красная обводка
    local stroke = Instance.new("UIStroke")
    stroke.Name = "EspStroke"
    stroke.Color = Color3.fromRGB(255, 0, 0)
    stroke.Thickness = 2.5
    stroke.Transparency = 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = image

    -- Текст с дистанцией
    local distanceText = Instance.new("TextLabel")
    distanceText.Name = "Distance"
    distanceText.Size = UDim2.new(1, 0, 0, 20)
    distanceText.Position = UDim2.new(0, 0, 1, 5)
    distanceText.BackgroundTransparency = 1
    distanceText.TextColor3 = Color3.fromRGB(255, 255, 255)
    distanceText.TextStrokeTransparency = 0
    distanceText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distanceText.TextScaled = true
    distanceText.Font = Enum.Font.GothamBold
    distanceText.Parent = billboard

    highlights[ticket] = billboard
end

local function removeESP(ticket)
    if highlights[ticket] then
        highlights[ticket]:Destroy()
        highlights[ticket] = nil
    end
end

local function updateTicketsESP()
    local ticketsFolder = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild("Tickets")
    if not ticketsFolder then return end

    -- Добавляем ESP на новые тикеты
    for _, ticket in ipairs(ticketsFolder:GetChildren()) do
        if isTicket(ticket) then
            if _G.EspTickets then
                createESP(ticket)
            else
                removeESP(ticket)
            end
        end
    end

    -- Обновляем дистанцию и чистим удалённые
    for ticket, billboard in pairs(highlights) do
        if not ticket.Parent or not isTicket(ticket) then
            removeESP(ticket)
        else
            -- Обновляем текст дистанции
            local root = ticket:FindFirstChild("HumanoidRootPart")
            local lpRoot = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if root and lpRoot and billboard:FindFirstChild("Distance") then
                local dist = math.floor((root.Position - lpRoot.Position).Magnitude)
                billboard.Distance.Text = dist .. " studs"
            end
        end
    end
end

-- Основной цикл
RunService.Heartbeat:Connect(function()
    if not _G.EspTickets then
        -- Выключаем всё
        for ticket, _ in pairs(highlights) do
            removeESP(ticket)
        end
        return
    end

    updateTicketsESP()
end)

print("✅ Tickets ESP успешно загружен!")
print("   Управление:  _G.EspTickets = true / false")
