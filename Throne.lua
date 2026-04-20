--// THRONE PRO FINAL (UI + NETWORK + RINGS)
--// UI: negro + verde neón, bordes, draggable, minimizar, cerrar, ON/OFF
--// Controls: label + textbox (editable) + +/- 
--// Physics: SimulationRadius + velocity control (funciona en la mayoría de juegos)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

--================= NETWORK CONTROL (CLAVE) =================
pcall(function()
    getgenv().Network = getgenv().Network or {BaseParts = {}}
    RunService.Heartbeat:Connect(function()
        -- algunos exploits requieren pcall
        pcall(function()
            sethiddenproperty(player, "SimulationRadius", math.huge)
        end)
    end)
end)

--================= CONFIG =================
local config = {
    radius = 60,        -- radio del anillo
    height = 8,         -- altura base
    speed = 4,          -- velocidad rotación
    force = 300,        -- fuerza de atracción
    rings = 5           -- número de anillos (capas)
}

local enabled = false
local minimized = false

--================= GUI =================
local gui = Instance.new("ScreenGui")
gui.Name = "ThroneProUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 260)
frame.Position = UDim2.new(0, 20, 0.5, -130)
frame.BackgroundColor3 = Color3.fromRGB(5,5,5)
frame.BorderSizePixel = 0

-- borde verde neón
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(0,255,120)
stroke.Thickness = 2

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0,10)

-- título
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,35)
title.BackgroundColor3 = Color3.fromRGB(0,0,0)
title.Text = "THRONE PRO"
title.TextColor3 = Color3.fromRGB(0,255,120)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

local titleStroke = Instance.new("UIStroke", title)
titleStroke.Color = Color3.fromRGB(0,255,120)

-- botones top
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-35,0,3)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(20,0,0)
close.TextColor3 = Color3.fromRGB(0,255,120)
close.Font = Enum.Font.GothamBold
close.TextScaled = true

local mini = Instance.new("TextButton", frame)
mini.Size = UDim2.new(0,30,0,30)
mini.Position = UDim2.new(1,-70,0,3)
mini.Text = "-"
mini.BackgroundColor3 = Color3.fromRGB(0,0,0)
mini.TextColor3 = Color3.fromRGB(0,255,120)
mini.Font = Enum.Font.GothamBold
mini.TextScaled = true

-- draggable
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

-- helper control (label + textbox + +/-)
local function createControl(text, key, y)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1,0,0,20)
    label.Position = UDim2.new(0,0,0,y)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(0,255,120)
    label.Font = Enum.Font.Gotham
    label.TextScaled = true

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(0,90,0,28)
    box.Position = UDim2.new(0.3,0,0,y+20)
    box.Text = tostring(config[key])
    box.BackgroundColor3 = Color3.fromRGB(15,15,15)
    box.TextColor3 = Color3.fromRGB(0,255,120)
    box.Font = Enum.Font.Code
    box.TextScaled = true

    local plus = Instance.new("TextButton", frame)
    plus.Size = UDim2.new(0,30,0,28)
    plus.Position = UDim2.new(0.65,0,0,y+20)
    plus.Text = "+"
    plus.BackgroundColor3 = Color3.fromRGB(0,0,0)
    plus.TextColor3 = Color3.fromRGB(0,255,120)

    local minus = Instance.new("TextButton", frame)
    minus.Size = UDim2.new(0,30,0,28)
    minus.Position = UDim2.new(0.8,0,0,y+20)
    minus.Text = "-"
    minus.BackgroundColor3 = Color3.fromRGB(0,0,0)
    minus.TextColor3 = Color3.fromRGB(0,255,120)

    plus.MouseButton1Click:Connect(function()
        config[key] += 5
        box.Text = tostring(config[key])
    end)

    minus.MouseButton1Click:Connect(function()
        config[key] -= 5
        box.Text = tostring(config[key])
    end)

    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then config[key] = n end
        box.Text = tostring(config[key])
    end)
end

createControl("Radius", "radius", 40)
createControl("Height", "height", 90)
createControl("Speed", "speed", 140)
createControl("Force", "force", 190)

-- toggle
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0,120,0,30)
toggle.Position = UDim2.new(0.5,-60,1,-35)
toggle.Text = "OFF"
toggle.BackgroundColor3 = Color3.fromRGB(40,0,0)
toggle.TextColor3 = Color3.fromRGB(0,255,120)
toggle.Font = Enum.Font.GothamBold
toggle.TextScaled = true

toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggle.Text = enabled and "ON" or "OFF"
    toggle.BackgroundColor3 = enabled and Color3.fromRGB(0,60,0) or Color3.fromRGB(40,0,0)
end)

-- minimizar
mini.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _,v in pairs(frame:GetChildren()) do
        if v:IsA("GuiObject") and v ~= title and v ~= mini and v ~= close then
            v.Visible = not minimized
        end
    end
    frame.Size = minimized and UDim2.new(0,300,0,40) or UDim2.new(0,300,0,260)
end)

-- cerrar
close.MouseButton1Click:Connect(function()
    enabled = false
    gui:Destroy()
end)

--================= PARTES =================
local parts = {}

local function refreshParts()
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
            refreshParts()
        end
    end
end)

--================= MOVIMIENTO (ANILLOS) =================
RunService.Heartbeat:Connect(function(dt)
    if not enabled then return end

    for i,part in ipairs(parts) do
        if part and part.Parent then
            local layer = (i % config.rings)
            local angle = tick()*config.speed + i

            local offset = Vector3.new(
                math.cos(angle)*(config.radius + layer*3),
                config.height + (layer*3),
                math.sin(angle)*(config.radius + layer*3)
            )

            local target = root.Position + offset
            local dir = (target - part.Position).Unit

            part.Velocity = dir * config.force
        end
    end
end)
