--[[
    Unified Stealth Clicker: Location Target Edition
    UI Base: Grok's Stealth Hub (Dark/Cool)
    Logic: Manual Position Target Clicker (Mobile/PC Support)
]]

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- === 設定 ===
local clickSpeed = 0.001 -- 超高速設定 (Script 2準拠)
local isRunning = false
local isSelecting = false
local targetPosition = nil -- Vector2

-- === UI作成 (Script 2のStealth Hubデザインベース) ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealthTargetClicker"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

-- Executor対応 (gethui)
if gethui then
    ScreenGui.Parent = gethui()
else
    if CoreGui:FindFirstChild("RobloxGui") then
        ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
end

-- 1. メインフレーム（黒デザイン）
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 200)
MainFrame.Position = UDim2.new(0.5, -160, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
MainFrame.Active = true
MainFrame.Draggable = true -- ドラッグ可能
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- 2. タイトルバー
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
TitleBar.BackgroundTransparency = 0.5
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

-- タイトル文字
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Text = "⚡ Stealth Target Clicker"
TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- 3. コントロールボタン (最小化・閉じる)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -75, 0, 5)
MinimizeBtn.Text = "−"
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeBtn.TextColor3 = Color3.new(1,1,1)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TitleBar
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 8)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 5)
CloseBtn.Text = "×"
CloseBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

-- 4. コンテンツエリア (機能部分)
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -50)
Content.Position = UDim2.new(0, 10, 0, 45)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- ステータス表示
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Position = UDim2.new(0, 0, 0, 0)
StatusLabel.Text = "Target: None"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 14
StatusLabel.Parent = Content

-- 場所設定ボタン (SET)
local SetBtn = Instance.new("TextButton")
SetBtn.Size = UDim2.new(1, 0, 0, 45)
SetBtn.Position = UDim2.new(0, 0, 0.25, 0)
SetBtn.Text = "Set Click Position 🎯"
SetBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 90)
SetBtn.TextColor3 = Color3.fromRGB(200, 220, 255)
SetBtn.Font = Enum.Font.GothamBold
SetBtn.TextSize = 16
SetBtn.Parent = Content
Instance.new("UICorner", SetBtn).CornerRadius = UDim.new(0, 8)

-- 開始/停止ボタン (START/STOP)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, 0, 0, 45)
ToggleBtn.Position = UDim2.new(0, 0, 0.65, 0)
ToggleBtn.Text = "START CLICKING"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) -- Disabled color
ToggleBtn.TextColor3 = Color3.fromRGB(100, 100, 100)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 16
ToggleBtn.AutoButtonColor = false -- 手動制御
ToggleBtn.Parent = Content
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)

-- === ターゲットマーカー (Script 1の機能) ===
local Marker = Instance.new("Frame")
Marker.Name = "TargetMarker"
Marker.Size = UDim2.new(0, 20, 0, 20)
Marker.AnchorPoint = Vector2.new(0.5, 0.5)
Marker.BackgroundColor3 = Color3.fromRGB(255, 0, 255) -- 目立つピンク
Marker.BackgroundTransparency = 0.3
Marker.Visible = false
Marker.ZIndex = 10000
Marker.Parent = ScreenGui
Instance.new("UICorner", Marker).CornerRadius = UDim.new(1, 0) -- 丸
-- 枠線
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.new(1,1,1)
stroke.Thickness = 2
stroke.Parent = Marker

-- === 選択用オーバーレイ (透明な全画面ボタン) ===
local SelectionOverlay = Instance.new("TextButton")
SelectionOverlay.Name = "Overlay"
SelectionOverlay.Size = UDim2.new(1, 0, 1, 0)
SelectionOverlay.BackgroundTransparency = 0.5
SelectionOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
SelectionOverlay.Text = "Tap the button you want to click!"
SelectionOverlay.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectionOverlay.TextSize = 24
SelectionOverlay.Font = Enum.Font.GothamBold
SelectionOverlay.Visible = false
SelectionOverlay.ZIndex = 9999
SelectionOverlay.Parent = ScreenGui

-- === ロジック実装 ===

