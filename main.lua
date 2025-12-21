-- 「Fling Things and People」専用 超高速クリッカー（修正完全版）
-- Place ID: 9604086456

-- サービス参照
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager") -- 必須サービスを追加

-- ローカルプレイヤー
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- クリック状態
local isClicking = false
local clickSpeed = 0.05 -- 動作安定のため少しだけ間隔を調整（早すぎるとサーバーに弾かれるため）
local lastClickTime = 0
local targetButtons = {} -- ターゲットとなるボタン
local connection = nil

-- 表示用フレーム作成
local displayFrame = Instance.new("Frame")
displayFrame.Name = "AutoClickerDisplay"
displayFrame.Size = UDim2.new(0, 160, 0, 90)
displayFrame.Position = UDim2.new(0, 20, 0, 20)
displayFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
displayFrame.BackgroundTransparency = 0.2
displayFrame.BorderSizePixel = 0

-- コーナーを丸く
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = displayFrame

-- ドロップシャドウ
local uiShadow = Instance.new("ImageLabel")
uiShadow.Name = "Shadow"
uiShadow.Image = "rbxassetid://1316045217"
uiShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
uiShadow.ImageTransparency = 0.6
uiShadow.ScaleType = Enum.ScaleType.Slice
uiShadow.SliceCenter = Rect.new(10, 10, 118, 118)
uiShadow.Size = UDim2.new(1, 20, 1, 20)
uiShadow.Position = UDim2.new(0, -10, 0, -10)
uiShadow.BackgroundTransparency = 1
uiShadow.Parent = displayFrame

-- タイトルテキスト
local statusText = Instance.new("TextLabel")
statusText.Name = "StatusText"
statusText.Size = UDim2.new(1, -10, 0.4, 0)
statusText.Position = UDim2.new(0, 10, 0, 5)
statusText.BackgroundTransparency = 1
statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
statusText.Text = "Fling AutoClicker"
statusText.Font = Enum.Font.GothamBold
statusText.TextSize = 14
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = displayFrame

-- 状態表示テキスト
local clickStatus = Instance.new("TextLabel")
clickStatus.Name = "ClickStatus"
clickStatus.Size = UDim2.new(1, -10, 0.3, 0)
clickStatus.Position = UDim2.new(0, 10, 0.45, 0)
clickStatus.BackgroundTransparency = 1
clickStatus.TextColor3 = Color3.fromRGB(200, 200, 255)
clickStatus.Text = "待機中..."
clickStatus.Font = Enum.Font.Gotham
clickStatus.TextSize = 13
clickStatus.TextXAlignment = Enum.TextXAlignment.Left
clickStatus.Parent = displayFrame

-- ボタン検出数テキスト
local detectText = Instance.new("TextLabel")
detectText.Name = "DetectText"
detectText.Size = UDim2.new(1, -10, 0.2, 0)
detectText.Position = UDim2.new(0, 10, 0.75, 0)
detectText.BackgroundTransparency = 1
detectText.TextColor3 = Color3.fromRGB(150, 255, 150)
detectText.Text = "検出: 0"
detectText.Font = Enum.Font.Gotham
detectText.TextSize = 11
detectText.TextXAlignment = Enum.TextXAlignment.Left
detectText.Parent = displayFrame

-- オン/オフ切り替えボタン
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 36, 0, 36)
toggleButton.Position = UDim2.new(1, -45, 0.5, -18)
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
toggleButton.Text = "OFF"
toggleButton.TextColor3 = Color3.new(1,1,1)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 10
toggleButton.AutoButtonColor = false

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0) -- 完全な円
toggleCorner.Parent = toggleButton

toggleButton.Parent = displayFrame

-- GUIのセットアップ
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlingAutoClicker_Fixed"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 10000
displayFrame.Parent = screenGui

local playerGui = player:WaitForChild("PlayerGui")
screenGui.Parent = playerGui

