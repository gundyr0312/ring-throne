local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

local cfg = {radius = 32, height = 12, speed = 2.5, force = 700}
local on = false
local parts = {}
local data = {} -- [part] = {ring, slot}
local t = 0

pcall(function()
    RunService.Heartbeat:Connect(function()
        sethiddenproperty(plr, "SimulationRadius", math.huge)
    end)
end)

-- ===== UI PRO =====
local gui = Instance.new("ScreenGui")
gui.Name = "ThroneUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = plr:WaitForChild("PlayerGui")

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 300, 0, 320)
main.Position = UDim2.new(0, 25, 0.5, -160)
main.BackgroundColor3 = Color3.fromRGB(8,8)
main.BorderSizePixel = 0
main.Active = true

local mc = Instance.new("UICorner", main)
mc.CornerRadius = UDim.new(0, 18)

local ms = Instance.new("UIStroke", main)
ms.Color = Color3.fromRGB(0,255,0)
ms.Thickness = 2
ms.Transparency = 0.15

local grad = Instance.new("UIGradient", main)
grad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(12,12)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0))
}
grad.Rotation = 90

-- top bar
local top = Instance.new("Frame", main)
top.Size = UDim2.new(1,0,36)
top.BackgroundColor3 = Color3.fromRGB(0,0,0)
top.BackgroundTransparency = 0.2
top.BorderSizePixel = 0
Instance.new("UICorner", top).CornerRadius = UDim.new(0,18)

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1,-80,1,0)
title.Position = UDim2.new(0,14,0,0)
title.BackgroundTransparency = 1
title.Text = "THRONE PRO"
title.TextColor3 = Color3.fromRGB(0,255,0)
title.Font = Enum.Font.GothamBlack
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left

local function topBtn(txt, x)
    local b = Instance.new("TextButton", top)
    b.Size = UDim2.new(0,28,0,28)
    b.Position = UDim2.new(1, x, 0, 4)
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(15,15,15)
    b.TextColor3 = Color3.fromRGB(0,255,0)
    b.AutoButtonColor = false
    b.Font = Enum.Font.GothamBold
    b.TextSize = 18
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    local s = Instance.new("UIStroke", b)
    s.Color = Color3.fromRGB(0,255,0)
    s.Transparency = 0.6
    b.MouseEnter:Connect(function() b.BackgroundColor3 = Color3.fromRGB(0,40,0) end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = Color3.fromRGB(15,15) end)
    return b
end

local close = topBtn("×", -32)
local mini = topBtn("–", -66)

-- drag
local drag, startP, startM
top.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = true
        startP = i.Position
        startM = main.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - startP
        main.Position = UDim2.new(startM.X.Scale, startM.X.Offset + d.X, startM.Y.Scale, startM.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function() drag = false end)

-- controles
local function ctrl(name, y, key)
    local l = Instance.new("TextLabel", main)
    l.Position = UDim2.new(0,18,0,y)
    l.Size = UDim2.new(0,80,0,28)
    l.BackgroundTransparency = 1
    l.Text = name
    l.TextColor3 = Color3.fromRGB(0,255,0)
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 14
    l.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox", main)
    box.Position = UDim2.new(0,100,0,y)
    box.Size = UDim2.new(0,70,0,28)
    box.Text = tostring(cfg[key])
    box.BackgroundColor3 = Color3.fromRGB(18,18,18)
    box.TextColor3 = Color3.fromRGB(0,255,0)
    box.ClearTextOnFocus = false
    box.Font = Enum.Font.Code
    box.TextSize = 14
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke", box).Color = Color3.fromRGB(0,255,0)

    local function btn(txt, x)
        local b = Instance.new("TextButton", main)
        b.Position = UDim2.new(0,x,0,y)
        b.Size = UDim2.new(0,28,0,28)
        b.Text = txt
        b.BackgroundColor3 = Color3.fromRGB(0,35,0)
        b.TextColor3 = Color3.fromRGB(0,255,0)
        b.Font = Enum.Font.GothamBold
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
        return b
    end
    local plus = btn("+", 180)
    local minus = btn("-", 218)

    plus.MouseButton1Click:Connect(function() cfg[key] = cfg[key] + 5 box.Text = cfg[key] end)
    minus.MouseButton1Click:Connect(function() cfg[key] = math.max(5, cfg[key]-5) box.Text = cfg[key] end)
    box.FocusLost:Connect(function() local n=tonumber(box.Text) if n then cfg[key]=n box.Text=n end)
