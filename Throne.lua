local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- CONFIG por defecto más balanceado
local config = {
    radius = 60, -- más área
    height = 15,
    speed = 0.5, -- giro lento
    force = 400, -- atrae bien
    spinSpeed = 1 -- rotación propia lenta
}

local enabled = false
local minimized = false
local parts = {}
local character, root

-- NETWORK
pcall(function()
    RunService.Heartbeat:Connect(function()
        sethiddenproperty(player, "SimulationRadius", math.huge)
    end)
end)

--================ GUI SETUP CON RESPAWN =================--
local function setupGUI()
    if player.PlayerGui:FindFirstChild("ThroneUI") then
        player.PlayerGui:FindFirstChild("ThroneUI"):Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "ThroneUI"
    gui.ResetOnSpawn = false -- clave para que no se cierre al morir
    gui.Parent = player.PlayerGui

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 260, 0, 300)
    frame.Position = UDim2.new(0, 20, 0.5, -150)
    frame.BackgroundColor3 = Color3.fromRGB(0,0,0)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(0,255,0)
    stroke.Thickness = 2

    -- TOP BAR
    local top = Instance.new("Frame", frame)
    top.Size = UDim2.new(1,0,0,30)
    top.BackgroundColor3 = Color3.fromRGB(0,0,0)

    local title = Instance.new("TextLabel", top)
    title.Size = UDim2.new(1,0,1,0)
    title.Text = "THRONE PRO"
    title.TextColor3 = Color3.fromRGB(0,255,0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true

    -- CLOSE
    local close = Instance.new("TextButton", top)
    close.Size = UDim2.new(0,30,0,30)
    close.Position = UDim2.new(1,-30,0,0)
    close.Text = "X"
    close.BackgroundColor3 = Color3.fromRGB(0,0,0)
    close.TextColor3 = Color3.fromRGB(0,255,0)

    -- MINIMIZE
    local mini = Instance.new("TextButton", top)
    mini.Size = UDim2.new(0,30,0,30)
    mini.Position = UDim2.new(1,-60,0,0)
    mini.Text = "-"
    mini.BackgroundColor3 = Color3.fromRGB(0,0,0)
    mini.TextColor3 = Color3.fromRGB(0,255,0)

    -- DRAG
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
            local delta = i.Position - dragStart
            frame.Position = startPos + UDim2.new(0,delta.X,0,delta.Y)
        end
    end)

    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- CONTROL CREATOR
    local function createControl(name, y, key, step)
        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(0.35,0,0,30)
        label.Position = UDim2.new(0,10,0,y)
        label.Text = name
        label.TextColor3 = Color3.fromRGB(0,255,0)
        label.BackgroundTransparency = 1
        label.TextScaled = true

        local box = Instance.new("TextBox", frame)
        box.Size = UDim2.new(0.3,0,0,30)
        box.Position = UDim2.new(0.38,0,0,y)
        box.Text = tostring(config[key])
        box.BackgroundColor3 = Color3.fromRGB(0,40,0)
        box.TextColor3 = Color3.fromRGB(0,255,0)

        local plus = Instance.new("TextButton", frame)
        plus.Size = UDim2.new(0.1,0,0,30)
        plus.Position = UDim2.new(0.7,0,0,y)
        plus.Text = "+"
        plus.BackgroundColor3 = Color3.fromRGB(0,40,0)
        plus.TextColor3 = Color3.fromRGB(0,255,0)

        local minus = Instance.new("TextButton", frame)
        minus.Size = UDim2.new(0.1,0,0,30)
        minus.Position = UDim2.new(0.82,0,0,y)
        minus.Text = "-"
        minus.BackgroundColor3 = Color3.fromRGB(0,40,0)
        minus.TextColor3 = Color3.fromRGB(0,255,0)

        plus.MouseButton1Click:Connect(function()
            config[key] += step
            box.Text = string.format("%.2f", config[key])
        end)

        minus.MouseButton1Click:Connect(function()
            config[key] -= step
            if key == "radius" or key == "force" then
                config[key] = math.max(1, config[key])
            end
            box.Text = string.format("%.2f", config[key])
        end)

        box.FocusLost:Connect(function()
            local n = tonumber(box.Text)
            if n then config[key] = n end
            box.Text = string.format("%.2f", config[key])
        end)
    end

    createControl("Radius", 50, "radius", 5)
    createControl("Height", 90, "height", 2)
    createControl("Speed", 130, "speed", 0.1)
    createControl("Force", 170, "force", 20)
    createControl("Spin", 210, "spinSpeed", 0.2)

    -- TOGGLE
    local toggle = Instance.new("TextButton", frame)
    toggle.Size = UDim2.new(0.6,0,0,35)
    toggle.Position = UDim2.new(0.2,0,1,-45)
    toggle.Text = "OFF"
    toggle.BackgroundColor3 = Color3.fromRGB(0,40,0)
    toggle.TextColor3 = Color3.fromRGB(0,255,0)

    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggle.Text = enabled and "ON" or "OFF"
    end)

    -- MINIMIZE FUNC
    mini.MouseButton1Click:Connect(function()
        minimized = not minimized
        for _,v in pairs(frame:GetChildren()) do
            if v ~= top then
                v.Visible = not minimized
            end
        end
        frame.Size = minimized and UDim2.new(0,260,0,30) or UDim2.new(0,260,0,300)
    end)

    -- CLOSE FUNC
    close.MouseButton1Click:Connect(function()
        enabled = false
        gui:Destroy()
    end)
