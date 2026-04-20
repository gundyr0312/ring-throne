print("THRONE DELTA OK")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

local cfg = {radius = 35, height = 12, speed = 2.5, force = 700}
local on = false
local parts = {}
local data = {}
local t = 0

-- network
pcall(function()
    RunService.Heartbeat:Connect(function()
        sethiddenproperty(plr, "SimulationRadius", math.huge)
    end)
end)

-- UI
local gui = Instance.new("ScreenGui")
gui.Name = "ThroneUI"
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 280, 0, 260)
main.Position = UDim2.new(0, 20, 0.5, -130)
main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
main.BorderSizePixel = 0
main.Active = true

local c = Instance.new("UICorner", main)
c.CornerRadius = UDim.new(0, 16)

local s = Instance.new("UIStroke", main)
s.Color = Color3.fromRGB(0, 255, 0)
s.Thickness = 2

local top = Instance.new("Frame", main)
top.Size = UDim2.new(1, 0, 0, 32)
top.BackgroundColor3 = Color3.fromRGB(10, 10)
top.BorderSizePixel = 0
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 16)

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "THRONE PRO"
title.TextColor3 = Color3.fromRGB(0, 255, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

local function topBtn(txt, x)
    local b = Instance.new("TextButton", top)
    b.Size = UDim2.new(0, 26, 0, 26)
    b.Position = UDim2.new(1, x, 0, 3)
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    b.TextColor3 = Color3.fromRGB(0, 255, 0)
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local close = topBtn("X", -30)
local mini = topBtn("-", -62)

-- drag
local dragging, ds, sp
top.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        ds = i.Position
        sp = main.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - ds
        main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function() dragging = false end)

-- controles simples
local function ctrl(name, y, k)
    local l = Instance.new("TextLabel", main)
    l.Position = UDim2.new(0, 15, 0, y)
    l.Size = UDim2.new(0, 70, 0, 26)
    l.BackgroundTransparency = 1
    l.Text = name
    l.TextColor3 = Color3.fromRGB(0, 255, 0)
    l.Font = Enum.Font.Gotham
    l.TextSize = 14
    l.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox", main)
    box.Position = UDim2.new(0, 90, 0, y)
    box.Size = UDim2.new(0, 60, 0, 26)
    box.Text = tostring(cfg[k])
    box.BackgroundColor3 = Color3.fromRGB(15, 15)
    box.TextColor3 = Color3.fromRGB(0, 255, 0)
    box.ClearTextOnFocus = false
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

    local p = Instance.new("TextButton", main)
    p.Position = UDim2.new(0, 160, 0, y)
    p.Size = UDim2.new(0, 26, 0, 26)
    p.Text = "+"
    p.BackgroundColor3 = Color3.fromRGB(0, 40, 0)
    p.TextColor3 = Color3.fromRGB(0, 255, 0)
    Instance.new("UICorner", p).CornerRadius = UDim.new(0, 6)

    local m = Instance.new("TextButton", main)
    m.Position = UDim2.new(0, 192, 0, y)
    m.Size = UDim2.new(0, 26, 0, 26)
    m.Text = "-"
    m.BackgroundColor3 = Color3.fromRGB(0, 40, 0)
    m.TextColor3 = Color3.fromRGB(0, 255, 0)
    Instance.new("UICorner", m).CornerRadius = UDim.new(0, 6)

    p.MouseButton1Click:Connect(function() cfg[k] = cfg[k] + 5 box.Text = cfg[k] end)
    m.MouseButton1Click:Connect(function() cfg[k] = math.max(5, cfg[k]-5) box.Text = cfg[k] end)
end

ctrl("Radius", 50, "radius")
ctrl("Height", 85, "height")
ctrl("Speed", 120, "speed")
ctrl("Force", 155, "force")

local toggle = Instance.new("TextButton", main)
toggle.Size = UDim2.new(1, -40, 0, 38)
toggle.Position = UDim2.new(0, 20, 1, -52)
toggle.Text = "ACTIVAR"
toggle.BackgroundColor3 = Color3.fromRGB(0, 30, 0)
toggle.TextColor3 = Color3.fromRGB(0, 255, 0)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 18
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 10)

toggle.MouseButton1Click:Connect(function()
    on = not on
    toggle.Text = on and "DESACTIVAR" or "ACTIVAR"
end)

local minimized = false
mini.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _,v in pairs(main:GetChildren()) do
        if v ~= top and v.ClassName ~= "UICorner" and v.ClassName ~= "UIStroke" then
            v.Visible = not minimized
        end
    end
    main.Size = minimized and UDim2.new(0,280,0,32) or UDim2.new(0,280,0,260)
end)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

plr.CharacterAdded:Connect(function(c)
    char = c
    root = c:WaitForChild("HumanoidRootPart")
end)

-- partes
local function add(p)
    if not p:IsA("BasePart") then return end
    if p.Anchored then return end
    if not p:IsDescendantOf(workspace) then return end
    if p.Parent and p.Parent:FindFirstChild("Humanoid") then return end
    if char and p:IsDescendantOf(char) then return end
    if data[p] then return end

    p.CanCollide = false
    pcall(function() p.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0) end)
    data[p] = {ring = #parts % 3, slot = math.floor(#parts/3)}
    table.insert(parts, p)
end

for _,v in ipairs(workspace:GetDescendants()) do add(v) end
workspace.DescendantAdded:Connect(add)

RunService.Heartbeat:Connect(function(dt)
    if not on or not root then return end
    t = t + dt * cfg.speed
    local spin = CFrame.Angles(0, t, 0)
    local center = root.Position + Vector3.new(0, cfg.height, 0)

    for _,p in ipairs(parts) do
        local d = data[p]
        if p.Parent and d then
            local tilt = d.ring == 0 and 0 or d.ring == 1 and math.rad(45) or math.rad(-45)
            local ang = (d.slot/12) * math.pi*2
            local base = Vector3.new(math.cos(ang)*cfg.radius, 0, math.sin(ang)*cfg.radius)
            local pos = CFrame.Angles(tilt,0,0) * base

            local target
            if d.ring == 0 then -- SOLO MEDIO GIRA
                target = center + (spin * pos)
            else
                target = center + pos
            end

            local dir = target - p.Position
            if dir.Magnitude > 1 then
                p.AssemblyLinearVelocity = dir.Unit * cfg.force
            end
        end
    end
end)
