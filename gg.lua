-- Stealth Fling Mobile Clicker Hub (融合版)
-- クールな黒デザインHub + 場所指定型モバイル連打機能

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealthFlingHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

-- Executor対応
if gethui then
    ScreenGui.Parent = gethui()
elseif CoreGui:FindFirstChild("RobloxGui") then
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = playerGui
end

-- メインフレーム（クールな黒デザイン）
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 200)
MainFrame.Position = UDim2.new(0.5, -160, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

-- タイトルバー
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Text = "⚡ Fling Mobile Clicker"
TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- 最小化ボタン（3段階）
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -70, 0, 5)
MinimizeBtn.Text = "−"
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeBtn.TextColor3 = Color3.new(1,1,1)
MinimizeBtn.Parent = TitleBar

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 8)
MinimizeCorner.Parent = MinimizeBtn

-- 閉じるボタン
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "×"
CloseBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- コンテンツエリア
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -60)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- 生成ボタン
local GenerateBtn = Instance.new("TextButton")
GenerateBtn.Size = UDim2.new(0.9, 0, 0, 55)
GenerateBtn.Position = UDim2.new(0.05, 0, 0.5, -27)
GenerateBtn.Text = "Generate Fling Mobile Clicker"
GenerateBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
GenerateBtn.TextColor3 = Color3.fromRGB(180, 255, 200)
GenerateBtn.Font = Enum.Font.GothamBold
GenerateBtn.TextSize = 16
GenerateBtn.Parent = Content

local GenCorner = Instance.new("UICorner")
GenCorner.CornerRadius = UDim.new(0, 10)
GenCorner.Parent = GenerateBtn

-- 最小化状態管理
local minimizeLevel = 0

MinimizeBtn.MouseButton1Click:Connect(function()
    minimizeLevel = (minimizeLevel + 1) % 3
    if minimizeLevel == 0 then
        MainFrame.Size = UDim2.new(0, 320, 0, 200)
        MinimizeBtn.Text = "−"
        Content.Visible = true
    elseif minimizeLevel == 1 then
        MainFrame.Size = UDim2.new(0, 320, 0, 40)
        MinimizeBtn.Text = "□"
        Content.Visible = false
    else
        MainFrame.Size = UDim2.new(0, 150, 0, 40)
        MinimizeBtn.Text = "⚡"
        Content.Visible = false
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- メインUIドラッグ
local dragging = false
local dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- 場所指定型モバイルクリッカー生成関数
local function createFlingClicker()
    -- 個別のScreenGui（Hubとは別）
    local clickerGui = Instance.new("ScreenGui")
    clickerGui.Name = "FlingClickerInstance"
    clickerGui.ResetOnSpawn = false
    clickerGui.Parent = ScreenGui.Parent -- 同じ親に

    -- 状態
    local isRunning = false
    local isSelecting = false
    local targetPosition = nil
    local clickSpeed = 0.05

    -- メインフレーム（小型）
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 160, 0, 130)
    frame.Position = UDim2.new(0.05, math.random(0, 100), 0.4, math.random(0, 100))
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.Active = true
    frame.Draggable = true
    frame.Parent = clickerGui

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 12)
    uiCorner.Parent = frame

    -- タイトル
    local title = Instance.new("TextLabel")
    title.Text = "Fling Clicker"
    title.Size = UDim2.new(1, 0, 0.2, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = frame

    -- ステータス
    local status = Instance.new("TextLabel")
    status.Text = "場所未設定"
    status.Size = UDim2.new(1, 0, 0.15, 0)
    status.Position = UDim2.new(0, 0, 0.2, 0)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(200, 200, 200)
    status.TextSize = 12
    status.Parent = frame

    -- 場所設定ボタン
    local setBtn = Instance.new("TextButton")
    setBtn.Size = UDim2.new(0.8, 0, 0.25, 0)
    setBtn.Position = UDim2.new(0.1, 0, 0.4, 0)
    setBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
    setBtn.Text = "場所を決める"
    setBtn.TextColor3 = Color3.new(1,1,1)
    setBtn.Font = Enum.Font.GothamBold
    setBtn.TextSize = 12
    setBtn.Parent = frame
    Instance.new("UICorner", setBtn).CornerRadius = UDim.new(0, 8)

    -- トグルボタン
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0.8, 0, 0.25, 0)
    toggleBtn.Position = UDim2.new(0.1, 0, 0.7, 0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggleBtn.Text = "START"
    toggleBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 14
    toggleBtn.Parent = frame
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

    -- マーカー
    local marker = Instance.new("Frame")
    marker.Size = UDim2.new(0, 20, 0, 20)
    marker.AnchorPoint = Vector2.new(0.5, 0.5)
    marker.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    marker.BackgroundTransparency = 0.3
    marker.BorderSizePixel = 2
    marker.BorderColor3 = Color3.new(1,1,1)
    marker.Visible = false
    marker.ZIndex = 10000
    marker.Parent = clickerGui
    Instance.new("UICorner", marker).CornerRadius = UDim.new(1, 0)

    -- オーバーレイ
    local overlay = Instance.new("TextButton")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundTransparency = 0.8
    overlay.BackgroundColor3 = Color3.new(0,0,0)
    overlay.Text = "連打したい場所をタップ"
    overlay.TextColor3 = Color3.new(1,1,1)
    overlay.TextSize = 24
    overlay.Font = Enum.Font.GothamBold
    overlay.Visible = false
    overlay.ZIndex = 9999
    overlay.Parent = clickerGui

    -- ロジック
    setBtn.MouseButton1Click:Connect(function()
        isRunning = false
        isSelecting = true
        toggleBtn.Text = "START"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        status.Text = "タップして設定..."
        overlay.Visible = true
    end)

    UserInputService.InputBegan:Connect(function(input)
        if isSelecting and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
            targetPosition = input.Position
            marker.Position = UDim2.new(0, targetPosition.X, 0, targetPosition.Y)
            marker.Visible = true
            isSelecting = false
            overlay.Visible = false
            status.Text = "設定完了!"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
            toggleBtn.TextColor3 = Color3.new(1,1,1)
        end
    end)

    toggleBtn.MouseButton1Click:Connect(function()
        if not targetPosition then
            status.Text = "先に場所を決めて!"
            return
        end
        isRunning = not isRunning
        if isRunning then
            toggleBtn.Text = "STOP"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
            status.Text = "連打中..."
        else
            toggleBtn.Text = "START"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
            status.Text = "停止中"
        end
    end)

    -- 連打ループ
    task.spawn(function()
        while task.wait(clickSpeed) do
            if isRunning and targetPosition then
                pcall(function()
                    local pos = Vector2.new(targetPosition.X, targetPosition.Y)
                    VirtualInputManager:SendTouchEvent(pos, 0, 0) -- Touch Start
                    task.wait(0.01)
                    VirtualInputManager:SendTouchEvent(pos, 0, 2) -- Touch End
                end)
                -- マーカーフィードバック
                TweenService:Create(marker, TweenInfo.new(0.05), {Size = UDim2.new(0, 15, 0, 15)}):Play()
                task.delay(0.05, function()
                    marker.Size = UDim2.new(0, 20, 0, 20)
                end)
            end
        end
    end)
end

-- 生成ボタン接続
GenerateBtn.MouseButton1Click:Connect(createFlingClicker)

print("Stealth Fling Mobile Clicker Hub Loaded ⚡")
