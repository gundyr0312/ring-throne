local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

-- CONFIG
local config = {
    radius = 35,
    height = 12,
    speed = 2,
    force = 600
}

local enabled = false
local parts = {}
local t = 0

-- SISTEMA V6 PARA AGARRAR TODO (invisible)
if not getgenv().Network then
    getgenv().Network = {BaseParts = {}}
    Network.RetainPart = function(Part)
        if Part:IsA("BasePart") and Part:IsDescendantOf(workspace) then
            table.insert(Network.BaseParts, Part)
            Part.CustomPhysicalProperties = PhysicalProperties.new(0,0,0)
            Part.CanCollide = true
        end
    end
end

pcall(function()
    RunService.Heartbeat:Connect(function()
        sethiddenproperty(player, "SimulationRadius", math.huge)
    end)
end)

-- PANEL ORIGINAL NEGRO/VERDE NEON
local gui = Instance.new("ScreenGui")
gui.Name = "ThroneUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 260)
frame.Position = UDim2.new(0, 20, 0.5, -130)
frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
frame.BorderSizePixel = 0

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(0,255,0)
stroke.Thickness = 2

-- drag
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
        frame.Position = startPos + UDim2.new(0, i.Position.X - dragStart.X, 0, i.Position.Y - dragStart.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

local function createControl(name, y, key)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.4,0,0,30)
    label.Position = UDim2.new(0,10,0,y)
    label.Text = name
    label.TextColor3 = Color3.fromRGB(0,255,0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(0.3,0,0,30)
    box.Position = UDim2.new(0.4,0,0,y)
    box.Text = tostring(config[key])
    box.BackgroundColor3 = Color3.fromRGB(10,10,10)
    box.TextColor3 = Color3.fromRGB(0,255,0)
    box.Font = Enum.Font.Gotham

    local plus = Instance.new("TextButton", frame)
    plus.Size = UDim2.new(0.1,0,0,30)
    plus.Position = UDim2.new(0.72,0,0,y)
    plus.Text = "+"
    plus.BackgroundColor3 = Color3.fromRGB(0,40,0)
    plus.TextColor3 = Color3.fromRGB(0,255,0)
    plus.Font = Enum.Font.GothamBold

    local minus = Instance.new("TextButton", frame)
    minus.Size = UDim2.new(0.1,0,0,30)
    minus.Position = UDim2.new(0.84,0,0,y)
    minus.Text = "-"
    minus.BackgroundColor3 = Color3.fromRGB(0,40,0)
    minus.TextColor3 = Color3.fromRGB(0,255,0)
    minus.Font = Enum.Font.GothamBold

    plus.MouseButton1Click:Connect(function() config[key] = config[key] + 5 box.Text = config[key] end)
    minus.MouseButton1Click:Connect(function() config[key] = config[key] - 5 box.Text = config[key] end)
    box.FocusLost:Connect(function() local n = tonumber(box.Text) if n then config[key] = n end box.Text = config[key] end)
end

createControl("Radius", 20, "radius")
createControl("Height", 70, "height")
createControl("Speed", 120, "speed")
createControl("Force", 170, "force")

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.5,0,0,40)
toggle.Position = UDim2.new(0.25,0,1,-50)
toggle.Text = "OFF"
toggle.BackgroundColor3 = Color3.fromRGB(0,30,0)
toggle.TextColor3 = Color3.fromRGB(0,255,0)
toggle.Font = Enum.Font.GothamBold

toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggle.Text = enabled and "ON" or "OFF"
end)

-- AGARRE TIPO V6
local function RetainPart(v)
    if v:IsA("BasePart") and not v.Anchored and v:IsDescendantOf(workspace) then
        if v:IsDescendantOf(character) then return false end
        if v.Parent and v.Parent:FindFirstChildOfClass("Humanoid") then return false end
        if v.Name == "Handle" then return false end
        return true
    end
    return false
end

local function getParts()
    parts = {}
    for _,v in pairs(workspace:GetDescendants()) do
        if RetainPart(v) then
            Network.RetainPart(v)
            table.insert(parts, v)
        end
    end
end

task.spawn(function()
    while true do
        task.wait(1.5)
        if enabled then getParts() end
    end
end)

player.CharacterAdded:Connect(function(char)
    character = char
    root = char:WaitForChild("HumanoidRootPart")
end)

local function getRingPosition(i,total,tilt)
    local angle = (i/total) * math.pi * 2
    local base = Vector3.new(math.cos(angle)*config.radius, 0, math.sin(angle)*config.radius)
    return CFrame.Angles(tilt,0,0) * base
end

RunService.Heartbeat:Connect(function(dt)
    if not enabled or not root then return end
    t = t + dt * config.speed
    local total = #parts
    if total == 0 then return end
    local perRing = math.ceil(total/3)
    local spin = CFrame.Angles(0,t,0)

    for i,part in ipairs(parts) do
        if part.Parent and not part.Anchored then
            local ring = (i-1) % 3
            local idx = math.floor((i-1)/3)+1
            local tilt = ring==0 and 0 or ring==1 and math.rad(45) or math.rad(-45)
            local pos = getRingPosition(idx, perRing, tilt)
            local target = root.Position + Vector3.new(0,config.height,0) + (ring==0 and spin*pos or pos)
            local dir = target - part.Position
            part.Velocity = dir * (config.force/25)
        end
    end
end)
