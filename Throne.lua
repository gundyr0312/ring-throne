local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character, root

-- CONFIG por defecto
local config = {
    radius = 60,
    height = 15,
    speed = 0.5,
    force = 400,
    spinSpeed = 1
}

local enabled = false
local minimized = false
local parts = {}

-- Colores pro
local BLACK = Color3.fromRGB(8,8,8)
local GREEN = Color3.fromRGB(0,255,140)
local DARK_GREEN = Color3.fromRGB(0,40,20)

pcall(function()
    RunService.Heartbeat:Connect(function()
        sethiddenproperty(player, "SimulationRadius", math.huge)
    end)
end)

--================ GUI =================--
local function setupGUI()
    if player.PlayerGui:FindFirstChild("ThroneUI") then
        player.PlayerGui.ThroneUI:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "ThroneUI"
    gui.ResetOnSpawn = false
    gui.Parent = player.PlayerGui

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 270, 0, 310)
    frame.Position = UDim2.new(0, 20, 0.5, -155)
    frame.BackgroundColor3 = BLACK
    frame.BorderSizePixel = 0

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0,12)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = GREEN
    stroke.Thickness = 2
    stroke.Transparency = 0.2

    -- Top bar
    local top = Instance.new("Frame", frame)
    top.Size = UDim2.new(1,0,0,34)
    top.BackgroundColor3 = Color3.fromRGB(12,12,12)
    top.BorderSizePixel = 0
    Instance.new("UICorner", top).CornerRadius = UDim.new(0,12)

    local title = Instance.new("TextLabel", top)
    title.Size = UDim2.new(1,-70,1,0)
    title.Position = UDim2.new(0,10,0,0)
    title.Text = "THRONE PRO"
    title.TextColor3 = GREEN
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left

    local function makeBtn(parent, txt, pos)
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(0,30,0,30)
        b.Position = pos
        b.Text = txt
        b.BackgroundColor3 = BLACK
        b.TextColor3 = GREEN
        b.Font = Enum.Font.GothamBold
        b.TextSize = 18
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
        b.MouseEnter:Connect(function() b.BackgroundColor3 = DARK_GREEN end)
        b.MouseLeave:Connect(function() b.BackgroundColor3 = BLACK end)
        return b
    end

    local close = makeBtn(top, "X", UDim2.new(1,-32,0,2))
    local mini = makeBtn(top, "-", UDim2.new(1,-64,0,2))

    -- Drag
    local dragging, dragStart, startPos
    top.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
            startPos = frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            frame.Position = startPos + UDim2.new(0, i.Position.X - dragStart.X, 0, i.Position.Y - dragStart.Y)
        end
    end)
    UIS.InputEnded:Connect(function() dragging = false end)

    local function createControl(name, y, key, step)
        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(0.35,0,0,30)
        label.Position = UDim2.new(0,15,0,y)
        label.Text = name
        label.TextColor3 = GREEN
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.TextSize = 16
        label.TextXAlignment = Enum.TextXAlignment.Left

        local box = Instance.new("TextBox", frame)
        box.Size = UDim2.new(0.28,0,0,28)
        box.Position = UDim2.new(0.38,0,0,y+1)
        box.Text = tostring(config[key])
        box.BackgroundColor3 = DARK_GREEN
        box.TextColor3 = GREEN
        box.Font = Enum.Font.Code
        box.TextSize = 16
        Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)

        local plus = makeBtn(frame, "+", UDim2.new(0.7,0,0,y+1))
        local minus = makeBtn(frame, "-", UDim2.new(0.84,0,0,y+1))

        plus.MouseButton1Click:Connect(function() config[key] += step box.Text = string.format("%.2f", config[key]) end)
        minus.MouseButton1Click:Connect(function() config[key] = math.max(step, config[key]-step) box.Text = string.format("%.2f", config[key]) end)
        box.FocusLost:Connect(function() local n=tonumber(box.Text) if n then config[key]=n end box.Text = string.format("%.2f", config[key]) end)
    end

    createControl("Radius", 55, "radius", 5)
    createControl("Height", 95, "height", 2)
    createControl("Speed", 135, "speed", 0.1)
    createControl("Force", 175, "force", 20)
    createControl("Spin", 215, "spinSpeed", 0.2)

    local toggle = Instance.new("TextButton", frame)
    toggle.Size = UDim2.new(0.9,0,0,38)
    toggle.Position = UDim2.new(0.05,0,1,-48)
    toggle.Text = "OFF"
    toggle.BackgroundColor3 = DARK_GREEN
    toggle.TextColor3 = GREEN
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 20
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,8)
    local tstroke = Instance.new("UIStroke", toggle)
    tstroke.Color = GREEN
    tstroke.Thickness = 1.5

    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggle.Text = enabled and "ON" or "OFF"
        toggle.BackgroundColor3 = enabled and Color3.fromRGB(0,60,30) or DARK_GREEN
    end)

    mini.MouseButton1Click:Connect(function()
        minimized = not minimized
        for _,v in pairs(frame:GetChildren()) do
            if v ~= top and v ~= corner and v ~= stroke then
                v.Visible = not minimized
            end
        end
        frame.Size = minimized and UDim2.new(0,270,0,34) or UDim2.new(0,270,0,310)
    end)

    close.MouseButton1Click:Connect(function()
        enabled = false
        gui:Destroy()
    end)
