-- 「Fling Things and People」モバイル専用 完全版オートクリッカー
-- Place ID: 9604086456
-- モバイル（スマホ/タブレット）対応版

-- サービス参照
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- ローカルプレイヤー
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 設定
local isRunning = false
local clickSpeed = 0.1 -- モバイルは少しゆっくりめが安定します
local targetButtons = {} 

-- === GUI作成（モバイル用に少し大きめ・操作しやすく調整） ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlingMobileClicker"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- メインフレーム
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 180, 0, 110)
mainFrame.Position = UDim2.new(0.05, 0, 0.4, 0) -- 左手親指で操作しやすい位置
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- ドラッグ可能に
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = mainFrame

-- タイトル
local title = Instance.new("TextLabel")
title.Text = "Mobile Auto Tap"
title.Size = UDim2.new(1, 0, 0.3, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = mainFrame

-- ステータス表示
local status = Instance.new("TextLabel")
status.Name = "Status"
status.Text = "待機中..."
status.Size = UDim2.new(1, 0, 0.2, 0)
status.Position = UDim2.new(0, 0, 0.3, 0)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.Parent = mainFrame

-- ON/OFFボタン
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.new(0.8, 0, 0.35, 0)
toggleBtn.Position = UDim2.new(0.1, 0, 0.55, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60) -- 赤（OFF）
toggleBtn.Text = "START"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = toggleBtn

-- GUIをプレイヤーにセット
if gethui then
    screenGui.Parent = gethui() -- 最近のExecutor用
else
    if CoreGui:FindFirstChild("RobloxGui") then
        screenGui.Parent = CoreGui
    else
        screenGui.Parent = playerGui
    end
end

-- === モバイル特化型ボタン検出機能 ===
local function findMobileControls()
    targetButtons = {}
    
    -- 検索対象のGUIフォルダ（モバイル操作UIはここにあることが多い）
    local guiTargets = {
        playerGui,
        playerGui:FindFirstChild("TouchGui"),
        playerGui:FindFirstChild("ContextActionGui"), -- ジャンプやアクションボタンはここ
        playerGui:FindFirstChild("MobileControlGui")
    }

    local function scan(parent)
        if not parent then return end
        for _, v in pairs(parent:GetDescendants()) do
            -- ボタンっぽいものを探す
            if (v:IsA("ImageButton") or v:IsA("TextButton")) and v.Visible then
                local name = string.lower(v.Name)
                
                -- モバイル特有のボタン名やアイコン名を検索
                if string.find(name, "jump") or 
                   string.find(name, "action") or 
                   string.find(name, "interact") or 
                   string.find(name, "grab") or 
                   string.find(name, "click") or
                   string.find(name, "touch") or
                   string.find(name, "context") then -- ContextActionGuiのボタン
                    
                    table.insert(targetButtons, v)
                end
            end
        end
    end

    for _, gui in pairs(guiTargets) do
        scan(gui)
    end
    
    status.Text = "検出ボタン: " .. #targetButtons .. "個"
    return targetButtons
end

-- === モバイル用タップ実行関数 ===
-- 座標クリックではなく、イベントを直接発火させることで確実に動作させる
local function mobileTap(button)
    if not button then return end

    pcall(function()
        -- 1. Executor固有の機能があれば使う（最強）
        if getconnections then
            for _, connection in pairs(getconnections(button.Activated)) do
                connection:Fire()
            end
            for _, connection in pairs(getconnections(button.MouseButton1Click)) do
                connection:Fire()
            end
            for _, connection in pairs(getconnections(button.MouseButton1Down)) do
                connection:Fire()
            end
        else
            -- 2. 標準的なイベント発火（汎用）
            if button.Activated then button.Activated:Fire() end
            if button.MouseButton1Click then button:FireEvent("MouseButton1Click") end
        end

        -- 視覚エフェクト（押されたことがわかるように）
        local t = game:GetService("TweenService"):Create(button, TweenInfo.new(0.1), {ImageTransparency = 0.5})
        t:Play()
        task.delay(0.1, function()
            local t2 = game:GetService("TweenService"):Create(button, TweenInfo.new(0.1), {ImageTransparency = 0})
            t2:Play()
        end)
    end)
end

-- === メインループ ===
local function startLoop()
    task.spawn(function()
        while isRunning do
            if #targetButtons > 0 then
                for _, btn in pairs(targetButtons) do
                    if isRunning then -- ループ内でもチェック
                        mobileTap(btn)
                    end
                end
            else
                -- ボタンが見つからない場合、画面中央タップ（物理判定用）
                -- VirtualInputManagerは一部モバイルExecutorで動作しない可能性があるが、一応実装
                pcall(function()
                    VirtualInputManager:SendTouchEvent(Vector2.new(500, 500), 0, 0) -- TouchStart
                    task.wait(0.01)
                    VirtualInputManager:SendTouchEvent(Vector2.new(500, 500), 0, 2) -- TouchEnd
                end)
            end
            task.wait(clickSpeed)
        end
    end)
end

-- === ボタン操作 ===
toggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    
    if isRunning then
        -- ONにする
        toggleBtn.Text = "STOP"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 255, 60) -- 緑
        status.Text = "検索中..."
        
        -- ボタンを再検索
        findMobileControls()
        
        -- ループ開始
        startLoop()
    else
        -- OFFにする
        toggleBtn.Text = "START"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60) -- 赤
        status.Text = "停止中"
    end
end)

-- 初期化
findMobileControls()
print("Mobile Auto Clicker Loaded for Fling Things and People")
