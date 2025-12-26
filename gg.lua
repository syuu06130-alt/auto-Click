-- Grok's Ultimate Stealth Clicker Hub - Final Stable Version
-- 参考コードベースで完全安定動作 + スライダー + 4ボタン + スクロール + 位置固定

local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateStealthHub"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

-- メインフレーム
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 400)
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
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Text = "⚡ Ultimate Clicker"
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
MinimizeBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinimizeBtn

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

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- スクロールコンテンツ
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -60)
ScrollFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
ScrollFrame.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 15)
ListLayout.Parent = ScrollFrame

-- 生成ボタン定義
local genButtons = {
    {name = "PC Clicker", color = Color3.fromRGB(50, 50, 120), mark = "P", type = "clicker", mode = "pc"},
    {name = "Mobile Clicker", color = Color3.fromRGB(50, 120, 50), mark = "M", type = "clicker", mode = "mobile"},
    {name = "PC Slider", color = Color3.fromRGB(80, 80, 140), mark = "S", type = "slider", mode = "pc"},
    {name = "Mobile Slider", color = Color3.fromRGB(80, 140, 80), mark = "S", type = "slider", mode = "mobile"}
}

local generateBtns = {}

for _, info in ipairs(genButtons) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 50)
    btn.Text = "Generate " .. info.name
    btn.BackgroundColor3 = info.color
    btn.TextColor3 = Color3.fromRGB(220, 240, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Parent = ScrollFrame
    table.insert(generateBtns, btn)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn
end

-- 状態変数
local pcClicking = false
local mobileClicking = false
local pcDelay = 0.1
local mobileDelay = 0.1
local minimizeLevel = 0

-- 小型フローティングボタン生成関数
local function createFloatButton(info)
    local btn = Instance.new("TextButton")
    btn.Size = UserInputService.TouchEnabled and UDim2.new(0, 100, 0, 55) or UDim2.new(0, 90, 0, 50)
    btn.Position = UDim2.new(0.05, 0, 0.4, 0)
    btn.BackgroundColor3 = info.color
    btn.Text = info.mark
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 24
    btn.BackgroundTransparency = info.type == "slider" and 0.1 or 0.2
    btn.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = btn

    -- 位置固定トグル
    local locked = false
    local lockLabel = Instance.new("TextLabel")
    lockLabel.Size = UDim2.new(0, 24, 0, 24)
    lockLabel.Position = UDim2.new(1, -28, 0, 4)
    lockLabel.Text = "🔓"
    lockLabel.BackgroundTransparency = 1
    lockLabel.TextColor3 = Color3.fromRGB(255, 255, 120)
    lockLabel.Font = Enum.Font.GothamBold
    lockLabel.TextSize = 18
    lockLabel.Parent = btn

    lockLabel.MouseButton1Click:Connect(function()
        locked = not locked
        lockLabel.Text = locked and "🔒" or "🔓"
    end)

    if info.type == "slider" then
        -- スライダー部分
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0.75, 0, 0, 10)
        bar.Position = UDim2.new(0.125, 0, 0.6, 0)
        bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        bar.Parent = btn

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 18, 0, 18)
        knob.Position = UDim2.new(0, -9, 0, -4)  -- 初期位置（遅め）
        knob.BackgroundColor3 = Color3.fromRGB(0, 220, 255)
        knob.Parent = bar

        local kcorner = Instance.new("UICorner")
        kcorner.CornerRadius = UDim.new(1, 0)
        kcorner.Parent = knob

        local function updateDelay(pos)
            local x = math.clamp((pos.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            knob.Position = UDim2.new(x, -9, 0, -4)
            local delay = 0.1 * (1 - x) + 0.000001 * x
            if info.mode == "pc" then pcDelay = delay else mobileDelay = delay end
        end

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                updateDelay(input.Position)
            end
        end)
        bar.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                updateDelay(input.Position)
            end
        end)
    else
        -- クリッカーON/OFF
        local active = false
        btn.MouseButton1Click:Connect(function()
            if locked then return end
            active = not active
            btn.BackgroundTransparency = active and 0 or 0.2
            if info.mode == "pc" then pcClicking = active else mobileClicking = active end
        end)
    end

    -- ドラッグ機能（ロック時は無効）
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

-- Generateボタン接続（参考コードと同じ安定方式）
generateBtns[1].MouseButton1Click:Connect(function() createFloatButton(genButtons[1]) end)
generateBtns[2].MouseButton1Click:Connect(function() createFloatButton(genButtons[2]) end)
generateBtns[3].MouseButton1Click:Connect(function() createFloatButton(genButtons[3]) end)
generateBtns[4].MouseButton1Click:Connect(function() createFloatButton(genButtons[4]) end)

-- クリックループ
spawn(function()
    while true do
        if pcClicking then
            VirtualUser:ClickButton1(Vector2.new())
            task.wait(pcDelay)
        end
        if mobileClicking then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new())
            task.wait(mobileDelay)
        end
        task.wait()
    end
end)

-- 3段階最小化
MinimizeBtn.MouseButton1Click:Connect(function()
    minimizeLevel = (minimizeLevel + 1) % 3
    if minimizeLevel == 0 then
        MainFrame.Size = UDim2.new(0, 340, 0, 400)
        ScrollFrame.Visible = true
        MinimizeBtn.Text = "−"
    elseif minimizeLevel == 1 then
        MainFrame.Size = UDim2.new(0, 340, 0, 40)
        ScrollFrame.Visible = false
        MinimizeBtn.Text = "−"
    else
        MainFrame.Size = UDim2.new(0, 60, 0, 40)  -- Robloxアイコンサイズ
        ScrollFrame.Visible = false
        MinimizeBtn.Text = ""
        MinimizeBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    end
end)

-- メインUIドラッグ
local dragging = false
local dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if minimizeLevel == 2 then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- 超小モードでもドラッグ可能
MainFrame.InputBegan:Connect(function(input)
    if minimizeLevel == 2 and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

print("Ultimate Stealth Clicker Hub - Final Stable Version Loaded ⚡")