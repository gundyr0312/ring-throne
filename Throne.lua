local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local character, root

-- CONFIG
local config = {
    radius = 60,
    height = 15,
    rotationSpeed = 0.5, -- velocidad de órbita
    attractionStrength = 400, -- fuerza de atracción
    spinSpeed = 1 -- giro propio
}

local enabled = false
local parts = {}

-- colores pro
local BLACK = Color3.fromRGB(8,8,8)
local GREEN = Color3.fromRGB(0,255,140)
local DARK = Color3.fromRGB(0,40,20)

-- mantener simulación
pcall(function()
    RunService.Heartbeat:Connect(function()
        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
    end)
end)

-- ========= GUI THRONE PRO MEJORADA =========
local gui = Instance.new("ScreenGui")
gui.Name = "ThroneUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,270,0,320)
frame.Position = UDim2.new(0,20,0.5,-160)
frame.BackgroundColor3 = BLACK
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)
local stroke = Instance.new("UIStroke", frame)
stroke.Color = GREEN
stroke.Thickness = 2
stroke.Transparency = 0.1

local top = Instance.new("Frame", frame)
top.Size = UDim2.new(1,0,0,34)
top.BackgroundColor3 = Color3.fromRGB(12,12,12)
top.BorderSizePixel = 0
Instance.new("UICorner", top).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1,-70,1,0)
title.Position = UDim2.new(0,10,0,0)
title.BackgroundTransparency = 1
title.Text = "THRONE PRO"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = GREEN
title.TextXAlignment = Enum.TextXAlignment.Left

local function btn(txt, pos)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,28,0,28)
    b.Position = pos
    b.Text = txt
    b.BackgroundColor3 = BLACK
    b.TextColor3 = GREEN
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    b.Parent = top
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    return b
end

local close = btn("X", UDim2.new(1,-30,0,3))
local mini = btn("-", UDim2.new(1,-60,0,3))

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
        frame.Position = startPos + UDim2.new(0, i.Position.X-dragStart.X, 0, i.Position.Y-dragStart.Y)
    end
end)
UIS.InputEnded:Connect(function() dragging = false end)

local function createControl(name, y, key, step)
    local lbl = Instance.new("TextLabel", frame)
    lbl.Position = UDim2.new(0,15,0,y)
    lbl.Size = UDim2.new(0.35,0,0,28)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = GREEN
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 15
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox", frame)
    box.Position = UDim2.new(0.38,0,0,y)
    box.Size = UDim2.new(0.26,0,0,28)
    box.Text = tostring(config[key])
    box.BackgroundColor3 = DARK
    box.TextColor3 = GREEN
    box.Font = Enum.Font.Code
    box.TextSize = 15
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)

    local plus = Instance.new("TextButton", frame)
    plus.Position = UDim2.new(0.67,0,0,y)
    plus.Size = UDim2.new(0.12,0,0,28)
    plus.Text = "+"
    plus.BackgroundColor3 = DARK
    plus.TextColor3 = GREEN
    plus.Font = Enum.Font.GothamBold
    Instance.new("UICorner", plus).CornerRadius = UDim.new(0,6)

    local minus = Instance.new("TextButton", frame)
    minus.Position = UDim2.new(0.82,0,0,y)
    minus.Size = UDim2.new(0.12,0,0,28)
    minus.Text = "-"
    minus.BackgroundColor3 = DARK
    minus.TextColor3 = GREEN
    minus.Font = Enum.Font.GothamBold
    Instance.new("UICorner", minus).CornerRadius = UDim.new(0,6)

    local function update(v)
        config[key] = v
        box.Text = string.format("%.2f", v)
    end
    plus.MouseButton1Click:Connect(function() update(config[key]+step) end)
    minus.MouseButton1Click:Connect(function() update(math.max(0.1, config[key]-step)) end)
    box.FocusLost:Connect(function() local n=tonumber(box.Text) if n then update(n) end end)
end

createControl("Radius", 55, "radius", 5)
createControl("Height", 95, "height", 2)
createControl("Speed", 135, "rotationSpeed", 0.1)
createControl("Force", 175, "attractionStrength", 20)
createControl("Spin", 215, "spinSpeed", 0.2)

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.9,0,0,38)
toggle.Position = UDim2.new(0.05,0,1,-50)
toggle.Text = "OFF"
toggle.BackgroundColor3 = DARK
toggle.TextColor3 = GREEN
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 18
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", toggle).Color = GREEN

toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggle.Text = enabled and "ON" or "OFF"
end)

local minimized = false
mini.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _,v in pairs(frame:GetChildren()) do
        if v~=top and not v:IsA("UICorner") and not v:IsA("UIStroke") then
            v.Visible = not minimized
        end
    end
    frame.Size = minimized and UDim2.new(0,270,0,34) or UDim2.new(0,270,0,320)
end)
close.MouseButton1Click:Connect(function() enabled=false gui:Destroy() end)

-- ========= LÓGICA DE PARTES (del V6) =========
local function onChar(char)
    character = char
    root = char:WaitForChild("HumanoidRootPart")
end
LocalPlayer.CharacterAdded:Connect(onChar)
if LocalPlayer.Character then onChar(LocalPlayer.Character) end

local function canUse(part)
    return part:IsA("BasePart") and not part.Anchored and part:IsDescendantOf(workspace)
        and not part:IsDescendantOf(character) and not part.Parent:FindFirstChild("Humanoid")
end

local function prepare(part)
    if part:GetAttribute("ThroneReady") then return end
    part:SetAttribute("ThroneReady", true)
    part.CanCollide = false
    part.CustomPhysicalProperties = PhysicalProperties.new(0,0,0) -- sin masa = no cae
end

local function addPart(p) if canUse(p) then prepare(p) if not table.find(parts,p) then table.insert(parts,p) end end end
local function remPart(p) local i=table.find(parts,p) if i then table.remove(parts,i) end end

for _,p in pairs(workspace:GetDescendants()) do addPart(p) end
workspace.DescendantAdded:Connect(addPart)
workspace.DescendantRemoving:Connect(remPart)

-- ========= LOOP PRINCIPAL 3 ANILLOS =========
RunService.Heartbeat:Connect(function()
    if not enabled or not root then return end
    local center = root.Position
    local total = #parts
    if total == 0 then return end

    local rings = 3
    for i, part in ipairs(parts) do
        if part.Parent and canUse(part) then
            -- balanceo
            local ring = (i-1) % rings
            local indexInRing = math.floor((i-1)/rings)
            local perRing = math.ceil(total/rings)
            local angle = (indexInRing / perRing) * math.pi*2 + tick()*config.rotationSpeed

            local tilt = ring==0 and 0 or ring==1 and math.rad(45) or math.rad(-45)
            local offset = Vector3.new(math.cos(angle)*config.radius, 0, math.sin(angle)*config.radius)
            local targetPos = center + Vector3.new(0, config.height, 0) + (CFrame.Angles(tilt,0,0) * offset)

            local dir = targetPos - part.Position
            if dir.Magnitude > 0.1 then
                part.Velocity = dir.Unit * config.attractionStrength -- del V6
            end
            -- giro propio lento
            part.AssemblyAngularVelocity = Vector3.new(0, config.spinSpeed*8, 0)
        end
    end
end)
