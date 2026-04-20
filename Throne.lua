local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local character, root

-- CONFIG (cámbialo aquí si quieres)
local config = {
    radius = 60,
    height = 15,
    rotationSpeed = 2, -- grados por frame
    attractionStrength = 600,
    spinSpeed = 1
}

local enabled = false
local parts = {}
local partRings = {}
local ringCounter = 0

-- COLORES
local BLACK = Color3.fromRGB(0,0,0)
local GREEN = Color3.fromRGB(0,255,0) -- verde chillón
local DARK = Color3.fromRGB(10,10)

-- Mantener simulación
pcall(function()
    RunService.Heartbeat:Connect(function()
        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
    end)
end)

-- GUI SIMPLE
local gui = Instance.new("ScreenGui")
gui.Name = "ThroneUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, 240, 0, 100)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = BLACK
frame.BorderSizePixel = 0

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = GREEN
stroke.Thickness = 2
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "THRONE PRO"
title.TextColor3 = GREEN
title.Font = Enum.Font.GothamBold
title.TextSize = 18

local toggle = Instance.new("TextButton")
toggle.Parent = frame
toggle.Size = UDim2.new(0, 200, 0, 40)
toggle.Position = UDim2.new(0, 20, 0, 45)
toggle.Text = "OFF"
toggle.BackgroundColor3 = DARK
toggle.TextColor3 = GREEN
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 18

local tcorner = Instance.new("UICorner")
tcorner.CornerRadius = UDim.new(0, 8)
tcorner.Parent = toggle

toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    if enabled then
        toggle.Text = "ON"
    else
        toggle.Text = "OFF"
    end
end)

-- Personaje
local function onChar(char)
    character = char
    root = char:WaitForChild("HumanoidRootPart")
end
LocalPlayer.CharacterAdded:Connect(onChar)
if LocalPlayer.Character then onChar(LocalPlayer.Character) end

-- Preparar partes
local function canUse(p)
    return p:IsA("BasePart") and not p.Anchored and p:IsDescendantOf(workspace) and (not character or not p:IsDescendantOf(character)) and (not p.Parent or not p.Parent:FindFirstChild("Humanoid"))
end

local function prepare(p)
    if p:GetAttribute("Ready") then return end
    p:SetAttribute("Ready", true)
    p.CanCollide = false
    p.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0)
    partRings[p] = ringCounter % 3
    ringCounter = ringCounter + 1
end

local function addPart(p)
    if canUse(p) then
        prepare(p)
        table.insert(parts, p)
    end
end

for _,p in ipairs(workspace:GetDescendants()) do addPart(p) end
workspace.DescendantAdded:Connect(addPart)

-- LOOP PRINCIPAL
RunService.Heartbeat:Connect(function()
    if not enabled then return end
    if not root then return end

    local center = root.Position
    for _,part in ipairs(parts) do
        if part.Parent and canUse(part) then
            local ring = partRings[part] or 0
            local tilt = 0
            if ring == 1 then tilt = math.rad(45) end
            if ring == 2 then tilt = math.rad(-45) end

            local angle = math.atan2(part.Position.Z - center.Z, part.Position.X - center.X)
            local newAngle = angle + math.rad(config.rotationSpeed)

            local offset = Vector3.new(math.cos(newAngle) * config.radius, 0, math.sin(newAngle) * config.radius)
            local target = center + Vector3.new(0, config.height, 0) + (CFrame.Angles(tilt, 0, 0) * offset)

            local dir = target - part.Position
            if dir.Magnitude > 1 then
                part.Velocity = dir.Unit * config.attractionStrength
            end
            part.AssemblyAngularVelocity = Vector3.new(0, config.spinSpeed * 10, 0)
        end
    end
end)
