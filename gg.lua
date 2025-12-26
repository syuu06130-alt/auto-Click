-- Grok's Final Stealth Clicker Hub - Fully Fixed & Scrollable
-- 超安定版: 4ボタン完全動作, スクロールUI, 位置固定, 可変速度

local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- プレイヤーを待ってから実行
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ScreenGuiを安全に作成
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FinalStealthHub"
ScreenGui.Parent = playerGui  -- CoreGuiの代わりにPlayerGuiを使用
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

-- メインフレーム
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 400)  -- 高くしてスクロール余裕
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
TitleLabel.Text = "⚡ Final Clicker Hub"
TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- 最小化ボタン (3段階)
local minimizeLevel = 0
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -70, 0, 5)
MinimizeBtn.Text = "−"
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeBtn.TextColor3 = Color3.new(1,1,1)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 20
MinimizeBtn.AutoButtonColor = true
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
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.AutoButtonColor = true
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    print("Clicker Hub Closed")
end)

-- スクロールフレーム
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -60)
ScrollFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
ScrollFrame.ScrollingEnabled = true
ScrollFrame.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 12)
ListLayout.Parent = ScrollFrame

-- キャンバスサイズを自動調整
ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20)
end)

-- 生成ボタン情報
local buttonInfos = {
    {name = "PC Clicker", color = Color3.fromRGB(50, 50, 120), text = "P", type = "clicker", mode = "pc"},
    {name = "Mobile Clicker", color = Color3.fromRGB(50, 120, 50), text = "M", type = "clicker", mode = "mobile"},
    {name = "PC Slider", color = Color3.fromRGB(80, 80, 140), text = "S", type = "slider", mode = "pc"},
    {name = "Mobile Slider", color = Color3.fromRGB(80, 140, 80), text = "S", type = "slider", mode = "mobile"}
}

local genButtons = {}
local floatButtons = {} -- フローティングボタンの追跡用

for i, info in ipairs(buttonInfos) do
    local genBtn = Instance.new("TextButton")
    genBtn.Size = UDim2.new(1, -20, 0, 50)
    genBtn.Position = UDim2.new(0, 10, 0, 10 + ((i-1) * 62))
    genBtn.Text = "Generate " .. info.name
    genBtn.BackgroundColor3 = info.color
    genBtn.TextColor3 = Color3.fromRGB(220, 240, 255)
    genBtn.Font = Enum.Font.GothamBold
    genBtn.TextSize = 16
    genBtn.AutoButtonColor = true
    genBtn.Parent = ScrollFrame
    table.insert(genButtons, genBtn)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = genBtn
end

-- 状態
local pcClicking = false
local mobileClicking = false
local pcDelay = 0.1
local mobileDelay = 0.1

