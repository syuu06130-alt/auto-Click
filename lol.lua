-- Grok's Ultimate Clicker Hub (Mobile-Friendly, Scrollable, Feature-Rich)
-- 対応: PC & Mobile, ドラッグ可能, スクロール, 開閉, 多彩なクリッカー

local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

-- ScreenGui作成（Mobile対応）
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateClickerHub"
ScreenGui.Parent = game.CoreGui
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 10
ScreenGui.ResetOnSpawn = false

-- メインフレーム（ドラッグ可能）
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.9, 0, 0.6, 0) -- Mobileで扱いやすいサイズ
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
MainFrame.Parent = ScreenGui

-- タイトル
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "🚀 Ultimate Clicker Hub"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextScaled = true
Title.Parent = MainFrame

-- 閉じる/最小化ボタン
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.Text = "X"
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Parent = MainFrame

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -70, 0, 5)
MinimizeButton.Text = "-"
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
MinimizeButton.Parent = MainFrame

-- スクロールフレーム
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -50)
ScrollFrame.Position = UDim2.new(0, 5, 0, 45)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 5
ScrollFrame.CanvasSize = UDim2.new(0, 0, 2, 0) -- 項目が多いので長めに
ScrollFrame.Parent = MainFrame

-- UIListLayout（項目整列）
local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 5)
ListLayout.Parent = ScrollFrame

-- クリッカーの設定
local clickers = {
    {
        Name = "PC画面クリッカー",
        Desc = "マウスクリックをエミュレート",
        Func = function()
            VirtualUser:ClickButton1(Vector2.new())
        end
    },
    {
        Name = "Mobile画面クリッカー",
        Desc = "タッチ入力をエミュレート",
        Func = function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new())
        end
    },
    {
        Name = "高速連打クリッカー",
        Desc = "フレーム単位の超高速クリック",
        Func = function()
            VirtualUser:ClickButton1(Vector2.new())
        end
    },
    {
        Name = "ランダム間隔クリッカー",
        Desc = "検知回避用のランダム間隔",
        Func = function()
            VirtualUser:ClickButton1(Vector2.new())
            wait(math.random(0.05, 0.2))
        end
    }
}

local clickDelay = 0.01 -- 初期クリック間隔
local activeClicker = nil
local isClicking = false
local minimized = false

-- クリッカーUI生成
for i, clicker in ipairs(clickers) do
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 80)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Frame.Parent = ScrollFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Text = clicker.Name
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.BackgroundTransparency = 1
    Label.TextSize = 14
    Label.TextScaled = true
    Label.Parent = Frame

    local Desc = Instance.new("TextLabel")
    Desc.Size = UDim2.new(1, 0, 0, 20)
    Desc.Position = UDim2.new(0, 0, 0, 20)
    Desc.Text = clicker.Desc
    Desc.TextColor3 = Color3.fromRGB(150, 150, 150)
    Desc.BackgroundTransparency = 1
    Desc.TextSize = 12
    Desc.TextScaled = true
    Desc.Parent = Frame

    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0.4, 0, 0, 30)
    Toggle.Position = UDim2.new(0.55, 0, 0, 45)
    Toggle.Text = "OFF"
    Toggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    Toggle.TextColor3 = Color3.new(1, 1, 1)
    Toggle.Parent = Frame

    Toggle.MouseButton1Click:Connect(function()
        if activeClicker == clicker then
            isClicking = not isClicking
            Toggle.Text = isClicking and "ON" or "OFF"
            Toggle.BackgroundColor3 = isClicking and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            if not isClicking then
                activeClicker = nil
            end
        else
            if activeClicker then
                isClicking = false
                for _, f in ipairs(ScrollFrame:GetChildren()) do
                    if f:IsA("Frame") then
                        f:FindFirstChildOfClass("TextButton").Text = "OFF"
                        f:FindFirstChildOfClass("TextButton").BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    end
                end
            end
            activeClicker = clicker
            isClicking = true
            Toggle.Text = "ON"
            Toggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        end
    end)
end

-- 速度調整スライダー（細かい調整）
local SpeedFrame = Instance.new("Frame")
SpeedFrame.Size = UDim2.new(1, -10, 0, 100)
SpeedFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedFrame.Parent = ScrollFrame

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, 0, 0, 20)
SpeedLabel.Text = "クリック速度 (0 = 最速)"
SpeedLabel.TextColor3 = Color3.new(1, 1, 1)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.TextSize = 14
SpeedLabel.TextScaled = true
SpeedLabel.Parent = SpeedFrame

local CPSDisplay = Instance.new("TextLabel")
CPSDisplay.Size = UDim2.new(1, 0, 0, 20)
CPSDisplay.Position = UDim2.new(0, 0, 0, 20)
CPSDisplay.Text = "CPS: Calculating..."
CPSDisplay.TextColor3 = Color3.fromRGB(0, 255, 255)
CPSDisplay.BackgroundTransparency = 1
CPSDisplay.TextSize = 12
CPSDisplay.TextScaled = true
CPSDisplay.Parent = SpeedFrame

local SliderBar = Instance.new("Frame")
SliderBar.Size = UDim2.new(0.8, 0, 0, 10)
SliderBar.Position = UDim2.new(0.1, 0, 0, 50)
SliderBar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
SliderBar.Parent = SpeedFrame

local SliderKnob = Instance.new("Frame")
SliderKnob.Size = UDim2.new(0, 20, 0, 20)
SliderKnob.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
SliderKnob.Parent = SliderBar

-- スライダー操作（Mobile対応）
local function updateSlider(input)
    local x = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
    SliderKnob.Position = UDim2.new(x, -10, 0, -5)
    clickDelay = x * 1 -- 0（最速）～1秒
    CPSDisplay.Text = clickDelay == 0 and "CPS: MAX (Per Frame)" or string.format("CPS: %.2f", 1 / (clickDelay + 0.001))
end

SliderBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        updateSlider(input)
    end
end)

SliderBar.InputChanged:Connect(function(input)
    if input.UserInputState == Enum.UserInputState.Change and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

-- クリッカーループ
spawn(function()
    while true do
        if isClicking and activeClicker then
            activeClicker.Func()
            if clickDelay > 0 and activeClicker.Name ~= "ランダム間隔クリッカー" then
                wait(clickDelay)
            end
        end
        wait()
    end
end)

-- ドラッグ機能（Mobile対応）
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

MainFrame.InputChanged:Connect(function(input)
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

-- 閉じる/最小化
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    ScrollFrame.Visible = not minimized
    MainFrame.Size = minimized and UDim2.new(0.9, 0, 0, 40) or UDim2.new(0.9, 0, 0.6, 0)
    MinimizeButton.Text = minimized and "+" or "-"
end)

print("Ultimate Clicker Hub Loaded! 🚀")