end

ctrl("Radius", 55, "radius")
ctrl("Height", 95, "height")
ctrl("Speed", 135, "speed")
ctrl("Force", 175, "force")

local toggle = Instance.new("TextButton", main)
toggle.Size = UDim2.new(1,-40,0,44)
toggle.Position = UDim2.new(0,20,1,-60)
toggle.Text = "ACTIVAR"
toggle.BackgroundColor3 = Color3.fromRGB(0,25,0)
toggle.TextColor3 = Color3.fromRGB(0,255,0)
toggle.AutoButtonColor = false
toggle.Font = Enum.Font.GothamBlack
toggle.TextSize = 20
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,12)
local tg = Instance.new("UIStroke", toggle)
tg.Color = Color3.fromRGB(0,255,0)
tg.Thickness = 2

toggle.MouseButton1Click:Connect(function()
    on = not on
    toggle.Text = on and "DESACTIVAR" or "ACTIVAR"
    toggle.BackgroundColor3 = on and Color3.fromRGB(0,60,0) or Color3.fromRGB(0,25,0)
end)

local minimized = false
mini.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _,v in pairs(main:GetChildren()) do
        if v ~= top and v ~= mc and v ~= ms and v ~= grad then
            v.Visible = not minimized
        end
    end
    main.Size = minimized and UDim2.new(0,300,0,36) or UDim2.new(0,300,0,320)
end)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- no cerrar al morir
plr.CharacterAdded:Connect(function(c)
    char = c
    root = c:WaitForChild("HumanoidRootPart")
end)

-- PARTES
local function add(p)
    if not p:IsA("BasePart") or p.Anchored or not p:IsDescendantOf(workspace) then return end
    if p.Parent and p.Parent:FindFirstChild("Humanoid") then return end
    if char and p:IsDescendantOf(char) then return end
    if data[p] then return end

    p.CanCollide = false
    pcall(function() p.CustomPhysicalProperties = PhysicalProperties.new(0,0) end)

    local id = #parts
    data[p] = {ring = id % 3, slot = math.floor(id/3)}
    table.insert(parts, p)
end

for _,v in ipairs(workspace:GetDescendants()) do add(v) end
workspace.DescendantAdded:Connect(add)

local function posFor(slot, total, tilt)
    local a = (slot/total) * math.pi * 2
    local base = Vector3.new(math.cos(a)*cfg.radius, 0, math.sin(a)*cfg.radius)
    return CFrame.Angles(tilt,0,0) * base
end

RunService.Heartbeat:Connect(function(dt)
    if not on or not root then return end
    t = t + dt * cfg.speed
    local spin = CFrame.Angles(0, t, 0)
    local center = root.Position + Vector3.new(0, cfg.height, 0)

    for _,p in ipairs(parts) do
        local d = data[p]
        if p.Parent and d then
            local tilt = d.ring == 0 and 0 or d.ring == 1 and math.rad(45) or math.rad(-45)
            local basePos = posFor(d.slot, 20, tilt) -- 20 slots por anillo

            local target
            if d.ring == 0 then -- SOLO EL DEL MEDIO GIRA
                target = center + (spin * basePos)
            else -- los otros 2 estáticos
                target = center + basePos
            end

            local dir = target - p.Position
            if dir.Magnitude > 1 then
                p.AssemblyLinearVelocity = dir.Unit * cfg.force
            end
        end
    end
end)
