-- Grok's Final Stealth Clicker Hub - REBORN (Fixed by Gemini)
-- 修正版: 変数スコープ修正, Parent自動判定, エラー回避処理追加

local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- GUI作成
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FinalStealthHub_Fixed"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 親の設定（CoreGuiが使えない場合はPlayerGuiを使う安全設計）
local success, err = pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)
if not success then
    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- メインフレーム
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 400)
MainFrame.Position = UDim2.new(0.5, -170, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
MainFrame.Parent = ScreenGui
MainFrame.Active = true -- ドラッグ動作の安定化

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
TitleLabel.Text = "⚡ Final Clicker Hub (Fixed)"
TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- 最小化ボタン
local minimizeLevel = 0
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -70, 0, 5)
MinimizeBtn.Text = "−"
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeBtn.TextColor3 = Color3.new(1,1,1)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18
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
CloseBtn.TextSize = 18
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- スクロールフレーム
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -60)
ScrollFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- 自動調整用
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y -- 縦幅自動調整
ScrollFrame.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 12)
ListLayout.Parent = ScrollFrame

-- 生成ボタン情報
local buttonInfos = {
    {name = "PC Clicker", color = Color3.fromRGB(50, 50, 120), text = "P", type = "clicker", mode = "pc"},
    {name = "Mobile Clicker", color = Color3.fromRGB(50, 120, 50), text = "M", type = "clicker", mode = "mobile"},
    {name = "PC Slider", color = Color3.fromRGB(80, 80, 140), text = "S", type = "slider", mode = "pc"},
    {name = "Mobile Slider", color = Color3.fromRGB(80, 140, 80), text = "S", type = "slider", mode = "mobile"}
}

local genButtons = {}

for i, info in ipairs(buttonInfos) do
    local genBtn = Instance.new("TextButton")
    genBtn.Size = UDim2.new(1, -10, 0, 50) -- スクロールバー考慮
    genBtn.Text = "Generate " .. info.name
    genBtn.BackgroundColor3 = info.color
    genBtn.TextColor3 = Color3.fromRGB(220, 240, 255)
    genBtn.Font = Enum.Font.GothamBold
    genBtn.TextSize = 16
    genBtn.Parent = ScrollFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = genBtn
    
    table.insert(genButtons, genBtn)
end

-- 状態変数
local pcClicking = false
local mobileClicking = false
local pcDelay = 0.1
local mobileDelay = 0.1

