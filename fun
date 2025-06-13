local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local playerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- Giao diện
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name         = "CustomPushToggle"
screenGui.ResetOnSpawn = false

local toggleBtn = Instance.new("TextButton", screenGui)
toggleBtn.Size             = UDim2.new(0, 120, 0, 40)
toggleBtn.Position         = UDim2.new(0, 10, 0, 10)
toggleBtn.Text             = "🛠️ Menu"
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
toggleBtn.BorderSizePixel  = 0

-- Tăng chiều cao menuFrame để chứa 5 nút
local menuFrame = Instance.new("Frame", screenGui)
menuFrame.Size             = UDim2.new(0, 180, 0, 230)
menuFrame.Position         = UDim2.new(0, 140, 0, 10)
menuFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
menuFrame.Visible          = false

-- Nút Push
local pushBtn = Instance.new("TextButton", menuFrame)
pushBtn.Size             = UDim2.new(1, -10, 0, 40)
pushBtn.Position         = UDim2.new(0, 5, 0, 5)
pushBtn.Text             = "🚫 Push: OFF"
pushBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
pushBtn.TextColor3       = Color3.new(1, 1, 1)

-- Nút Fling (ON/OFF)
local flingBtn = Instance.new("TextButton", menuFrame)
flingBtn.Size             = UDim2.new(1, -10, 0, 40)
flingBtn.Position         = UDim2.new(0, 5, 0, 50)
flingBtn.Text             = "🌀 Fling: OFF"
flingBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
flingBtn.TextColor3       = Color3.new(1, 1, 1)

-- Nút Speed
local speedBtn = Instance.new("TextButton", menuFrame)
speedBtn.Size             = UDim2.new(1, -10, 0, 40)
speedBtn.Position         = UDim2.new(0, 5, 0, 95)
speedBtn.Text             = "⚡ Speed: OFF"
speedBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
speedBtn.TextColor3       = Color3.new(1, 1, 1)

-- Nút Mini Push
local miniPushBtn = Instance.new("TextButton", menuFrame)
miniPushBtn.Size             = UDim2.new(1, -10, 0, 40)
miniPushBtn.Position         = UDim2.new(0, 5, 0, 140)
miniPushBtn.Text             = "🎯 Mini Push: OFF"
miniPushBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
miniPushBtn.TextColor3       = Color3.new(1, 1, 1)

-- Nút Medium Push
local mediumPushBtn = Instance.new("TextButton", menuFrame)
mediumPushBtn.Size             = UDim2.new(1, -10, 0, 40)
mediumPushBtn.Position         = UDim2.new(0, 5, 0, 185)
mediumPushBtn.Text             = "💥 Medium Push: OFF"
mediumPushBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
mediumPushBtn.TextColor3       = Color3.new(1, 1, 1)

-- Toggle menu
toggleBtn.MouseButton1Click:Connect(function()
    menuFrame.Visible = not menuFrame.Visible
end)

-- Helper to get character
local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

-- ===== PUSH LOGIC =====
local pushing, pushTask = false, nil
local function pushEffect(c)
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then return end
    hum:ChangeState(Enum.HumanoidStateType.Physics)
    hum.PlatformStand = true
    local bv = Instance.new("BodyVelocity", hrp)
    bv.Velocity = Vector3.new(math.random(-200,200),0,math.random(-200,200))
    bv.MaxForce = Vector3.new(1e6,0,1e6); bv.P = 3000
    game.Debris:AddItem(bv,0.3)
    local av = Instance.new("BodyAngularVelocity", hrp)
    av.AngularVelocity = Vector3.new(math.random(-100,100),math.random(-100,100),math.random(-100,100))
    av.MaxTorque = Vector3.new(1e6,1e6,1e6); av.P = 3000
    game.Debris:AddItem(av,0.3)
