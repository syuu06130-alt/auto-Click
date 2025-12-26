-- Grok's High-Speed Clicker Hub (Universal Auto Clicker GUI)
-- 特徴: 高速オートクリック、速度調整、トグルON/OFF、CPS表示

local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

-- GUI作成
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleButton = Instance.new("TextButton")
local SpeedSlider = Instance.new("Slider") -- 簡易スライダー風
local CPSLabel = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")

ScreenGui.Name = "HighSpeedClickerHub"
ScreenGui.Parent = game.CoreGui

MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 170, 255)
MainFrame.Parent = ScreenGui

Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "🚀 High-Speed Clicker Hub by Grok"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = MainFrame

ToggleButton.Size = UDim2.new(0.8, 0, 0, 40)
ToggleButton.Position = UDim2.new(0.1, 0, 0.3, 0)
ToggleButton.Text = "OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ToggleButton.Parent = MainFrame

CPSLabel.Size = UDim2.new(0.8, 0, 0, 30)
CPSLabel.Position = UDim2.new(0.1, 0, 0.55, 0)
CPSLabel.Text = "Speed: Normal"
CPSLabel.TextColor3 = Color3.new(1,1,1)
CPSLabel.BackgroundTransparency = 1
CPSLabel.Parent = MainFrame

CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.Text = "X"
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
CloseButton.Parent = MainFrame

-- 変数
local clicking = false
local clickDelay = 0.01  -- 初期速度 (小さいほど高速)

-- トグル機能
ToggleButton.MouseButton1Click:Connect(function()
    clicking = not clicking
    if clicking then
        ToggleButton.Text = "ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        spawn(function()
            while clicking do
                VirtualUser:ClickButton1(Vector2.new())  -- 超高速クリック
                wait(clickDelay)
            end
        end)
    else
        ToggleButton.Text = "OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

-- 速度調整 (マウスホイールで簡易調整例)
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        if input.Position.Z > 0 then
            clickDelay = math.max(0, clickDelay - 0.005)
        else
            clickDelay = clickDelay + 0.005
        end
        if clickDelay == 0 then
            CPSLabel.Text = "Speed: ULTRA FAST (Per Frame!)"
        else
            CPSLabel.Text = "Speed: " .. string.format("%.3f", clickDelay) .. " sec"
        end
    end
end)

-- 閉じる
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ドラッグ可能にする
local dragging
local dragInput
local dragStart
local startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("High-Speed Clicker Hub Loaded! 🚀")