-- ★重要修正: createFloatButtonに関数引数 index を追加
local function createFloatButton(info, index)
    local btn = Instance.new("TextButton")
    local isMobile = UserInputService.TouchEnabled
    
    btn.Size = isMobile and UDim2.new(0, 100, 0, 55) or UDim2.new(0, 90, 0, 50)
    -- indexを使ってずらして配置（indexが無いとエラーになります）
    btn.Position = UDim2.new(0.05, 0, 0.2 + (index * 0.12), 0)
    btn.BackgroundColor3 = info.color
    btn.Text = info.text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 24
    btn.BackgroundTransparency = info.type == "slider" and 0.1 or 0.2
    btn.Parent = ScreenGui
    btn.Active = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = btn

    -- 位置固定トグル (TextButtonに変更して反応を良くする)
    local locked = false
    local lockBtn = Instance.new("TextButton")
    lockBtn.Size = UDim2.new(0, 24, 0, 24)
    lockBtn.Position = UDim2.new(1, -28, 0, 4)
    lockBtn.Text = "🔓"
    lockBtn.BackgroundTransparency = 1
    lockBtn.TextColor3 = Color3.fromRGB(255, 255, 120)
    lockBtn.Font = Enum.Font.GothamBold
    lockBtn.TextSize = 18
    lockBtn.Parent = btn

    lockBtn.MouseButton1Click:Connect(function()
        locked = not locked
        lockBtn.Text = locked and "🔒" or "🔓"
    end)

    if info.type == "slider" then
        -- スライダー機能
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0.75, 0, 0, 10)
        bar.Position = UDim2.new(0.125, 0, 0.6, 0)
        bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        bar.BorderSizePixel = 0
        bar.Parent = btn

        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(1, 0)
        barCorner.Parent = bar

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 18, 0, 18)
        knob.Position = UDim2.new(0, -9, 0.5, -9)
        knob.AnchorPoint = Vector2.new(0, 0) -- 修正
        knob.BackgroundColor3 = Color3.fromRGB(0, 220, 255)
        knob.BorderSizePixel = 0
        knob.Parent = bar

        local kcorner = Instance.new("UICorner")
        kcorner.CornerRadius = UDim.new(1, 0)
        kcorner.Parent = knob

        local isDraggingSlider = false

        local function updateSlider(inputPos)
            if not bar or not bar.Parent then return end
            local barAbsPos = bar.AbsolutePosition
            local barAbsSize = bar.AbsoluteSize
            
            if barAbsSize.X == 0 then return end -- ゼロ除算回避

            local relativeX = inputPos.X - barAbsPos.X
            local scale = math.clamp(relativeX / barAbsSize.X, 0, 1)
            
            knob.Position = UDim2.new(scale, -9, 0.5, -9)
            
            -- 遅延計算 (右に行くほど高速 = delay小)
            local delay = 0.5 * (1 - scale) -- 最大0.5秒, 最小0秒付近
            if delay < 0.001 then delay = 0 end -- 最速
            
            if info.mode == "pc" then pcDelay = delay else mobileDelay = delay end
        end

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDraggingSlider = true
                updateSlider(input.Position)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if isDraggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateSlider(input.Position)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDraggingSlider = false
            end
        end)

    else
        -- クリッカー機能 (トグル)
        local active = false
        btn.MouseButton1Click:Connect(function()
            if locked then return end -- ロック中はトグル不可ならコメントアウト外す
            -- ボタン自体をクリックした時の処理
            active = not active
            btn.BackgroundTransparency = active and 0 or 0.2
            
            if info.mode == "pc" then 
                pcClicking = active 
            else 
                mobileClicking = active 
            end
        end)
    end

    -- フローティングボタン自体のドラッグ処理
    local dragToggle = false
    local dragStart = nil
    local startPos = nil
    
    btn.InputBegan:Connect(function(input)
        if locked then return end
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragToggle = true
            dragStart = input.Position
            startPos = btn.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = false
        end
    end)
end

-- 生成ボタンへの接続
for i, genBtn in ipairs(genButtons) do
    genBtn.MouseButton1Click:Connect(function()
        -- ★ここで i (インデックス) を渡すように修正しました
        createFloatButton(buttonInfos[i], i)
    end)
end

-- クリック処理ループ
task.spawn(function()
    while true do
        -- PC Clicker Logic
        if pcClicking then
            pcall(function()
                VirtualUser:Button1Down(Vector2.new(0,0))
                VirtualUser:Button1Up(Vector2.new(0,0))
            end)
            if pcDelay > 0 then task.wait(pcDelay) else task.wait() end
        end
        
        -- Mobile Clicker Logic (CaptureControllerが必要な場合)
        if mobileClicking then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(0,0))
                VirtualUser:Button1Up(Vector2.new(0,0))
            end)
            if mobileDelay > 0 then task.wait(mobileDelay) else task.wait() end
        end
        
        if not pcClicking and not mobileClicking then
            task.wait(0.2) -- 負荷軽減
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
        MinimizeBtn.Text = "−"
        MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    else
        MainFrame.Size = UDim2.new(0, 50, 0, 40)
        ScrollFrame.Visible = false
        MinimizeBtn.Text = ""
        MinimizeBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    end
end)

-- メインUIドラッグ処理
local guiDragging = false
local guiDragStart, guiStartPos

TitleBar.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        guiDragging = true
        guiDragStart = input.Position
        guiStartPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if guiDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - guiDragStart
        MainFrame.Position = UDim2.new(guiStartPos.X.Scale, guiStartPos.X.Offset + delta.X, guiStartPos.Y.Scale, guiStartPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        guiDragging = false
    end
end)

print("Final Stealth Clicker Hub REBORN - Fully Fixed! ⚡")
