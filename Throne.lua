local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local config = { radius = 35, height = 12, speed = 2, force = 600 }
local enabled = false
local parts = {}
local t = 0

pcall(function()
    RunService.Heartbeat:Connect(function()
        sethiddenproperty(player, "SimulationRadius", math.huge)
    end)
end)

-- GUI
local gui = Instance.new("ScreenGui") gui.Name="ThroneUI" gui.ResetOnSpawn=false gui.Parent=player:WaitForChild("PlayerGui")
local frame = Instance.new("Frame",gui) frame.Size=UDim2.new(0,260,0,260) frame.Position=UDim2.new(0,20,0.5,-130) frame.BackgroundColor3=Color3.fromRGB(0,0,0)
Instance.new("UIStroke",frame).Color=Color3.fromRGB(0,255,0)

local dragging,ds,sp
frame.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true ds=i.Position sp=frame.Position end end)
UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then frame.Position=sp+UDim2.new(0,i.Position.X-ds.X,0,i.Position.Y-ds.Y) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)

local function ctrl(n,y,k)
    local l=Instance.new("TextLabel",frame) l.Position=UDim2.new(0,10,0,y) l.Size=UDim2.new(0.4,0,0,30) l.Text=n l.TextColor3=Color3.fromRGB(0,255,0) l.BackgroundTransparency=1 l.Font=Enum.Font.Gotham
    local b=Instance.new("TextBox",frame) b.Position=UDim2.new(0.4,0,0,y) b.Size=UDim2.new(0.3,0,0,30) b.Text=tostring(config[k]) b.BackgroundColor3=Color3.fromRGB(10,10,10) b.TextColor3=Color3.fromRGB(0,255,0)
    local p=Instance.new("TextButton",frame) p.Position=UDim2.new(0.72,0,0,y) p.Size=UDim2.new(0.1,0,0,30) p.Text="+" p.BackgroundColor3=Color3.fromRGB(0,40,0) p.TextColor3=Color3.fromRGB(0,255,0)
    local m=Instance.new("TextButton",frame) m.Position=UDim2.new(0.84,0,0,y) m.Size=UDim2.new(0.1,0,0,30) m.Text="-" m.BackgroundColor3=Color3.fromRGB(0,40,0) m.TextColor3=Color3.fromRGB(0,255,0)
    p.MouseButton1Click:Connect(function() config[k]=config[k]+5 b.Text=config[k] end)
    m.MouseButton1Click:Connect(function() config[k]=config[k]-5 b.Text=config[k] end)
end
ctrl("Radius",20,"radius") ctrl("Height",70,"height") ctrl("Speed",120,"speed") ctrl("Force",170,"force")

local toggle=Instance.new("TextButton",frame) toggle.Size=UDim2.new(0.5,0,0,40) toggle.Position=UDim2.new(0.25,0,1,-50) toggle.Text="OFF" toggle.BackgroundColor3=Color3.fromRGB(0,30,0) toggle.TextColor3=Color3.fromRGB(0,255,0) toggle.Font=Enum.Font.GothamBold
toggle.MouseButton1Click:Connect(function() enabled=not enabled toggle.Text=enabled and "ON" or "OFF" end)

-- SOLO ESCOMBRO REAL Y CON OWNER
local function isDebris(v)
    if not v:IsA("BasePart") then return false end
    if v.Anchored or v.Locked then return false end
    if v:IsDescendantOf(character) then return false end
    if v.Size.Magnitude<2 or v.Size.Magnitude>45 then return false end
    if v.Mass>150 then return false end
    local m=v:FindFirstAncestorOfClass("Model") if m and m:FindFirstChildOfClass("Humanoid") then return false end
    if v:FindFirstChildWhichIsA("WeldConstraint",true) then return false end
    if #v:GetConnectedParts(true)>1 then return false end
    -- importante: solo si tenemos network
    local ok,owner = pcall(function() return v:GetNetworkOwner() end)
    if ok and owner ~= player then return false end
    return true
end

local function getParts()
    parts={}
    for _,v in pairs(workspace:GetDescendants()) do
        if isDebris(v) then
            v.CanCollide=true
            pcall(function() v.CustomPhysicalProperties=PhysicalProperties.new(0.1,0,0) end)
            table.insert(parts,v)
        end
    end
end

task.spawn(function() while true do task.wait(1.5) if enabled then getParts() end end end)
player.CharacterAdded:Connect(function(c) character=c root=c:WaitForChild("HumanoidRootPart") end)

local function ringPos(i,total,tilt)
    local a=(i/total)*math.pi*2
    return CFrame.Angles(tilt,0,0)*Vector3.new(math.cos(a)*config.radius,0,math.sin(a)*config.radius)
end

RunService.Heartbeat:Connect(function(dt)
    if not enabled or not root then return end
    t=t+dt*config.speed
    local total=#parts if total==0 then return end
    local per=math.ceil(total/3)
    local spin=CFrame.Angles(0,t,0)
    for i,p in ipairs(parts) do
        if p.Parent then
            local ring=(i-1)%3
            local idx=math.floor((i-1)/3)+1
            local tilt=ring==0 and 0 or ring==1 and math.rad(45) or math.rad(-45)
            local pos=ringPos(idx,per,tilt)
            local final=root.Position+Vector3.new(0,config.height,0)+(ring==0 and spin*pos or pos)

            -- CLAVE: velocidad proporcional a la distancia (replica a todos)
            local delta = final - p.Position
            p.AssemblyLinearVelocity = delta * 25 -- 25 = llega en 1/25 seg, no se compacta
            p.AssemblyAngularVelocity = Vector3.new(0,5,0)
        end
    end
end)
