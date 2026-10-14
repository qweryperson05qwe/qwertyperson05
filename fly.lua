local flySpeed = 50
local flying = false

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local bodyVelocity

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    flying = false
    if bodyVelocity then bodyVelocity:Destroy() end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "FlyMenu"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 265)
frame.Position = UDim2.new(0.5, -140, 0.5, -132)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
frame.Parent = gui

-- Перетаскивание меню (для телефона и ПК)
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(0, 240, 0, 40)
flyButton.Position = UDim2.new(0, 20, 0, 10)
flyButton.Text = "Полёт: ВЫКЛ"
flyButton.Parent = frame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 240, 0, 30)
speedLabel.Position = UDim2.new(0, 20, 0, 55)
speedLabel.Text = "Скорость: " .. flySpeed
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.BackgroundTransparency = 1
speedLabel.Parent = frame

local minusButton = Instance.new("TextButton")
minusButton.Size = UDim2.new(0, 115, 0, 35)
minusButton.Position = UDim2.new(0, 20, 0, 90)
minusButton.Text = "- Скорость"
minusButton.Parent = frame

local plusButton = Instance.new("TextButton")
plusButton.Size = UDim2.new(0, 115, 0, 35)
plusButton.Position = UDim2.new(0, 145, 0, 90)
plusButton.Text = "+ Скорость"
plusButton.Parent = frame

-- Кнопки управления высотой
local upButton = Instance.new("TextButton")
upButton.Size = UDim2.new(0, 115, 0, 40)
upButton.Position = UDim2.new(0, 20, 0, 135)
upButton.Text = "▲ Вверх"
upButton.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
upButton.TextColor3 = Color3.new(1, 1, 1)
upButton.Parent = frame

local downButton = Instance.new("TextButton")
downButton.Size = UDim2.new(0, 115, 0, 40)
downButton.Position = UDim2.new(0, 145, 0, 135)
downButton.Text = "▼ Вниз"
downButton.BackgroundColor3 = Color3.fromRGB(120, 50, 50)
downButton.TextColor3 = Color3.new(1, 1, 1)
downButton.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 240, 0, 35)
closeButton.Position = UDim2.new(0, 20, 0, 185)
closeButton.Text = "Скрыть меню"
closeButton.Parent = frame

local menuVisible = true
closeButton.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    for _, child in ipairs(frame:GetChildren()) do
        if child ~= closeButton and child:IsA("GuiObject") then
            child.Visible = menuVisible
        end
    end
    frame.Size = menuVisible and UDim2.new(0, 280, 0, 230) or UDim2.new(0, 280, 0, 50)
    closeButton.Position = menuVisible and UDim2.new(0, 20, 0, 185) or UDim2.new(0, 20, 0, 10)
    closeButton.Text = menuVisible and "Скрыть меню" or "Открыть меню"
end)

-- Функция обновления скорости ходьбы и полета
local function updateSpeed()
    speedLabel.Text = "Скорость: " .. flySpeed
    if humanoid then
        humanoid.WalkSpeed = flySpeed -- Персонаж начинает ходить быстрее или медленнее
    end
end

plusButton.MouseButton1Click:Connect(function()
    flySpeed = math.clamp(flySpeed + 5, 5, 300)
    updateSpeed()
end)

minusButton.MouseButton1Click:Connect(function()
    flySpeed = math.clamp(flySpeed - 5, 5, 300)
    updateSpeed()
end)

-- Переключатель полёта
flyButton.MouseButton1Click:Connect(function()
    flying = not flying
    flyButton.Text = flying and "Полёт: ВКЛ" or "Полёт: ВЫКЛ"
    
    if flying then
        if not bodyVelocity then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
            bodyVelocity.Parent = humanoidRootPart
        end
    else
        if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    end
end)

-- Отслеживание нажатия кнопок вверх/вниз на телефоне
local movingUp = false
local movingDown = false

upButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        movingUp = true
    end
end)
upButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        movingUp = false
    end
end)

downButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        movingDown = true
    end
end)
downButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        movingDown = false
    end
end)

-- Обработка перемещения по вертикали
local RunService = game:GetService("RunService")

RunService.RenderStepped:Connect(function()
    if not flying or not character or not humanoidRootPart or not bodyVelocity then return end
    
    local yVelocity = 0
    
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) or movingUp then 
        yVelocity = flySpeed 
    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) or movingDown then 
        yVelocity = -flySpeed 
    else
        yVelocity = 0
    end
    
    bodyVelocity.Velocity = Vector3.new(0, yVelocity, 0)
end)