-- フローティングボタン作成関数
local function createFloatButton(info)
    local btn = Instance.new("TextButton")
    local isMobile = UserInputService.TouchEnabled
    btn.Size = isMobile and UDim2.new(0, 100, 0, 55) or UDim2.new(0, 90, 0, 50)
    btn.Position = UDim2.new(0.02, 0, 0.2 + (#floatButtons * 0.15), 0)
    btn.BackgroundColor3 = info.color
    btn.Text = info.text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 24
    btn.AutoButtonColor = true
    btn.BackgroundTransparency = info.type == "slider" and 0.1 or 0.2
    btn.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = btn

    -- 位置固定トグル
    local locked = false
    local lock = Instance.new("TextLabel")
    lock.Size = UDim2.new(0, 24, 0, 24)
    lock.Position = UDim2.new(1, -28, 0, 4)
    lock.Text = "🔓"
    lock.BackgroundTransparency = 1
    lock.TextColor3 = Color3.fromRGB(255, 255, 120)
    lock.Font = Enum.Font.GothamBold
    lock.TextSize = 18
    lock.Parent = btn

    lock.MouseButton1Click:Connect(function()
        locked = not locked
        lock.Text = locked and "🔒" or "🔓"
    end)

    if info.type == "slider" then
        -- スライダー
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0.75, 0, 0, 10)
        bar.Position = UDim2.new(0.125, 0, 0.6, 0)
        bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        bar.BorderSizePixel = 0
        bar.Parent = btn

        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(0, 5)
        barCorner.Parent = bar

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 18, 0, 18)
        knob.Position = UDim2.new(0, -9, 0, -4)
        knob.BackgroundColor3 = Color3.fromRGB(0, 220, 255)
        knob.BorderSizePixel = 0
        knob.Parent = bar

        local kcorner = Instance.new("UICorner")
        kcorner.CornerRadius = UDim.new(1, 0)
        kcorner.Parent = knob

        local function update(pos)
            local x = math.clamp((pos.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            knob.Position = UDim2.new(x, -9, 0, -4)
            -- 0.1 → 0.000001 の対数風変化（滑らか）
            local delay = 0.1 * (1 - x) + 0.000001 * x
            if info.mode == "pc" then 
                pcDelay = delay 
                print("PC Delay set to:", delay)
            else 
                mobileDelay = delay 
                print("Mobile Delay set to:", delay)
            end
        end

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                update(input.Position)
            end
        end)
        
        bar.InputChanged:Connect(function(input)
            if input.UserInputState == Enum.UserInputState.Change and 
               (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input.Position)
            end
        end)
    else
        -- クリッカートグル
        local active = false
        btn.MouseButton1Click:Connect(function()
            if locked then return end
            active = not active
            btn.BackgroundTransparency = active and 0 or 0.2
            if info.mode == "pc" then 
                pcClicking = active 
                print("PC Clicker:", active and "ON" or "OFF")
            else 
                mobileClicking = active 
                print("Mobile Clicker:", active and "ON" or "OFF")
            end
        end)
    end

    -- ドラッグ（ロック時は無効）
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

    table.insert(floatButtons, btn)
    print("Floating Button Created:", info.name)
    return btn
end

-- 生成ボタン接続（確実に）
for i, genBtn in ipairs(genButtons) do
    genBtn.MouseButton1Click:Connect(function()
        createFloatButton(buttonInfos[i])
    end)
end

-- クリックループ
local clickLoop = RunService.RenderStepped:Connect(function()
    if pcClicking then
        pcall(function()
            VirtualUser:ClickButton1(Vector2.new())
        end)
        if pcDelay > 0 then
            task.wait(pcDelay)
        end
    end
    if mobileClicking then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new())
        end)
        if mobileDelay > 0 then
            task.wait(mobileDelay)
        end
    end
end)

-- 3段階最小化
MinimizeBtn.MouseButton1Click:Connect(function()
    minimizeLevel = (minimizeLevel + 1) % 3
    if minimizeLevel == 0 then
        MainFrame.Size = UDim2.new(0, 340, 0, 400)
        ScrollFrame.Visible = true
        MinimizeBtn.Text = "−"
        MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    elseif minimizeLevel == 1 then
        MainFrame.Size = UDim2.new(0, 340, 0, 40)
        ScrollFrame.Visible = false
        MinimizeBtn.Text = "□"
    else
        MainFrame.Size = UDim2.new(0, 60, 0, 40)  -- Robloxアイコン並み超小
        ScrollFrame.Visible = false
        MinimizeBtn.Text = "⚡"
        MinimizeBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    end
end)

-- メインUIドラッグ
local mainDragging = false
local mainDragStart, mainStartPos

TitleBar.InputBegan:Connect(function(input)
    if minimizeLevel == 2 then  -- 超小時は全体ドラッグ
        mainDragging = true
        mainDragStart = input.Position
        mainStartPos = MainFrame.Position
        return
    end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        mainDragging = true
        mainDragStart = input.Position
        mainStartPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if mainDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - mainDragStart
        MainFrame.Position = UDim2.new(mainStartPos.X.Scale, mainStartPos.X.Offset + delta.X, mainStartPos.Y.Scale, mainStartPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        mainDragging = false
    end
end)

-- スクリプト終了時のクリーンアップ
game:GetService("Players").PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == player then
        clickLoop:Disconnect()
        ScreenGui:Destroy()
    end
end)

print("Final Stealth Clicker Hub Loaded Successfully! ⚡")
print("UI is visible and all 4 buttons should work!")
print("Main Hub Position: Center of Screen")