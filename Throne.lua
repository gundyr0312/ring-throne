local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local config = {radius = 35, height = 12, speed = 2, force = 600}
local enabled = false
local parts = {}
local t = 0

-- SISTEMA V6
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

-- GUI MEJORADA
local gui = Instance.new("ScreenGui")
gui.Name = "ThroneUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 300)
frame.Position = UDim2.new(0, 20, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(8,8,8)
frame.BorderSizePixel = 0
frame.ClipsDescendants = true

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0,12)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(0,255,120)
stroke.Thickness = 2
stroke.Transparency = 0.3

-- BARRA SUPERIOR
local titleBar = Instance.new("Frame", frame)
titleBar.Size = UDim2.new(1,0,0,32)
titleBar.BackgroundColor3 = Color3.fromRGB(0,18,0)
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1,-70,1,0)
title.Position = UDim2.new(0,12,0,0)
title.BackgroundTransparency = 1
title.Text = "THRONE // RING"
title.TextColor3 = Color3.fromRGB(0,255,120)
title.Font = Enum.Font.GothamBlack
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", titleBar)
minBtn.Size = UDim2.new(0,24,0,24)
minBtn.Position = UDim2.new(1,-56,0.5,-12)
minBtn.Text = "-"
minBtn.BackgroundColor3 = Color3.fromRGB(0,35,0)
minBtn.TextColor3 = Color3.fromRGB(0,255,120)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0,6)

local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0,24,0,24)
closeBtn.Position = UDim2.new(1,-28,0.5,-12)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(35,0,0)
closeBtn.TextColor3 = Color3.fromRGB(0,255,120)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,6)

-- DRAG
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(i)
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

-- CONTROLES
local function createControl(name, y, key)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.35,0,0,28)
    label.Position = UDim2.new(0,15,0,y)
    label.Text = name
    label.TextColor3 = Color3.fromRGB(0,255,120)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(0.25,0,0,26)
    box.Position = UDim2.new(0.38,0,0,y+1)
    box.Text = tostring(config[key])
    box.BackgroundColor3 = Color3.fromRGB(15,15,15)
    box.TextColor3 = Color3.fromRGB(0,255,120)
    box.Font = Enum.Font.Gotham
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)

    local plus = Instance.new("TextButton", frame)
    plus.Size = UDim2.new(0.12,0,0,26)
    plus.Position = UDim2.new(0.66,0,0,y+1)
    plus.Text = "+"
    plus.BackgroundColor3 = Color3.fromRGB(0,45,0)
    plus.TextColor3 = Color3.fromRGB(0,255,120)
    plus.Font = Enum.Font.GothamBold
    Instance.new("UICorner", plus).CornerRadius = UDim.new(0,6)

    local minus = Instance.new("TextButton", frame)
    minus.Size = UDim2.new(0.12,0,0,26)
    minus.Position = UDim2.new(0.81,0,0,y+1)
    minus.Text = "-"
    minus.BackgroundColor3 = Color3.fromRGB(0,45,0)
    minus.TextColor3 = Color3.fromRGB(0,255,120)
    minus.Font = Enum.Font.GothamBold
    Instance.new("UICorner", minus).CornerRadius = UDim.new(0,6)

    plus.MouseButton1Click:Connect(function() config[key] = config[key] + 5 box.Text = config[key] end)
    minus.MouseButton1Click:Connect(function() config[key] = config[key] - 5 box.Text = config[key] end)
    box.FocusLost:Connect(function() local n = tonumber(box.Text) if n then config[key] = n end box.Text = config[key] end)
end

createControl("Radius", 50, "radius")
createControl("Height", 90, "height")
createControl("Speed", 130, "speed")
createControl("Force", 170, "force")

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0.9,0,0,38)
toggle.Position = UDim2.new(0.05,0,1,-48)
toggle.Text = "OFF"
toggle.BackgroundColor3 = Color3.fromRGB(0,25,0)
toggle.TextColor3 = Color3.fromRGB(0,255,120)
toggle.Font = Enum.Font.GothamBlack
toggle.TextSize = 16
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", toggle).Color = Color3.fromRGB(0,255,120)

toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggle.Text = enabled and "ON" or "OFF"
    toggle.BackgroundColor3 = enabled and Color3.fromRGB(0,60,0) or Color3.fromRGB(0,25,0)
end)

-- MINIMIZAR Y CERRAR
local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        frame:TweenSize(UDim2.new(0,280,0,32), "Out", "Quad", 0.2, true)
        for _,v in ipairs(frame:GetChildren()) do
            if v ~= titleBar and v ~= stroke and v ~= corner then v.Visible = false end
        end
        minBtn.Text = "+"
    else
        frame:TweenSize(UDim2.new(0,280,0,300), "Out", "Quad", 0.2, true)
        for _,v in ipairs(frame:GetChildren()) do v.Visible = true end
        minBtn.Text = "-"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- LÓGICA DE PARTES (igual que antes)
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

task.spawn(function() while true do task.wait(1.5) if enabled then getParts() end end end)
player.CharacterAdded:Connect(function(char) character = char root = char:WaitForChild("HumanoidRootPart") end)

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