-- === 重要: ボタン検出ロジック ===
local function findGameButtons()
    targetButtons = {}
    
    local function scanDescendants(parent)
        for _, descendant in pairs(parent:GetDescendants()) do
            -- UIボタンのみ対象（TextButton / ImageButton）
            if descendant:IsA("TextButton") or descendant:IsA("ImageButton") then
                if descendant.Visible then -- 見えているボタンのみ
                    local name = string.lower(descendant.Name)
                    local text = ""
                    if descendant:IsA("TextButton") then
                        text = string.lower(descendant.Text)
                    end

                    -- 検索キーワード（必要に応じてここを追加・変更）
                    if string.find(name, "click") or string.find(text, "click") or
                       string.find(name, "fling") or string.find(text, "fling") or
                       string.find(name, "spawn") or string.find(text, "spawn") or
                       string.find(name, "collect") or
                       string.find(name, "btn") then
                        
                        table.insert(targetButtons, descendant)
                    end
                end
            end
        end
    end

    -- PlayerGui内を検索
    scanDescendants(playerGui)
    
    detectText.Text = "検出: " .. #targetButtons
    return #targetButtons
end

-- === 最重要: 物理クリックシミュレーション関数 ===
local function simulateClick(button)
    if button and button:IsDescendantOf(game) and button.Visible then
        
        -- ボタンの中心座標を計算
        local absolutePos = button.AbsolutePosition
        local absoluteSize = button.AbsoluteSize
        local centerX = absolutePos.X + (absoluteSize.X / 2)
        local centerY = absolutePos.Y + (absoluteSize.Y / 2)

        -- VirtualInputManagerを使って「本物の」クリックイベントを送る
        -- (座標X, 座標Y, ボタン種類(0=左), 押す(true), ゲーム, ブロックするか)
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
        
        -- 視覚フィードバック（クリックした瞬間赤くする）
        local oldColor = button.BackgroundColor3
        pcall(function() button.BackgroundColor3 = Color3.fromRGB(255, 50, 50) end)
        
        -- 一瞬待って離す
        task.delay(0.05, function()
            VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
            pcall(function() button.BackgroundColor3 = oldColor end)
        end)
    end
end

-- === メインループ ===
local function mainClickLoop()
    while isClicking do
        local currentTime = tick()
        
        if currentTime - lastClickTime >= clickSpeed then
            -- 1. 検出されたボタンがあればクリック
            if #targetButtons > 0 then
                for _, btn in pairs(targetButtons) do
                    simulateClick(btn)
                end
            else
                -- 2. ボタンがない場合、現在のマウス位置を連打（Fling用）
                -- ※UIボタンが見つからないときは、単純な連打ツールとして機能します
                local mouseX, mouseY = mouse.X, mouse.Y
                VirtualInputManager:SendMouseButtonEvent(mouseX, mouseY, 0, true, game, 1)
                task.delay(0.02, function()
                     VirtualInputManager:SendMouseButtonEvent(mouseX, mouseY, 0, false, game, 1)
                end)
            end
            
            lastClickTime = currentTime
        end
        RunService.RenderStepped:Wait()
    end
end

-- ボタン検出ループ（3秒ごとに更新）
task.spawn(function()
    while true do
        if isClicking then
            findGameButtons()
        end
        task.wait(3)
    end
end)

-- トグルボタンの処理
toggleButton.MouseButton1Click:Connect(function()
    isClicking = not isClicking
    
    if isClicking then
        -- ON
        toggleButton.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
        toggleButton.Text = "ON"
        clickStatus.Text = "稼働中..."
        clickStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        -- 開始時に一度ボタンを探す
        findGameButtons()
        
        -- ループ開始
        task.spawn(mainClickLoop)
    else
        -- OFF
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        toggleButton.Text = "OFF"
        clickStatus.Text = "停止中"
        clickStatus.TextColor3 = Color3.fromRGB(200, 200, 255)
    end
end)

-- ドラッグ移動機能
local dragging, dragInput, dragStart, startPos

displayFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = displayFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

displayFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        displayFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- 起動時処理
findGameButtons()
print("Fling AutoClicker (Fixed VIM Version) Loaded.")
