local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local config = {
    radius = 35,
    height = 12,
    speed = 2,
    force = 600
}

local enabled = false
local parts = {}
local t = 0

pcall(function()
    RunService.Heartbeat:Connect(function()
        sethiddenproperty(player, "SimulationRadius", math.huge)
    end)
end)

-- ===== UI PRO =====
local gui = Instance.new("ScreenGui")
gui.Name = "ThroneUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 300)
frame.Position = UDim2.new(0, 20, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
frame.BorderSizePixel = 0

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(0,255,0)
stroke.Thickness = 2
stroke.Transparency = 0.1

-- Top bar
local top = Instance.new("Frame", frame)
top.Size = UDim2.new(1, 0, 0, 32)
top.BackgroundColor3 = Color3.fromRGB(5,5)
top.BorderSizePixel = 0
Instance.new("UICorner", top).CornerRadius = UDim.new(0,14)

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "THRONE PRO"
title.TextColor3 = Color3.fromRGB(0,255,0)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

local function topBtn(txt, x)
    local b = Instance.new("TextButton", top)
    b.Size = UDim2.new(0, 26, 0, 26)
    b.Position = UDim2.new(1, x, 0, 3)
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(0,0,0)
    b.TextColor3 = Color3.fromRGB(0,255,0)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    return b
end

local close = topBtn("X", -30)
local mini = topBtn("-", -60)

-- drag
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

-- controles
local function createControl(name, y, key)
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.38,0,28)
    lbl.Position = UDim2.new(0,15,0,y)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(0,255,0)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(0.26,0,0,28)
    box.Position = UDim2.new(0.40,0,0,y)
    box.Text = tostring(config[key])
    box.BackgroundColor3 = Color3.fromRGB(10,10)
    box.TextColor3 = Color3.fromRGB(0,255,0)
    box.Font = Enum.Font.Code
    box.TextSize = 14
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)

    local function style(btn)
        btn.BackgroundColor3 = Color3.fromRGB(0,30,0)
        btn.TextColor3 = Color3.fromRGB(0,255,0)
        btn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    end

    local plus = Instance.new("TextButton", frame)
    plus.Size = UDim2.new(0.12,0,0,28)
    plus.Position = UDim2.new(0.68,0,0,y)
    plus.Text = "+"
    style(plus)

    local minus = Instance.new("TextButton", frame)
    minus.Size = UDim2.new(0.12,0,0,28)
    minus.Position = UDim2.new(0.82,0,0,y)
    minus.Text = "-"
    style(minus)

    plus.MouseButton1Click:Connect(function()
        config[key] = config[key] + 5
        box.Text = tostring(config[key])
    end)
    minus.MouseButton1Click:Connect(function()
        config[key] = config[key] - 5
        box.Text = tostring(config[key])
    end)
    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then config[key] = n end
        box.Text = tostring(config[key])
    end)
end

createControl("Radius", 50, "radius")
createControl("Height", 90, "height")
createControl("Speed", 130, "speed")
createControl("Force", 170, "force")

-- toggle
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.9,0,0,38)
toggle.Position = UDim2.new(0.05,0,1,-50)
toggle.Text = "OFF"
toggle.BackgroundColor3 = Color3.fromRGB(0,25,0)
toggle.TextColor3 = Color3.fromRGB(0,255,0)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 18
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,8)
local tstroke = Instance.new("UIStroke", toggle)
tstroke.Color = Color3.fromRGB(0,255,0)
tstroke.Thickness = 1

toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggle.Text = enabled and "ON" or "OFF"
end)

local minimized = false
mini.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _,v in pairs(frame:GetChildren()) do
        if v ~= top and not v:IsA("UICorner") and not v:IsA("UIStroke") then
            v.Visible = not minimized
        end
    end
    frame.Size = minimized and UDim2.new(0,280,0,32) or UDim2.new(0,280,0,300)
end)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- PARTES
local function getParts()
    parts = {}
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v.Anchored and not v:IsDescendantOf(character) and not (v.Parent and v.Parent:FindFirstChild("Humanoid")) then
            v.CanCollide = false
            pcall(function() v.CustomPhysicalProperties = PhysicalProperties.new(0,0,0) end)
            table.insert(parts, v)
        end
    end
end

task.spawn(function()
    while true do
        task.wait(2)
        if enabled then getParts() end
    end
end)

player.CharacterAdded:Connect(function(char)
    character = char
    root = char:WaitForChild("HumanoidRootPart")
end)

-- ANILLOS
local function getRingPos(i, total, tilt)
    local ang = (i/total) * math.pi * 2
    local base = Vector3.new(math.cos(ang)*config.radius, 0, math.sin(ang)*config.radius)
    return CFrame.Angles(tilt,0,0) * base
end

RunService.Heartbeat:Connect(function(dt)
    if not enabled or not root then return end
    t = t + dt * config.speed

    local total = #parts
    if total == 0 then return end
    local perRing = math.ceil(total/3)
    local spin = CFrame.Angles(0, t, 0)

    for i,part in ipairs(parts) do
        if part.Parent then
            local ring = (i-1) % 3
            local idx = math.floor((i-1)/3) + 1
            local tilt = ring == 0 and 0 or ring == 1 and math.rad(45) or math.rad(-45)

            local pos = getRingPos(idx, perRing, tilt)
            local finalPos

            -- SOLO EL ANILLO DEL MEDIO GIRA
            if ring == 0 then
                finalPos = root.Position + Vector3.new(0, config.height, 0) + (spin * pos)
            else
                finalPos = root.Position + Vector3.new(0, config.height, 0) + pos
            end

            local dir = finalPos - part.Position
            if dir.Magnitude > 0.5 then
                part.AssemblyLinearVelocity = dir.Unit * config.force
            end
        end
    end
end)
