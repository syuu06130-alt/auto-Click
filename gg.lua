-- Grok's Stealth High-Speed Clicker Hub (Cool Black Design)
-- 超高速固定 (0.001秒), PC/Mobile別, 小型トグルボタン, 3段階最小化

local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- ScreenGuiを安全に作成
local success, ScreenGui = pcall(function()
    local gui = Instance.new("ScreenGui")
    gui.Name = "StealthClickerHub"
    gui.Parent = game:GetService("CoreGui") or game.Players.LocalPlayer:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    return gui
end)

if not success then
    warn("ScreenGuiの作成に失敗しました")
    return
end

-- メインフレーム（クールな黒デザイン）
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 200)
MainFrame.Position = UDim2.new(0.5, -160, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
MainFrame.Visible = true  -- 明示的に表示
MainFrame.Parent = ScreenGui

-- 角を丸く
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
TitleLabel.Text = "⚡ Stealth Clicker"
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
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 20
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
CloseBtn.TextSize = 20
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
PCButtonGen.Text = "Generate PC Clicker Button"
PCButtonGen.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
PCButtonGen.TextColor3 = Color3.fromRGB(180, 220, 255)
PCButtonGen.Font = Enum.Font.Gotham
PCButtonGen.TextSize = 14
PCButtonGen.AutoButtonColor = true
PCButtonGen.Parent = Content

local PCCorner = Instance.new("UICorner")
PCCorner.CornerRadius = UDim.new(0, 10)
PCCorner.Parent = PCButtonGen

-- Mobile Clicker トグル生成ボタン
local MobileButtonGen = Instance.new("TextButton")
MobileButtonGen.Size = UDim2.new(0.9, 0, 0, 45)
MobileButtonGen.Position = UDim2.new(0.05, 0, 0, 65)
MobileButtonGen.Text = "Generate Mobile Clicker Button"
MobileButtonGen.BackgroundColor3 = Color3.fromRGB(30, 50, 30)
MobileButtonGen.TextColor3 = Color3.fromRGB(180, 255, 200)
MobileButtonGen.Font = Enum.Font.Gotham
MobileButtonGen.TextSize = 14
MobileButtonGen.AutoButtonColor = true
MobileButtonGen.Parent = Content

local MobileCorner = Instance.new("UICorner")
MobileCorner.CornerRadius = UDim.new(0, 10)
MobileCorner.Parent = MobileButtonGen

-- 状態
local pcClicking = false
local mobileClicking = false
local minimizeLevel = 0  -- 0:フル, 1:中, 2:超小
local floatButtons = {}

-- 小型ボタン生成関数
local function createFloatButton(name, color, clickFunc)
    local btn = Instance.new("TextButton")
    btn.Size = UserInputService.TouchEnabled and UDim2.new(0, 50, 0, 50) or UDim2.new(0, 40, 0, 40)
    btn.Position = UDim2.new(0.02, 0, 0.5 + (#floatButtons * 0.1), 0)
    btn.BackgroundColor3 = color
    btn.Text = name:sub(1,1)  -- P か M
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 20
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(100, 100, 100)
    btn.AutoButtonColor = true
    btn.Parent = ScreenGui

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)  -- 完全円形
    btnCorner.Parent = btn

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.BackgroundTransparency = active and 0 or 0.2
        btn.BorderColor3 = active and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(100, 100, 100)
        clickFunc(active)
    end)

    -- ドラッグ可能
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

    table.insert(floatButtons, btn)
    return btn
end

-- 生成ボタン機能
PCButtonGen.MouseButton1Click:Connect(function()
    local btn = createFloatButton("PC Clicker", Color3.fromRGB(50, 50, 100), function(state)
        pcClicking = state
        print("PC Clicker:", state and "ON" or "OFF")
    end)
    print("PC Clicker Button Generated")
end)

MobileButtonGen.MouseButton1Click:Connect(function()
    local btn = createFloatButton("Mobile Clicker", Color3.fromRGB(50, 100, 50), function(state)
        mobileClicking = state
        print("Mobile Clicker:", state and "ON" or "OFF")
    end)
    print("Mobile Clicker Button Generated")
end)

-- クリックループ（超高速固定 0.001秒）
local clickConnection
clickConnection = RunService.RenderStepped:Connect(function()
    if pcClicking then
        pcall(function()
            VirtualUser:ClickButton1(Vector2.new())
        end)
    end
    if mobileClicking then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new())
        end)
    end
end)

-- 3段階最小化
MinimizeBtn.MouseButton1Click:Connect(function()
    minimizeLevel = (minimizeLevel + 1) % 3
    if minimizeLevel == 0 then  -- フル
        MainFrame.Size = UDim2.new(0, 320, 0, 200)
        MinimizeBtn.Text = "−"
        Content.Visible = true
    elseif minimizeLevel == 1 then  -- 中
        MainFrame.Size = UDim2.new(0, 320, 0, 40)
        MinimizeBtn.Text = "□"
        Content.Visible = false
    else  -- 超小
        MainFrame.Size = UDim2.new(0, 150, 0, 40)
        MinimizeBtn.Text = "⚡"
        Content.Visible = false
    end
end)

-- 閉じる
CloseBtn.MouseButton1Click:Connect(function()
    if clickConnection then
        clickConnection:Disconnect()
    end
    ScreenGui:Destroy()
    print("Stealth Clicker Hub Closed")
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

print("Stealth Clicker Hub Loaded - Ultra Fast & Cool Design ⚡")
print("UI should be visible on screen!")