end

setupGUI()

-- Character
local function onChar(char)
    character = char
    root = char:WaitForChild("HumanoidRootPart")
end
player.CharacterAdded:Connect(onChar)
if player.Character then onChar(player.Character) end

-- Preparar parte
local function prep(part)
    if part:FindFirstChild("ThroneAP") then return end
    part.CanCollide = false
    part.CustomPhysicalProperties = PhysicalProperties.new(0,0,0)

    local att = Instance.new("Attachment", part)
    att.Name = "ThroneAtt"

    local ap = Instance.new("AlignPosition", part)
    ap.Name = "ThroneAP"
    ap.Attachment0 = att
    ap.Mode = Enum.PositionAlignmentMode.OneAttachment
    ap.MaxForce = 1e9
    ap.MaxVelocity = 1e9
    ap.Responsiveness = 35

    local ao = Instance.new("AlignOrientation", part)
    ao.Name = "ThroneAO"
    ao.Attachment0 = att
    ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
    ao.MaxTorque = 1e9
    ao.Responsiveness = 25
end

local function getParts()
    parts = {}
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v.Anchored and v.Parent and not v:IsDescendantOf(character) and not v:FindFirstAncestorOfClass("Accessory") then
            if (v.Position - root.Position).Magnitude < config.radius * 3 then
                table.insert(parts, v)
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(2.5)
        if enabled and root then getParts() end
    end
end)

-- Loop principal
RunService.Heartbeat:Connect(function()
    if not enabled or not root then return end

    local t = tick() * config.speed
    local total = #parts
    if total == 0 then return end

    local rings = 3
    local perRing = math.floor(total / rings)

    for i, part in ipairs(parts) do
        if part and part.Parent then
            prep(part)

            local ringIndex = (i-1) % rings
            local indexInRing = math.floor((i-1)/rings)
            local totalInRing = perRing + (indexInRing < total % rings and 1 or 0)
            if totalInRing == 0 then totalInRing = 1 end

            local tilt = ringIndex == 0 and 0 or ringIndex == 1 and math.rad(45) or math.rad(-45)
            local angle = (indexInRing / totalInRing) * math.pi * 2 + t

            local offset = Vector3.new(math.cos(angle)*config.radius, 0, math.sin(angle)*config.radius)
            local worldPos = root.Position + Vector3.new(0, config.height, 0) + (CFrame.Angles(tilt,0,0) * offset)

            part.ThroneAP.Position = worldPos
            part.ThroneAP.Responsiveness = config.force / 10

            -- rotación propia lenta en su eje
            local spin = CFrame.Angles(0, tick()*config.spinSpeed*2, 0)
            part.ThroneAO.CFrame = CFrame.Angles(tilt,0,0) * spin
        end
    end
end)
