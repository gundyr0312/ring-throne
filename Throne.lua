local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

-- CONFIG
local config = {
    radius = 50,
    speed = 5,
    force = 200
}

local enabled = false
local parts = {}

-- ================= GUI =================

local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "ThroneUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 220)
frame.Position = UDim2.new(0, 20, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(0,0,0)

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

-- CREAR CONTROL
local function createControl(text, y, key)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1,0,0,25)
    label.Position = UDim2.new(0,0,0,y)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(0,255,0)
    label.Text = text
    label.Font = Enum.Font.Code
    label.TextScaled = true

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(0,80,0,30)
    box.Position = UDim2.new(0.3,0,0,y+25)
    box.Text = tostring(config[key])
    box.BackgroundColor3 = Color3.fromRGB(20,20,20)
    box.TextColor3 = Color3.fromRGB(0,255,0)

    local plus = Instance.new("TextButton", frame)
    plus.Size = UDim2.new(0,40,0,30)
    plus.Position = UDim2.new(0.65,0,0,y+25)
    plus.Text = "+"
    plus.BackgroundColor3 = Color3.fromRGB(0,0,0)
    plus.TextColor3 = Color3.fromRGB(0,255,0)

    local minus = Instance.new("TextButton", frame)
    minus.Size = UDim2.new(0,40,0,30)
    minus.Position = UDim2.new(0.82,0,0,y+25)
    minus.Text = "-"
    minus.BackgroundColor3 = Color3.fromRGB(0,0,0)
    minus.TextColor3 = Color3.fromRGB(0,255,0)

    plus.MouseButton1Click:Connect(function()
        config[key] += 10
        box.Text = tostring(config[key])
    end)

    minus.MouseButton1Click:Connect(function()
        config[key] -= 10
        box.Text = tostring(config[key])
    end)

    box.FocusLost:Connect(function()
        local num = tonumber(box.Text)
        if num then
            config[key] = num
        end
        box.Text = tostring(config[key])
    end)
end

createControl("Radius", 10, "radius")
createControl("Speed", 70, "speed")
createControl("Force", 130, "force")

-- TOGGLE
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0,100,0,30)
toggle.Position = UDim2.new(0.3,0,1,-40)
toggle.Text = "OFF"
toggle.BackgroundColor3 = Color3.fromRGB(50,0,0)
toggle.TextColor3 = Color3.fromRGB(0,255,0)

toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggle.Text = enabled and "ON" or "OFF"
end)

-- ================= PARTES =================

local function updateParts()
    parts = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v.Anchored then
            table.insert(parts, v)
        end
    end
end

task.spawn(function()
    while true do
        task.wait(3)
        updateParts()
    end
end)

-- ================= MOVIMIENTO =================

RunService.Heartbeat:Connect(function(dt)
    if not enabled then return end

    for _, part in pairs(parts) do
        if part and part.Parent then
            local offset = part.Position - root.Position
            local dist = offset.Magnitude

            if dist < config.radius then
                local angle = math.atan2(offset.Z, offset.X)
                angle += config.speed * dt

                local target = Vector3.new(
                    root.Position.X + math.cos(angle)*config.radius,
                    root.Position.Y + 5,
                    root.Position.Z + math.sin(angle)*config.radius
                )

                local dir = (target - part.Position).Unit
                part.Velocity = dir * config.force
            end
        end
    end
end)
