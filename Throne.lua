local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

-- CONFIG
local config = {
    radius = 30,
    height = 10,
    speed = 2,
    force = 200
}

local enabled = false
local parts = {}

-- NETWORK (CLAVE)
pcall(function()
    RunService.Heartbeat:Connect(function()
        sethiddenproperty(player, "SimulationRadius", math.huge)
    end)
end)

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "ThroneUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 260)
frame.Position = UDim2.new(0, 20, 0.5, -130)
frame.BackgroundColor3 = Color3.fromRGB(0,0,0)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(0,255,0)
stroke.Thickness = 2

-- DRAG
local dragging, dragStart, startPos

frame.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = i.Position
        startPos = frame.Position
    end
end)

UIS.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - dragStart
        frame.Position = startPos + UDim2.new(0,delta.X,0,delta.Y)
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- UI CONTROL
local function createControl(name, y, key)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.4,0,0,30)
    label.Position = UDim2.new(0,10,0,y)
    label.Text = name
    label.TextColor3 = Color3.fromRGB(0,255,0)
    label.BackgroundTransparency = 1

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(0.3,0,0,30)
    box.Position = UDim2.new(0.4,0,0,y)
    box.Text = tostring(config[key])

    local plus = Instance.new("TextButton", frame)
    plus.Size = UDim2.new(0.1,0,0,30)
    plus.Position = UDim2.new(0.72,0,0,y)
    plus.Text = "+"

    local minus = Instance.new("TextButton", frame)
    minus.Size = UDim2.new(0.1,0,0,30)
    minus.Position = UDim2.new(0.84,0,0,y)
    minus.Text = "-"

    plus.MouseButton1Click:Connect(function()
        config[key] += 5
        box.Text = config[key]
    end)

    minus.MouseButton1Click:Connect(function()
        config[key] -= 5
        box.Text = config[key]
    end)

    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then config[key] = n end
        box.Text = config[key]
    end)
end

createControl("Radius", 20, "radius")
createControl("Height", 70, "height")
createControl("Speed", 120, "speed")
createControl("Force", 170, "force")

-- TOGGLE
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.5,0,0,40)
toggle.Position = UDim2.new(0.25,0,1,-50)
toggle.Text = "OFF"

toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggle.Text = enabled and "ON" or "OFF"
end)

-- PARTES
local function getParts()
    parts = {}
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v.Anchored and not v:IsDescendantOf(character) then
            table.insert(parts, v)
        end
    end
end

task.spawn(function()
    while true do
        task.wait(3)
        if enabled then
            getParts()
        end
    end
end)

-- ANILLOS REALES
local function getRingPosition(index, total, tilt)
    local angle = (index/total)*math.pi*2
    local base = Vector3.new(
        math.cos(angle)*config.radius,
        0,
        math.sin(angle)*config.radius
    )
    local rot = CFrame.Angles(tilt, 0, 0)
    return (rot * base)
end

RunService.Heartbeat:Connect(function(dt)
    if not enabled then return end

    local total = #parts
    if total == 0 then return end

    local t = tick() * config.speed

    for i,part in ipairs(parts) do
        if part and part.Parent then
            
            part.CanCollide = false
            
            local ring = i % 3

            local tilt =
                ring == 0 and 0 or
                ring == 1 and math.rad(45) or
                math.rad(-45)

            local pos = getRingPosition(i, total/3, tilt)

            local spin = CFrame.Angles(0, t, 0)
            local final = root.Position + (spin * pos)

            local dir = (final - part.Position).Unit
            part.Velocity = dir * config.force
        end
    end
end)
