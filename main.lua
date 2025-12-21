-- 「Fling Things and People」モバイル専用：場所指定型クリッカー
-- Place ID: 9604086456
-- 特徴：自動検出を廃止し、ユーザーがタップした場所を記憶して連打する方式に変更

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 状態管理
local isRunning = false
local isSelecting = false -- 場所設定モードかどうか
local targetPosition = nil -- 連打する座標 (Vector2)
local clickSpeed = 0.05 -- 連打速度

-- === GUI作成 ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileManualClicker"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 最近のExecutor対応
if gethui then
    screenGui.Parent = gethui()
else
    if CoreGui:FindFirstChild("RobloxGui") then
        screenGui.Parent = CoreGui
    else
        screenGui.Parent = playerGui
    end
end

-- メインフレーム
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 160, 0, 130) -- 少し縦長に
mainFrame.Position = UDim2.new(0.05, 0, 0.4, 0) -- 左側配置
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- ドラッグ可能
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = mainFrame

-- タイトル
local title = Instance.new("TextLabel")
title.Text = "Fling Clicker"
title.Size = UDim2.new(1, 0, 0.2, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = mainFrame

-- ステータス表示
local statusLabel = Instance.new("TextLabel")
statusLabel.Text = "場所未設定"
statusLabel.Size = UDim2.new(1, 0, 0.15, 0)
statusLabel.Position = UDim2.new(0, 0, 0.2, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.Parent = mainFrame

-- 場所設定ボタン
local setBtn = Instance.new("TextButton")
setBtn.Name = "SetButton"
setBtn.Size = UDim2.new(0.8, 0, 0.25, 0)
setBtn.Position = UDim2.new(0.1, 0, 0.4, 0)
setBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255) -- 青
setBtn.Text = "場所を決める (SET)"
setBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
setBtn.Font = Enum.Font.GothamBold
setBtn.TextSize = 12
setBtn.Parent = mainFrame
Instance.new("UICorner", setBtn).CornerRadius = UDim.new(0, 8)

-- 開始/停止ボタン
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Size = UDim2.new(0.8, 0, 0.25, 0)
toggleBtn.Position = UDim2.new(0.1, 0, 0.7, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- グレー（無効状態）
toggleBtn.Text = "START"
toggleBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = mainFrame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

-- ターゲットマーカー（ピンク色の点）
local marker = Instance.new("Frame")
marker.Name = "TargetMarker"
marker.Size = UDim2.new(0, 20, 0, 20)
marker.AnchorPoint = Vector2.new(0.5, 0.5) -- 中心基準
marker.BackgroundColor3 = Color3.fromRGB(255, 0, 255) -- ピンク
marker.BackgroundTransparency = 0.3
marker.BorderSizePixel = 2
marker.BorderColor3 = Color3.fromRGB(255, 255, 255)
marker.Visible = false
marker.ZIndex = 10000 -- 最前面
marker.Parent = screenGui

local markerCorner = Instance.new("UICorner")
markerCorner.CornerRadius = UDim.new(1, 0) -- 丸くする
markerCorner.Parent = marker

-- 選択モード用オーバーレイ（画面全体を覆う透明ボタン）
local selectionOverlay = Instance.new("TextButton")
selectionOverlay.Name = "Overlay"
selectionOverlay.Size = UDim2.new(1, 0, 1, 0)
selectionOverlay.BackgroundTransparency = 0.8
selectionOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
selectionOverlay.Text = "連打したいボタンをタップしてください"
selectionOverlay.TextColor3 = Color3.fromRGB(255, 255, 255)
selectionOverlay.TextSize = 24
selectionOverlay.Font = Enum.Font.GothamBold
selectionOverlay.Visible = false
selectionOverlay.ZIndex = 9999
selectionOverlay.Parent = screenGui

-- === 機能ロジック ===

-- 1. 「場所を決める」ボタンを押したとき
setBtn.MouseButton1Click:Connect(function()
    isRunning = false
    isSelecting = true
    
    -- UI更新
    toggleBtn.Text = "START"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    statusLabel.Text = "ボタンをタップ..."
    
    -- オーバーレイ表示
    selectionOverlay.Visible = true
end)

-- 2. 画面をタップして場所を決める処理
selectionOverlay.MouseButton1Click:Connect(function()
    -- マウス/タッチの位置を取得
    local mouseLoc = UserInputService:GetMouseLocation()
    
    -- ターゲット位置を保存 (GUIのInsetを考慮しないといけない場合があるため調整)
    -- モバイルのタッチ位置はInputServiceから取るのが確実
end)

-- 正確なタッチ位置取得のためにInputBeganを使用
UserInputService.InputBegan:Connect(function(input)
    if isSelecting and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
        
        -- 位置を記録
        targetPosition = input.Position
        
        -- マーカーを移動
        marker.Position = UDim2.new(0, targetPosition.X, 0, targetPosition.Y)
        marker.Visible = true
        
        -- モード終了
        isSelecting = false
        selectionOverlay.Visible = false
        
        -- UI更新
        statusLabel.Text = "設定完了!"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60) -- 赤（準備OK）
        toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        -- 確認のためコンソール出力
        print("Target Set at:", targetPosition)
    end
end)

-- 3. スタート/ストップボタン
toggleBtn.MouseButton1Click:Connect(function()
    if not targetPosition then
        statusLabel.Text = "先に場所を決めて!"
        return
    end

    isRunning = not isRunning
    
    if isRunning then
        toggleBtn.Text = "STOP"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 255, 60) -- 緑
        statusLabel.Text = "連打中..."
    else
        toggleBtn.Text = "START"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60) -- 赤
        statusLabel.Text = "停止中"
    end
end)

-- 4. 連打実行ループ（物理タップ）
task.spawn(function()
    while true do
        if isRunning and targetPosition then
            pcall(function()
                -- 記録した座標をタップ
                -- Vector2に変換
                local pos = Vector2.new(targetPosition.X, targetPosition.Y)
                
                -- Touch Start
                VirtualInputManager:SendTouchEvent(pos, 0, 0) 
                
                -- ごく短時間待機（しっかり押した判定にするため）
                task.wait(0.01)
                
                -- Touch End
                VirtualInputManager:SendTouchEvent(pos, 0, 2)
            end)
            
            -- マーカーを一瞬大きくして視覚フィードバック
            local t = game:GetService("TweenService"):Create(marker, TweenInfo.new(0.05), {Size = UDim2.new(0, 15, 0, 15)})
            t:Play()
            task.delay(0.05, function()
                marker.Size = UDim2.new(0, 20, 0, 20)
            end)
        end
        
        task.wait(clickSpeed)
    end
end)

print("Manual Mobile Clicker Loaded")