-- 1. 場所設定開始
SetBtn.MouseButton1Click:Connect(function()
    isRunning = false
    isSelecting = true
    
    -- UI状態リセット
    ToggleBtn.Text = "START CLICKING"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ToggleBtn.TextColor3 = Color3.fromRGB(100, 100, 100)
    
    StatusLabel.Text = "Select a target..."
    SelectionOverlay.Visible = true
end)

-- 2. 場所決定 (InputBeganを使用)
UserInputService.InputBegan:Connect(function(input)
    if isSelecting and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
        -- 座標取得
        targetPosition = input.Position
        
        -- マーカー移動
        Marker.Position = UDim2.new(0, targetPosition.X, 0, targetPosition.Y)
        Marker.Visible = true
        
        -- モード終了
        isSelecting = false
        SelectionOverlay.Visible = false
        
        -- UI更新
        StatusLabel.Text = string.format("Target: (%d, %d)", targetPosition.X, targetPosition.Y)
        SetBtn.Text = "Reset Position 🎯"
        
        -- スタートボタンを有効化 (赤色：待機中)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- 3. スタート/ストップ切り替え
ToggleBtn.MouseButton1Click:Connect(function()
    if not targetPosition then return end -- 場所が決まってなければ無視
    
    isRunning = not isRunning
    
    if isRunning then
        ToggleBtn.Text = "STOP CLICKING"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- 緑
        StatusLabel.Text = "Status: CLICKING ⚡"
    else
        ToggleBtn.Text = "START CLICKING"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- 赤
        StatusLabel.Text = "Status: PAUSED"
    end
end)

-- 4. 連打ループ (Script 1のVIMロジック + Script 2の高速性)
task.spawn(function()
    while true do
        if isRunning and targetPosition then
            pcall(function()
                local pos = Vector2.new(targetPosition.X, targetPosition.Y)
                
                -- タップイベント送信 (VirtualInputManagerを使用することで正確な位置をタップ)
                VirtualInputManager:SendTouchEvent(pos, 0, 0) -- Touch Start
                -- ごく短時間待機しないと反応しないゲームがあるため微調整 (Script 2より少し安定重視)
                -- もし早すぎて反応しない場合はここを task.wait(0.01) にしてください
                VirtualInputManager:SendTouchEvent(pos, 0, 2) -- Touch End
            end)
            
            -- 視覚エフェクト (マーカーを少し動かす)
            local t = TweenService:Create(Marker, TweenInfo.new(0.05), {Size = UDim2.new(0, 18, 0, 18)})
            t:Play()
            task.delay(0.05, function()
                Marker.Size = UDim2.new(0, 20, 0, 20)
            end)
        end
        
        -- 連打速度待機
        if isRunning then
            task.wait(clickSpeed)
        else
            task.wait(0.1) -- 停止中は負荷を下げる
        end
    end
end)

-- === 最小化ロジック (Script 2から継承) ===
local minimizeLevel = 0 -- 0:Full, 1:Bar, 2:Tiny

MinimizeBtn.MouseButton1Click:Connect(function()
    minimizeLevel = (minimizeLevel + 1) % 3
    
    if minimizeLevel == 0 then -- フル表示
        MainFrame.Size = UDim2.new(0, 320, 0, 200)
        MinimizeBtn.Text = "−"
        Content.Visible = true
        TitleLabel.Text = "⚡ Stealth Target Clicker"
        
    elseif minimizeLevel == 1 then -- タイトルバーのみ
        MainFrame.Size = UDim2.new(0, 320, 0, 40)
        MinimizeBtn.Text = "□"
        Content.Visible = false
        TitleLabel.Text = isRunning and "⚡ Clicking..." or "⚡ Paused"
        
    else -- 超小型 (アイコンのみ)
        MainFrame.Size = UDim2.new(0, 120, 0, 40)
        MinimizeBtn.Text = "⚡"
        Content.Visible = false
        TitleLabel.Text = isRunning and "ON" or "OFF"
    end
end)

-- 閉じる機能
CloseBtn.MouseButton1Click:Connect(function()
    isRunning = false
    ScreenGui:Destroy()
end)

print("Stealth Target Clicker Loaded - UI V2 / Logic V1")
