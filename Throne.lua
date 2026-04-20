local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Sound
local function playSound(soundId)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. soundId
    sound.Parent = SoundService
    sound:Play()
    sound.Ended:Connect(function() sound:Destroy() end)
end
playSound("2865227271")

-- GUI (tu misma)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SuperRingPartsGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 500)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -250)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 20)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "Super Ring Parts V6 - 3 Rings"
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(0, 204, 204)
Title.Font = Enum.Font.Fondamento
Title.TextSize = 22
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 20)

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.8, 0, 0, 40)
ToggleButton.Position = UDim2.new(0.1, 0, 0.1, 0)
ToggleButton.Text = "Ring Off"
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
ToggleButton.Font = Enum.Font.Fondamento
ToggleButton.TextSize = 18
ToggleButton.Parent = MainFrame
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 10)

local config = {
    radius = 50,
    height = 12,
    rotationSpeed = 10,
    attractionStrength = 1000,
}

local function saveConfig() writefile("SuperRingPartsConfig.txt", HttpService:JSONEncode(config)) end
local function loadConfig() if isfile("SuperRingPartsConfig.txt") then config = HttpService:JSONDecode(readfile("SuperRingPartsConfig.txt")) end end
loadConfig()

local function createControl(name, positionY, color, labelText, defaultValue, callback)
    local DecreaseButton = Instance.new("TextButton")
    DecreaseButton.Size = UDim2.new(0.2, 0, 0, 40)
    DecreaseButton.Position = UDim2.new(0.1, 0, positionY, 0)
    DecreaseButton.Text = "-"
    DecreaseButton.BackgroundColor3 = color
    DecreaseButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    DecreaseButton.Font = Enum.Font.Fondamento
    DecreaseButton.TextSize = 18
    DecreaseButton.Parent = MainFrame

    local IncreaseButton = Instance.new("TextButton")
    IncreaseButton.Size = UDim2.new(0.2, 0, 0, 40)
    IncreaseButton.Position = UDim2.new(0.7, 0, positionY, 0)
    IncreaseButton.Text = "+"
    IncreaseButton.BackgroundColor3 = color
    IncreaseButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    IncreaseButton.Font = Enum.Font.Fondamento
    IncreaseButton.TextSize = 18
    IncreaseButton.Parent = MainFrame

    local Display = Instance.new("TextLabel")
    Display.Size = UDim2.new(0.4, 0, 0, 40)
    Display.Position = UDim2.new(0.3, 0, positionY, 0)
    Display.Text = labelText .. ": " .. defaultValue
    Display.BackgroundColor3 = Color3.fromRGB(255, 153, 51)
    Display.TextColor3 = Color3.fromRGB(0, 0, 0)
    Display.Font = Enum.Font.Fondamento
    Display.TextSize = 18
    Display.Parent = MainFrame

    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(0.8, 0, 0, 35)
    TextBox.Position = UDim2.new(0.1, 0, positionY + 0.1, 0)
    TextBox.PlaceholderText = "Enter " .. labelText
    TextBox.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
    TextBox.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextBox.Font = Enum.Font.Fondamento
    TextBox.TextSize = 18
    TextBox.Parent = MainFrame
    Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 10)

    DecreaseButton.MouseButton1Click:Connect(function()
        local value = tonumber(Display.Text:match("%d+"))
        value = math.max(0, value - 10)
        Display.Text = labelText .. ": " .. value
        callback(value)
        playSound("12221967")
        saveConfig()
    end)

    IncreaseButton.MouseButton1Click:Connect(function()
        local value = tonumber(Display.Text:match("%d+"))
        value = math.min(10000, value + 10)
        Display.Text = labelText .. ": " .. value
        callback(value)
        playSound("12221967")
        saveConfig()
    end)
end

createControl("Radius", 0.2, Color3.fromRGB(153, 153, 0), "Radius", config.radius, function(v) config.radius = v end)
createControl("Height", 0.4, Color3.fromRGB(153, 0, 153), "Height", config.height, function(v) config.height = v end)
createControl("RotationSpeed", 0.6, Color3.fromRGB(0, 153, 153), "Rotation Speed", config.rotationSpeed, function(v) config.rotationSpeed = v end)
createControl("AttractionStrength", 0.8, Color3.fromRGB(153, 0, 0), "Attraction Strength", config.attractionStrength, function(v) config.attractionStrength = v end)

