-- Grok's Ultimate Stealth Clicker Hub v3 (With Sliders & Lock Toggle)
-- 超高速可変, PC/Mobile別, 4つの小型ボタン(クリッカー×2 + スライダー×2), 位置固定機能

local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateStealthHub"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

-- メインフレーム（クール黒デザイン）
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 240)
MainFrame.Position = UDim2.new(0.5, -170, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

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
TitleLabel.Text = "⚡ Ultimate Clicker Hub"
TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- 最小化（3段階）
local minimizeLevel = 0
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -70, 0, 5)
MinimizeBtn.Text = "−"
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeBtn.TextColor3 = Color3.new(1,1,1)
MinimizeBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinimizeBtn

MinimizeBtn.MouseButton1Click:Connect(function()
    minimizeLevel = (minimizeLevel + 1) % 3
    if minimizeLevel == 0 then
        MainFrame.Size = UDim2.new(0, 340, 0, 240)
        MinimizeBtn.Text = "−"
    elseif minimizeLevel == 1 then
        MainFrame.Size = UDim2.new(0, 340, 0, 40)
        MinimizeBtn.Text = "□"
    else
        MainFrame.Size = UDim2.new(0, 170, 0, 40)
        MinimizeBtn.Text = "⚡"
    end
end)

-- 閉じる
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

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- コンテンツ（生成ボタン4つ）
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -60)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local buttons = {
    {name = "PC Clicker", color = Color3.fromRGB(50, 50, 120), type = "clicker", mode = "pc"},
    {name = "Mobile Clicker", color = Color3.fromRGB(50, 120, 50), type = "clicker", mode = "mobile"},
    {name = "PC Slider", color = Color3.fromRGB(80, 80, 140), type = "slider", mode = "pc"},
    {name = "Mobile Slider", color = Color3.fromRGB(80, 140, 80), type = "slider", mode = "mobile"}
}

for i, btnInfo in ipairs(buttons) do
    local genBtn = Instance.new("TextButton")
    genBtn.Size = UDim2.new(0.9, 0, 0, 45)
    genBtn.Position = UDim2.new(0.05, 0, 0, 10 + (i-1)*55)
    genBtn.Text = "Generate " .. btnInfo.name
    genBtn.BackgroundColor3 = btnInfo.color
    genBtn.TextColor3 = Color3.fromRGB(220, 240, 255)
    genBtn.Font = Enum.Font.Gotham
    genBtn.Parent = Content

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = genBtn
end

-- 状態変数
local pcClicking = false
local mobileClicking = false
local pcDelay = 0.1  -- 初期 10CPS
local mobileDelay = 0.1

-- 小型ボタン作成関数（固定トグル付き）
local function createFloatButton(info)
    local isSlider = info.type == "slider"
    local btn = Instance.new("TextButton")
    btn.Size = UserInputService.TouchEnabled and UDim2.new(0, 90, 0, 50) or UDim2.new(0, 80, 0, 45)  -- 少し横長
    btn.Position = UDim2.new(0.02, 0, 0.4 + i*0.1, 0)
    btn.BackgroundColor3 = info.color
    btn.Text = isSlider and "S" or info.name:sub(1,1)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.BackgroundTransparency = isSlider and 0.1 or 0.2
    btn.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = btn

    -- 固定トグル
    local locked = false
    local lockLabel = Instance.new("TextLabel")
    lockLabel.Size = UDim2.new(0, 20, 0, 20)
    lockLabel.Position = UDim2.new(1, -25, 0, 5)
    lockLabel.Text = "🔓"
    lockLabel.BackgroundTransparency = 1
    lockLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
    lockLabel.Font = Enum.Font.GothamBold
    lockLabel.Parent = btn

    lockLabel.MouseButton1Click:Connect(function()
        locked = not locked
        lockLabel.Text = locked and "🔒" or "🔓"
    end)

    -- スライダー機能（PC/Mobile別）
    if isSlider then
        local sliderBar = Instance.new("Frame")
        sliderBar.Size = UDim2.new(0.7, 0, 0, 8)
        sliderBar.Position = UDim2.new(0.15, 0, 0.6, 0)
        sliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        sliderBar.Parent = btn

        local sliderKnob = Instance.new("Frame")
        sliderKnob.Size = UDim2.new(0, 16, 0, 16)
        sliderKnob.Position = UDim2.new(0, -8, 0, -4)
        sliderKnob.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        sliderKnob.Parent = sliderBar

        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(1, 0)
        knobCorner.Parent = sliderKnob

        local function updateDelay(input)
            if locked then return end
            local relX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
            sliderKnob.Position = UDim2.new(relX, -8, 0, -4)
            local delay = 0.1 * (1 - relX)^2 + 0.000001 * relX  -- 0.1 → 0.000001 の滑らか変化
            if info.mode == "pc" then pcDelay = delay else mobileDelay = delay end
        end

        sliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                updateDelay(input)
            end
        end)
        sliderBar.InputChanged:Connect(function(input)
            if input.UserInputState == Enum.UserInputState.Change then
                updateDelay(input)
            end
        end)
    else
        -- クリッカー機能
        local active = false
        btn.MouseButton1Click:Connect(function()
            if locked then return end
            active = not active
            btn.BackgroundTransparency = active and 0 or 0.2
            if info.mode == "pc" then pcClicking = active else mobileClicking = active end
        end)
    end

    -- ドラッグ（ロック中は無効）
    local dragging = false
    local dragStart, startPos
    btn.InputBegan:Connect(function(input)
        if locked then return end
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
end

-- 生成ボタン接続
Content:FindFirstChildWhichIsA("TextButton").MouseButton1Click:Connect(function() createFloatButton(buttons[1]) end)
Content:GetChildren()[2].MouseButton1Click:Connect(function() createFloatButton(buttons[2]) end)
Content:GetChildren()[3].MouseButton1Click:Connect(function() createFloatButton(buttons[3]) end)
Content:GetChildren()[4].MouseButton1Click:Connect(function() createFloatButton(buttons[4]) end)

-- 超高速クリックループ
RunService.Heartbeat:Connect(function()
    if pcClicking and pcDelay > 0 then
        VirtualUser:ClickButton1(Vector2.new())
        task.wait(pcDelay)
    end
    if mobileClicking and mobileDelay > 0 then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new())
        task.wait(mobileDelay)
    end
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

print("Ultimate Stealth Clicker Hub v3 Loaded ⚡")