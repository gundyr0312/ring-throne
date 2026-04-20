-- Throne Pro Delta | Natural Disaster Survival
-- by lukas base + 3 rings fix
print("THRONE DELTA CARGADO")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local root = nil

-- CONFIG (edita aquí)
local cfg = {
    radius = 55,
    height = 12,
    speed = 2.5, -- grados por frame
    force = 800 -- súbelo si van lento en ND
}

local on = false
local parts = {}
local rings = {}
local count = 0

-- GUI simple Delta-friendly
local gui = Instance.new("ScreenGui")
gui.Name = "ThroneDelta"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

local btn = Instance.new("TextButton")
btn.Parent = gui
btn.Size = UDim2.new(0, 180, 0, 45)
btn.Position = UDim2.new(0, 15, 0, 15)
btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
btn.BorderSizePixel = 0
btn.Text = "THRONE OFF"
btn.TextColor3 = Color3.fromRGB(0, 255, 0) -- verde chillón
btn.Font = Enum.Font.GothamBold
btn.TextSize = 20

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = btn

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 255, 0)
stroke.Thickness = 2
stroke.Parent = btn

btn.MouseButton1Click:Connect(function()
    on = not on
    btn.Text = on and "THRONE ON" or "THRONE OFF"
end)

-- personaje
LP.CharacterAdded:Connect(function(c)
    root = c:WaitForChild("HumanoidRootPart")
end)
if LP.Character then root = LP.Character:FindFirstChild("HumanoidRootPart") end

-- recolectar partes como V6
local function add(p)
    if not p:IsA("BasePart") then return end
    if p.Anchored then return end
    if not p:IsDescendantOf(workspace) then return end
    if p.Parent and p.Parent:FindFirstChild("Humanoid") then return end
    if LP.Character and p:IsDescendantOf(LP.Character) then return end

    p.CanCollide = false
    table.insert(parts, p)
    rings[p] = count % 3
    count = count + 1
end

for _,v in ipairs(workspace:GetDescendants()) do add(v) end
workspace.DescendantAdded:Connect(add)

-- loop principal (Delta safe)
RunService.Heartbeat:Connect(function()
    -- simulation radius (pcall por si Delta lo bloquea)
    pcall(function()
        sethiddenproperty(LP, "SimulationRadius", math.huge)
    end)

    if not on or not root then return end

    local center = root.Position
    for _,part in ipairs(parts) do
        if part and part.Parent then
            local r = rings[part] or 0
            local tilt = 0
            if r == 1 then tilt = math.rad(45) end
            if r == 2 then tilt = math.rad(-45) end

            -- ángulo real (clave para ND)
            local ang = math.atan2(part.Position.Z - center.Z, part.Position.X - center.X)
            local newAng = ang + math.rad(cfg.speed)

            local offset = Vector3.new(math.cos(newAng) * cfg.radius, 0, math.sin(newAng) * cfg.radius)
            local target = center + Vector3.new(0, cfg.height, 0) + (CFrame.Angles(tilt, 0, 0) * offset)

            local dir = target - part.Position
            if dir.Magnitude > 1 then
                -- Delta prefiere AssemblyLinearVelocity
                pcall(function()
                    part.AssemblyLinearVelocity = dir.Unit * cfg.force
                end)
                -- fallback viejo
                pcall(function()
                    part.Velocity = dir.Unit * cfg.force
                end)
            end
        end
    end
end)