-- Draggable
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
MainFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + input.Position.X - dragStart.X, startPos.Y.Scale, startPos.Y.Offset + input.Position.Y - dragStart.Y) end end)

-- NETWORK (tu sistema que agarra todo)
local Workspace = game:GetService("Workspace")
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

if not getgenv().Network then
    getgenv().Network = { BaseParts = {}, Velocity = Vector3.new(0,0,0) }
    Network.RetainPart = function(Part)
        if typeof(Part) == "Instance" and Part:IsA("BasePart") and Part:IsDescendantOf(Workspace) then
            table.insert(Network.BaseParts, Part)
            Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            Part.CanCollide = true -- CAMBIO: ahora empujan
        end
    end
    local function EnablePartControl()
        LocalPlayer.ReplicationFocus = Workspace
        RunService.Heartbeat:Connect(function()
            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
        end)
    end
    EnablePartControl()
end

-- FILTRO MEJORADO: agarra TODO lo suelto real
local function RetainPart(Part)
    if not Part:IsA("BasePart") then return false end
    if Part.Anchored then return false end
    if not Part:IsDescendantOf(workspace) then return false end
    if Part:IsDescendantOf(LocalPlayer.Character) then return false end
    if Part.Parent and Part.Parent:FindFirstChildOfClass("Humanoid") then return false end
    if Part.Name == "Handle" or Part.Name == "Baseplate" then return false end
    if Part:IsDescendantOf(workspace.Terrain) then return false end
    if Part.Size.Magnitude > 70 then return false end -- evita agarrar mapa entero
    
    -- evita piezas soldadas a estructuras fijas
    for _,c in ipairs(Part:GetConnectedParts(true)) do
        if c.Anchored then return false end
    end
    
    Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
    Part.CanCollide = true
    return true
end

local ringPartsEnabled = false
local parts = {}
local t = 0

local function addPart(part)
    if RetainPart(part) then
        if not table.find(parts, part) then
            Network.RetainPart(part)
            table.insert(parts, part)
        end
    end
end

local function removePart(part)
    local index = table.find(parts, part)
    if index then table.remove(parts, index) end
end

for _, part in pairs(workspace:GetDescendants()) do addPart(part) end
workspace.DescendantAdded:Connect(addPart)
workspace.DescendantRemoving:Connect(removePart)

-- 3 ANILLOS: solo el medio gira
RunService.Heartbeat:Connect(function(dt)
    if not ringPartsEnabled then return end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    t = t + dt * (config.rotationSpeed / 5)
    local center = hrp.Position
    local total = #parts
    if total == 0 then return end
    local perRing = math.ceil(total / 3)
    local spin = CFrame.Angles(0, t, 0)
    
    for i, part in ipairs(parts) do
        if part.Parent and not part.Anchored then
            local ring = (i-1) % 3
            local idx = math.floor((i-1)/3) + 1
            local tilt = ring == 0 and 0 or ring == 1 and math.rad(45) or math.rad(-45)
            local angle = (idx / perRing) * math.pi * 2
            local base = Vector3.new(math.cos(angle) * config.radius, 0, math.sin(angle) * config.radius)
            local pos = CFrame.Angles(tilt, 0, 0) * base
            local target = center + Vector3.new(0, config.height, 0) + (ring == 0 and spin * pos or pos)
            
            local delta = target - part.Position
            part.Velocity = delta * (config.attractionStrength / 40) -- replica a todos
        end
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    ringPartsEnabled = not ringPartsEnabled
    ToggleButton.Text = ringPartsEnabled and "Ring On" or "Ring Off"
    ToggleButton.BackgroundColor3 = ringPartsEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    playSound("12221967")
end)

StarterGui:SetCore("SendNotification", {Title = "Super Ring V6", Text = "3 anillos listos - solo medio gira", Duration = 5})
