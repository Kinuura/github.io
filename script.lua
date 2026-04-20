local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 80)
frame.Position = UDim2.new(0.5, -130, 0.8, 0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

local minus = Instance.new("TextButton", frame)
minus.Size = UDim2.new(0, 50, 1, 0)
minus.Text = "-"

local plus = Instance.new("TextButton", frame)
plus.Size = UDim2.new(0, 50, 1, 0)
plus.Position = UDim2.new(1, -50, 0, 0)
plus.Text = "+"

local label = Instance.new("TextLabel", frame)
label.Size = UDim2.new(0, 100, 1, 0)
label.Position = UDim2.new(0.5, -50, 0, 0)
label.Text = "0"
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(1,1,1)

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0, 60, 1, 0)
toggle.Position = UDim2.new(0, 50, 0, 0)
toggle.Text = "On"

local reach = 0
local visuals = {}
local enabled = true

-- 🎯 ТОЧНОЕ ОПРЕДЕЛЕНИЕ МЯЧА MPS
local function isBall(obj)
    if not obj:IsA("BasePart") then return false end

    local path = obj:GetFullName():lower()
    if not path:find("interactive") then return false end
    if not path:find("balls") then return false end

    if obj.Name ~= "MPS" then return false end

    local s = obj.Size
    if s.X == 2.5 and s.Y == 2.5 and s.Z == 2.5 then
        return true
    end

    return false
end

-- создаём визуальный хитбокс
local function createVisual(ball)
    if visuals[ball] then return end
    
    local part = Instance.new("Part")
    part.Shape = Enum.PartType.Ball
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.ForceField
    part.Color = Color3.fromRGB(0, 170, 255)
    part.Transparency = 0.5
    part.Name = "HitboxVisual"
    
    part.Parent = workspace
    visuals[ball] = part
end

-- обновление визуалов
local function updateVisuals()
    for ball, visual in pairs(visuals) do
        if not ball or not ball.Parent then
            visual:Destroy()
            visuals[ball] = nil
        else
            if enabled then
                visual.Transparency = 0.5
                visual.Position = ball.Position
                visual.Size = ball.Size + Vector3.new(reach, reach, reach)
            else
                visual.Transparency = 1
            end
        end
    end
end

-- 🔥 УЛУЧШЕННАЯ РЕГИСТРАЦИЯ КАСАНИЯ (ТОЛЬКО ДЛЯ LOCALPLAYER)
local function checkTouch()
    if not enabled then return end

    local char = player.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for ball, visual in pairs(visuals) do
        if ball and ball.Parent and visual then
            
            local dist = (root.Position - ball.Position).Magnitude
            local radius = visual.Size.X / 2

            if dist <= radius then
                print("TOUCH:", ball.Name)

                -- 🔥 ТУТ МОЖНО ДОБАВИТЬ ЛЮБОЕ ДЕЙСТВИЕ:
                -- например автокик:
                -- ball.Velocity = (root.CFrame.LookVector * 60)
            end
        end
    end
end

-- ищем мячи
for _, v in pairs(workspace:GetDescendants()) do
    if isBall(v) then
        createVisual(v)
    end
end

workspace.DescendantAdded:Connect(function(v)
    if isBall(v) then
        createVisual(v)
    end
end)

-- цикл обновления
game:GetService("RunService").RenderStepped:Connect(function()
    updateVisuals()
    checkTouch()
end)

-- GUI кнопки
plus.MouseButton1Click:Connect(function()
    reach = reach + 0.5
    label.Text = tostring(reach)
end)

minus.MouseButton1Click:Connect(function()
    reach = math.max(0, reach - 0.5)
    label.Text = tostring(reach)
end)

toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggle.Text = enabled and "On" or "Off"
end)
