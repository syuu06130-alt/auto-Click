-- 統合版 Stealth High-Speed Clicker Hub
-- PC用通常クリッカー + Mobile用場所指定クリッカー
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealthClickerHub"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 状態管理
local pcClicking = false
local mobileClicking = false
local mobileTargetPosition = nil
local isSelecting = false
local minimizeLevel = 0
local clickSpeed = 0.001

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
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Text = "⚡ Stealth Clicker Hub"
TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- 最小化ボタン
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -70, 0, 5)
MinimizeBtn.Text = "−"
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeBtn.TextColor3 = Color3.new(1,1,1)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18
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
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
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

-- PC Clicker トグル生成ボタン
local PCButtonGen = Instance.new("TextButton")
PCButtonGen.Size = UDim2.new(0.9, 0, 0, 45)
PCButtonGen.Position = UDim2.new(0.05, 0, 0, 10)
PCButtonGen.Text = "🖱️ Generate PC Clicker"
PCButtonGen.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
PCButtonGen.TextColor3 = Color3.fromRGB(180, 220, 255)
PCButtonGen.Font = Enum.Font.GothamBold
PCButtonGen.TextSize = 14
PCButtonGen.Parent = Content

local PCCorner = Instance.new("UICorner")
PCCorner.CornerRadius = UDim.new(0, 10)
PCCorner.Parent = PCButtonGen

-- Mobile Clicker トグル生成ボタン
local MobileButtonGen = Instance.new("TextButton")
MobileButtonGen.Size = UDim2.new(0.9, 0, 0, 45)
MobileButtonGen.Position = UDim2.new(0.05, 0, 0, 65)
MobileButtonGen.Text = "📱 Generate Mobile Clicker"
MobileButtonGen.BackgroundColor3 = Color3.fromRGB(30, 50, 30)
MobileButtonGen.TextColor3 = Color3.fromRGB(180, 255, 200)
MobileButtonGen.Font = Enum.Font.GothamBold
MobileButtonGen.TextSize = 14
MobileButtonGen.Parent = Content

local MobileCorner = Instance.new("UICorner")
MobileCorner.CornerRadius = UDim.new(0, 10)
MobileCorner.Parent = MobileButtonGen

-- ステータス表示
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.05, 0, 0, 120)
StatusLabel.Text = "Ready"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.Parent = Content

-- ターゲットマーカー（ピンク色の点）
local Marker = Instance.new("Frame")
Marker.Name = "TargetMarker"
Marker.Size = UDim2.new(0, 24, 0, 24)
Marker.AnchorPoint = Vector2.new(0.5, 0.5)
Marker.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
Marker.BackgroundTransparency = 0.3
Marker.BorderSizePixel = 2
Marker.BorderColor3 = Color3.fromRGB(255, 255, 255)
Marker.Visible = false
Marker.ZIndex = 10000
Marker.Parent = ScreenGui

local MarkerCorner = Instance.new("UICorner")
MarkerCorner.CornerRadius = UDim.new(1, 0)
MarkerCorner.Parent = Marker

-- 選択モード用オーバーレイ
local SelectionOverlay = Instance.new("TextButton")
SelectionOverlay.Name = "SelectionOverlay"
SelectionOverlay.Size = UDim2.new(1, 0, 1, 0)
SelectionOverlay.BackgroundTransparency = 0.7
SelectionOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
SelectionOverlay.Text = "📍 連打したい場所をタップしてください"
SelectionOverlay.TextColor3 = Color3.fromRGB(255, 255, 0)
SelectionOverlay.TextSize = 24
SelectionOverlay.Font = Enum.Font.GothamBold
SelectionOverlay.Visible = false
SelectionOverlay.ZIndex = 9999
SelectionOverlay.Parent = ScreenGui

-- 小型フローティングボタン生成関数
local function createFloatButton(name, color, clickFunc)
    local btn = Instance.new("TextButton")
    btn.Size = UserInputService.TouchEnabled and UDim2.new(0, 60, 0, 60) or UDim2.new(0, 50, 0, 50)
    btn.Position = UDim2.new(0.02, 0, 0.5, -30)
    btn.BackgroundColor3 = color
    btn.Text = name:sub(1,1)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 24
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 2
    btn.BorderColor3 = Color3.fromRGB(100, 100, 100)
    btn.Parent = ScreenGui
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = btn
    
    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.BackgroundTransparency = active and 0 or 0.2
        btn.BorderColor3 = active and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(100, 100, 100)
        clickFunc(active)
    end)
    
    -- ドラッグ機能
    local dragging = false
    local dragStart, startPos
    
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
        end
    end)
    
    btn.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    return btn
end

-- PC Clicker生成
PCButtonGen.MouseButton1Click:Connect(function()
    StatusLabel.Text = "PC Clicker Generated!"
    createFloatButton("PC", Color3.fromRGB(50, 50, 120), function(state)
        pcClicking = state
    end)
end)

-- Mobile Clicker生成（場所選択モード開始）
MobileButtonGen.MouseButton1Click:Connect(function()
    isSelecting = true
    mobileClicking = false
    SelectionOverlay.Visible = true
    StatusLabel.Text = "タップして場所を選択中..."
end)

-- 場所選択処理
UserInputService.InputBegan:Connect(function(input)
    if isSelecting and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
        -- 位置を記録
        mobileTargetPosition = input.Position
        
        -- マーカー表示
        Marker.Position = UDim2.new(0, mobileTargetPosition.X, 0, mobileTargetPosition.Y)
        Marker.Visible = true
        
        -- モード終了
        isSelecting = false
        SelectionOverlay.Visible = false
        StatusLabel.Text = "Mobile Clicker Generated!"
        
        -- フローティングボタン生成
        createFloatButton("M", Color3.fromRGB(50, 120, 50), function(state)
            mobileClicking = state
        end)
        
        print("Mobile Target Set at:", mobileTargetPosition)
    end
end)

-- クリックループ（PC用 - 超高速）
task.spawn(function()
    while true do
        if pcClicking then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new())
            end)
        end
        task.wait(clickSpeed)
    end
end)

-- クリックループ（Mobile用 - 場所指定タップ）
task.spawn(function()
    while true do
        if mobileClicking and mobileTargetPosition then
            pcall(function()
                local pos = Vector2.new(mobileTargetPosition.X, mobileTargetPosition.Y)
                
                -- タッチ開始
                VirtualInputManager:SendTouchEvent(pos, 0, 0)
                task.wait(0.01)
                -- タッチ終了
                VirtualInputManager:SendTouchEvent(pos, 0, 2)
                
                -- マーカーアニメーション
                local tween = TweenService:Create(Marker, TweenInfo.new(0.05), {Size = UDim2.new(0, 18, 0, 18)})
                tween:Play()
                task.delay(0.05, function()
                    Marker.Size = UDim2.new(0, 24, 0, 24)
                end)
            end)
        end
        task.wait(0.05)
    end
end)

-- 3段階最小化
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

-- 閉じる
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- メインUIドラッグ機能
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

print("✅ Integrated Stealth Clicker Hub Loaded!")
print("🖱️ PC Clicker: 通常の高速クリック")
print("📱 Mobile Clicker: 場所を指定して連打")