end
local function disableCollision(c)
    for _, part in ipairs(c:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.CustomPhysicalProperties = PhysicalProperties.new(0.01,0,0)
        end
    end
end

pushBtn.MouseButton1Click:Connect(function()
    pushing = not pushing
    pushBtn.Text = pushing and "✅ Push: ON" or "🚫 Push: OFF"
    if pushing then
        local c = getChar()
        disableCollision(c)
        pushTask = task.spawn(function()
            while pushing do
                pushEffect(getChar())
                task.wait(0.4)
            end
        end)
    else
        if pushTask then task.cancel(pushTask) end
        local hum = getChar():FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end)

-- ===== FLING LOGIC =====
local hiddenFling, flingThread = false, nil
local function flingLoop()
    local movel = 0.1
    while hiddenFling do
        RunService.Heartbeat:Wait()
        local hrp = getChar():FindFirstChild("HumanoidRootPart")
        if hrp then
            local vel = hrp.Velocity
            hrp.Velocity = vel*10000 + Vector3.new(0,10000,0)
            RunService.RenderStepped:Wait()
            hrp.Velocity = vel
            RunService.Stepped:Wait()
            hrp.Velocity = vel + Vector3.new(0,movel,0)
            movel = -movel
        end
    end
end

flingBtn.MouseButton1Click:Connect(function()
    hiddenFling = not hiddenFling
    flingBtn.Text = hiddenFling and "🌀 Fling: ON" or "🌀 Fling: OFF"
    if hiddenFling then
        flingThread = coroutine.create(flingLoop)
        coroutine.resume(flingThread)
    end
end)

-- ===== SPEED LOGIC (1.5x) =====
local speedOn, defaultSpeed = false, 16
local function applySpeed()
    local hum = getChar():FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = speedOn and defaultSpeed*1.5 or defaultSpeed end
end

speedBtn.MouseButton1Click:Connect(function()
    speedOn = not speedOn
    speedBtn.Text = speedOn and "⚡ Speed: ON" or "⚡ Speed: OFF"
    applySpeed()
end)

-- ===== MINI PUSH LOGIC =====
local miniOn = false
miniPushBtn.MouseButton1Click:Connect(function()
    miniOn = not miniOn
    miniPushBtn.Text = miniOn and "🎯 Mini Push: ON" or "🎯 Mini Push: OFF"
    local c = getChar()
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if miniOn then
        hum:ChangeState(Enum.HumanoidStateType.Physics)
        hum.PlatformStand = true
        for _, part in ipairs(c:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Anchored = false; part.CanCollide = true
            end
        end
    else
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        hum.PlatformStand = false
        hum:Move(Vector3.zero,false)
    end
end)

-- ===== MEDIUM PUSH LOGIC =====
local mediumOn = false
mediumPushBtn.MouseButton1Click:Connect(function()
    mediumOn = not mediumOn
    mediumPushBtn.Text = mediumOn and "💥 Medium Push: ON" or "💥 Medium Push: OFF"
    local c = getChar()
    if mediumOn then
        -- mạnh hơn nhưng không bay lên
        local hum = c:FindFirstChildOfClass("Humanoid")
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if hum and hrp then
            hum:ChangeState(Enum.HumanoidStateType.Physics)
            hum.PlatformStand = true
            for _, part in ipairs(c:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Anchored = false; part.CanCollide = true
                end
            end
            local bv = Instance.new("BodyVelocity", hrp)
            bv.Velocity   = Vector3.new(math.random(-90,90),0,math.random(-90,90))
            bv.MaxForce   = Vector3.new(1e6,0,1e6); bv.P = 3000
            game.Debris:AddItem(bv,0.5)
            local av = Instance.new("BodyAngularVelocity", hrp)
            av.AngularVelocity = Vector3.new(math.random(-20,20),math.random(-20,20),math.random(-20,20))
            av.MaxTorque       = Vector3.new(1e6,1e6,1e6); av.P = 3000
            game.Debris:AddItem(av,0.5)
        end
    else
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end)
