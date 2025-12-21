-- 「Fling Things and People」モバイル専用 物理タップ版
-- Place ID: 9604086456
-- 修正点: イベント発火ではなく、ボタンの座標を物理的にタップする方式に変更

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local isRunning = false
local clickSpeed = 0.05 -- 連打速度
local targetButtons = {}

-- === UI作成 ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PhysicalMobileClicker"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if gethui then
    screenGui.Parent = gethui()
else
    if CoreGui:FindFirstChild("RobloxGui") then
        screenGui.Parent = CoreGui
    else
        screenGui.Parent = playerGui
    end
end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 150, 0, 100)
mainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0.4, 0)
statusLabel.Position = UDim2.new(0, 0, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Text = "待機中"
statusLabel.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.8, 0, 0.4, 0)
toggleBtn.Position = UDim2.new(0.1, 0, 0.5, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
toggleBtn.Text = "開始 (START)"
toggleBtn.Parent = mainFrame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

-- デバッグ用マーカー（どこをクリックしているか可視化）
local marker = Instance.new("Frame")
marker.Size = UDim2.new(0, 10, 0, 10)
marker.BackgroundColor3 = Color3.fromRGB(255, 0, 255) -- 紫色の点
marker.BorderColor3 = Color3.new(1,1,1)
marker.Visible = false
marker.ZIndex = 1000
marker.Parent = screenGui

-- === ボタン検索ロジック（右下のボタンを狙う） ===
local function findActionButtons()
    targetButtons = {}
    local screenSize = workspace.CurrentCamera.ViewportSize
    
    -- モバイル操作UIが含まれるフォルダを探す
    local targets = {
        playerGui:FindFirstChild("ContextActionGui"), -- ジャンプやアクションは通常ここ
        playerGui:FindFirstChild("TouchGui"),
        playerGui:FindFirstChild("MobileControlGui")
    }
    
    local function scan(parent)
        if not parent then return end
        for _, v in pairs(parent:GetDescendants()) do
            if (v:IsA("ImageButton") or v:IsA("TextButton")) and v.Visible then
                -- 画面上の絶対位置を取得
                local pos = v.AbsolutePosition
                
                -- 条件1: 画面の「右半分」かつ「下半分」にあるか？（アクションボタンは大体ここ）
                local isBottomRight = (pos.X > screenSize.X * 0.5) and (pos.Y > screenSize.Y * 0.4)
                
                -- 条件2: 「Jump」ボタンを除外する（名前で判定）
                local name = string.lower(v.Name)
                local isJump = string.find(name, "jump") or string.find(name, "touchjump")
                
                -- 条件3: 特定のキーワード（アクション系）または 名前なしボタン（Fling等の場合が多い）
                local isAction = string.find(name, "action") or 
                                 string.find(name, "interact") or
                                 string.find(name, "context") or -- ContextButton1, 2 etc
                                 string.find(name, "button")
                
                -- 右下にあって、ジャンプボタンじゃなければターゲットにする
                if isBottomRight and not isJump then
                    table.insert(targetButtons, v)
                    -- 見つかったボタンの名前をコンソールに表示（確認用）
                    print("Target Found: " .. v.Name .. " at " .. tostring(pos))
                end
            end
        end
    end
    
    for _, t in pairs(targets) do scan(t) end
    
    -- もしContextActionGuiで見つからなければ、PlayerGui全体から探す（最終手段）
    if #targetButtons == 0 then
        scan(playerGui)
    end
    
    statusLabel.Text = "対象: " .. #targetButtons .. "個"
end

-- === 物理タップ実行 ===
local function tapButton(btn)
    if not btn or not btn.Visible then return end
    
    -- ボタンの中心座標を計算
    local absPos = btn.AbsolutePosition
    local absSize = btn.AbsoluteSize
    local centerX = absPos.X + (absSize.X / 2)
    local centerY = absPos.Y + (absSize.Y / 2)
    
    -- デバッグ用マーカーを移動（どこを押そうとしているか表示）
    marker.Position = UDim2.new(0, centerX - 5, 0, centerY - 5)
    marker.Visible = true
    
    -- VirtualInputManagerでタッチイベントを送信
    pcall(function()
        VirtualInputManager:SendTouchEvent(Vector2.new(centerX, centerY), 0, 0) -- Touch Start
        -- ほんの少し待機しないと「長押し」判定になったり認識されなかったりする
        task.wait(0.01) 
        VirtualInputManager:SendTouchEvent(Vector2.new(centerX, centerY), 0, 2) -- Touch End
    end)
end

-- === メインループ ===
task.spawn(function()
    while true do
        if isRunning then
            if #targetButtons > 0 then
                for _, btn in pairs(targetButtons) do
                    if isRunning and btn.Parent then
                        tapButton(btn)
                    end
                end
            end
        else
            marker.Visible = false
        end
        -- 連打速度（早すぎるとラグる場合はここを0.1などに増やす）
        task.wait(clickSpeed)
    end
end)

-- === ボタン操作 ===
toggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        findActionButtons()
        toggleBtn.Text = "停止 (STOP)"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        
        if #targetButtons == 0 then
            statusLabel.Text = "ボタン無し(右下)"
            -- ボタンが見つからない場合、警告として赤点滅
            task.delay(1, function() isRunning = false toggleBtn.Text = "再試行" end)
        end
    else
        toggleBtn.Text = "開始 (START)"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        statusLabel.Text = "停止中"
        marker.Visible = false
    end
end)

print("Physical Mobile Clicker Loaded")
