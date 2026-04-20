local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

-- CONFIG
local rotationSpeed = 2
local attractionRadius = 100
local enabled = true

local partsPerRing = 8
local radius = 10

local ringsConfig = {
    {tilt = math.rad(0)},
    {tilt = math.rad(15)},
    {tilt = math.rad(-15)},
    {tilt = math.rad(45)},
    {tilt = math.rad(-45)},
}

local controlled = {}
local connections = {}

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "ThronePro"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 180)
frame.Position = UDim2.new(0, 20, 0.5, -90)
frame.BackgroundColor3 = Color3.new(0,0,0)

-- DRAG
local dragging = false
local dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- UI helpers
local function label(text, y)
    local l = Instance.new("TextLabel", frame)
    l.Size = UDim2.new(1,0,0,30)
    l.Position = UDim2.new(0,0,0,y)
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.fromRGB(0,255,0)
    l.Font = Enum.Font.Code
    l.TextScaled = true
    l.Text = text
    return l
end

local function button(text, x, y, callback)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0,40,0,30)
    b.Position = UDim2.new(0,x,0,y)
    b.Text = text
    b.BackgroundColor3 = Color3.new(0,0,0)
    b.TextColor3 = Color3.fromRGB(0,255,0)
    b.Font = Enum.Font.Code
    b.TextScaled = true
    b.MouseButton1Click:Connect(callback)
    return b
end

-- CONTROLES
local speedLabel = label("Speed: "..rotationSpeed, 30)
button("+",150,30,function()
    rotationSpeed += 0.5
    speedLabel.Text = "Speed: "..rotationSpeed
end)
button("-",190,30,function()
    rotationSpeed -= 0.5
    speedLabel.Text = "Speed: "..rotationSpeed
end)

local rangeLabel = label("Range: "..attractionRadius, 70)
button("+",150,70,function()
    attractionRadius += 50
    rangeLabel.Text = "Range: "..attractionRadius
end)
button("-",190,70,function()
    attractionRadius -= 50
    rangeLabel.Text = "Range: "..attractionRadius
end)

-- ON OFF
local toggleBtn = button("ON", 20, 110, function()
    enabled = not enabled
    toggleBtn.Text = enabled and "ON" or "OFF"
end)

-- MINIMIZAR
local minimized = false
local minBtn = button("-", 170, 0, function()
    minimized = not minimized
    for _, v in pairs(frame:GetChildren()) do
        if v:IsA("TextLabel") or v:IsA("TextButton") then
            if v ~= minBtn and v ~= closeBtn then
                v.Visible = not minimized
            end
        end
    end
end)

-- CERRAR TODO
local closeBtn = button("X", 200, 0, function()
    enabled = false
    
    for _, c in pairs(connections) do
        pcall(function() c:Disconnect() end)
    end
    
    for _, d in pairs(controlled) do
        if d.align then d.align:Destroy() end
    end
    
    gui:Destroy()
end)

-- PARTES
local function updateParts()
    controlled = {}
    local found = {}

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v.Anchored then
            local dist = (v.Position - root.Position).Magnitude
            if dist <= attractionRadius then
                table.insert(found, v)
            end
        end
    end

    local index = 1
    for r, cfg in ipairs(ringsConfig) do
        for i = 1, partsPerRing do
            local part = found[index]
            if not part then break end

            local align = Instance.new("AlignPosition")
            align.MaxForce = 1e7
            align.Responsiveness = 40
            align.Parent = part

            local att = Instance.new("Attachment", part)
            align.Attachment0 = att

            table.insert(controlled, {
                part = part,
                align = align,
                angle = (i/partsPerRing)*math.pi*2,
                tilt = cfg.tilt
            })

            index += 1
        end
    end
end

task.spawn(function()
    while true do
        task.wait(2)
        if enabled then
            updateParts()
        end
    end
end)

-- MOVIMIENTO
table.insert(connections, RunService.Heartbeat:Connect(function(dt)
    if not enabled then return end
    
    local baseCF = root.CFrame
    
    for _, data in ipairs(controlled) do
        data.angle += rotationSpeed * dt
        
        local circle = CFrame.new(
            math.cos(data.angle)*radius,
            0,
            math.sin(data.angle)*radius
        )
        
        local tiltCF = CFrame.Angles(data.tilt,0,0)
        local spin = CFrame.Angles(0,data.angle*0.5,0)
        
        local finalCF = baseCF * spin * tiltCF * circle
        data.align.Position = finalCF.Position
    end
end))