end

setupGUI()

--================ LOGICA PRINCIPAL =================--
local function onCharacterAdded(char)
    character = char
    root = character:WaitForChild("HumanoidRootPart")
end

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
    onCharacterAdded(player.Character)
end

-- PARTS
local function getParts()
    parts = {}
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v.Anchored and not v:IsDescendantOf(character) then
            if v.CanCollide and not v:FindFirstAncestorOfClass("Accessory") then
                table.insert(parts, v)
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(3)
        if enabled and character and root then
            getParts()
        end
    end
end)

-- RINGS con distribución balanceada + rotación propia
RunService.Heartbeat:Connect(function()
    if not enabled or not character or not root or not root.Parent then return end

    local t = tick() * config.speed
    local totalParts = #parts
    if totalParts == 0 then return end

    local ringCount = 3
    local partsPerRing = math.floor(totalParts / ringCount)
    local extra = totalParts % ringCount

    for i, part in ipairs(parts) do
        if part and part.Parent and part:IsDescendantOf(workspace) then
            -- Solo desactivar colisión si está lejos para evitar muerte en spawn
            local dist = (part.Position - root.Position).Magnitude
            if dist > 10 then
                part.CanCollide = false
            else
                part.CanCollide = true
            end

            -- Determinar a qué anillo pertenece para balancear
            local ring = math.floor((i-1) / (partsPerRing + 1))
            if ring >= ringCount then ring = ringCount - 1 end

            local indexInRing = (i-1) % (partsPerRing + (ring < extra and 1 or 0))
            local totalInThisRing = partsPerRing + (ring < extra and 1 or 0)

            -- Tilt de cada anillo
            local tilt = ring == 0 and 0 or ring == 1 and math.rad(45) or math.rad(-45)

            -- Posición orbital
            local angle = (indexInRing / totalInThisRing) * math.pi * 2
            local orbitPos = Vector3.new(
                math.cos(angle) * config.radius,
                config.height,
                math.sin(angle) * config.radius
            )

            -- Rotación del anillo completo
            local finalPos = root.Position + (CFrame.Angles(tilt, t, 0) * orbitPos)

            -- Movimiento hacia la posición
            local dir = (finalPos - part.Position)
            if dir.Magnitude > 0.1 then
                part.Velocity = dir.Unit * math.min(config.force, dir.Magnitude * 5)
            end

            -- Rotación sobre su propio eje sin romper el movimiento
            part.RotVelocity = Vector3.new(
                config.spinSpeed * 5,
                config.spinSpeed * 10,
                config.spinSpeed * 5
            )
        end
    end
end)
