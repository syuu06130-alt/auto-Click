-- 「Fling Things and People」専用超高速クリッカー
-- Place ID: 9604086456

-- サービス参照
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- ローカルプレイヤー
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- クリック状態
local isClicking = false
local clickSpeed = 0.001 -- クリック間隔（秒）
local lastClickTime = 0
local targetButtons = {} -- ターゲットとなるボタン
local connection = nil

-- 表示用フレーム
local displayFrame = Instance.new("Frame")
displayFrame.Name = "AutoClickerDisplay"
displayFrame.Size = UDim2.new(0, 150, 0, 80)
displayFrame.Position = UDim2.new(0, 10, 0, 10)
displayFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
displayFrame.BackgroundTransparency = 0.2
displayFrame.BorderSizePixel = 2
displayFrame.BorderColor3 = Color3.fromRGB(100, 100, 200)

-- コーナーを丸く
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = displayFrame

-- ドロップシャドウ
local uiShadow = Instance.new("ImageLabel")
uiShadow.Name = "Shadow"
uiShadow.Image = "rbxassetid://1316045217"
uiShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
uiShadow.ImageTransparency = 0.8
uiShadow.ScaleType = Enum.ScaleType.Slice
uiShadow.SliceCenter = Rect.new(10, 10, 118, 118)
uiShadow.Size = UDim2.new(1, 20, 1, 20)
uiShadow.Position = UDim2.new(0, -10, 0, -10)
uiShadow.BackgroundTransparency = 1
uiShadow.Parent = displayFrame

-- 表示テキスト
local statusText = Instance.new("TextLabel")
statusText.Name = "StatusText"
statusText.Size = UDim2.new(1, -10, 0.5, 0)
statusText.Position = UDim2.new(0, 5, 0, 5)
statusText.BackgroundTransparency = 1
statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
statusText.Text = "Fling AutoClicker"
statusText.Font = Enum.Font.SourceSansBold
statusText.TextSize = 16
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = displayFrame

-- 状態表示テキスト
local clickStatus = Instance.new("TextLabel")
clickStatus.Name = "ClickStatus"
clickStatus.Size = UDim2.new(1, -10, 0.35, 0)
clickStatus.Position = UDim2.new(0, 5, 0.5, 0)
clickStatus.BackgroundTransparency = 1
clickStatus.TextColor3 = Color3.fromRGB(200, 200, 255)
clickStatus.Text = "準備中..."
clickStatus.Font = Enum.Font.SourceSans
clickStatus.TextSize = 14
clickStatus.TextXAlignment = Enum.TextXAlignment.Left
clickStatus.Parent = displayFrame

-- ボタン検出テキスト
local detectText = Instance.new("TextLabel")
detectText.Name = "DetectText"
detectText.Size = UDim2.new(1, -10, 0.15, 0)
detectText.Position = UDim2.new(0, 5, 0.85, 0)
detectText.BackgroundTransparency = 1
detectText.TextColor3 = Color3.fromRGB(150, 255, 150)
detectText.Text = "ボタン検出: 0"
detectText.Font = Enum.Font.SourceSans
detectText.TextSize = 12
detectText.TextXAlignment = Enum.TextXAlignment.Left
detectText.Parent = displayFrame

-- オン/オフ切り替えボタン
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 30, 0, 30)
toggleButton.Position = UDim2.new(1, -35, 0.5, -15)
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
toggleButton.Text = ""
toggleButton.AutoButtonColor = false

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 15)
toggleCorner.Parent = toggleButton

toggleButton.Parent = displayFrame

-- スクリーンGUIの作成
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlingAutoClickerGUI"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 9999
screenGui.ResetOnSpawn = false
displayFrame.Parent = screenGui

-- GUIをプレイヤーのGUIに追加
local playerGui = player:WaitForChild("PlayerGui")
screenGui.Parent = playerGui

-- ゲーム固有のボタン検出
local function findGameButtons()
    targetButtons = {}
    
    -- CoreGui内のボタンを検索
    local coreGui = game:GetService("CoreGui")
    for _, gui in pairs({playerGui, coreGui}) do
        local function scanDescendants(parent)
            for _, descendant in pairs(parent:GetDescendants()) do
                -- 一般的なボタンの検出条件
                if descendant:IsA("TextButton") or descendant:IsA("ImageButton") then
                    -- Flingゲーム特有のボタン名を検出
                    local buttonName = string.lower(descendant.Name or "")
                    local buttonText = string.lower(descendant.Text or "")
                    
                    -- クリックに関連するボタンを検出
                    if string.find(buttonName, "click") or 
                       string.find(buttonText, "click") or
                       string.find(buttonName, "tap") or 
                       string.find(buttonText, "tap") or
                       string.find(buttonName, "fling") or
                       string.find(buttonText, "fling") or
                       string.find(buttonName, "farm") or
                       string.find(buttonText, "farm") or
                       descendant.Name == "Button" or
                       string.find(buttonText, "!" ) then
                        
                        table.insert(targetButtons, descendant)
                    end
                    
                    -- 収穫やアップグレード関連のボタン
                    if string.find(buttonName, "harvest") or 
                       string.find(buttonText, "harvest") or
                       string.find(buttonName, "upgrade") or
                       string.find(buttonText, "upgrade") or
                       string.find(buttonName, "collect") then
                        
                        table.insert(targetButtons, descendant)
                    end
                end
            end
        end
        
        scanDescendants(gui)
    end
    
    -- StarterGuiもチェック
    local starterGui = game:GetService("StarterGui")
    scanDescendants(starterGui)
    
    detectText.Text = "ボタン検出: " .. #targetButtons
    
    if #targetButtons > 0 then
        clickStatus.Text = "準備完了"
        clickStatus.TextColor3 = Color3.fromRGB(150, 255, 150)
    else
        clickStatus.Text = "ボタンなし"
        clickStatus.TextColor3 = Color3.fromRGB(255, 150, 150)
    end
    
    return #targetButtons
end

-- ボタンクリック関数
local function clickButton(button)
    if button and button:IsDescendantOf(game) then
        -- マウスイベントをシミュレート
        if button:IsA("TextButton") or button:IsA("ImageButton") then
            -- MouseButton1Clickイベントを発火
            local success, result = pcall(function()
                button:FireEvent("MouseButton1Click")
            end)
            
            -- MouseButton1Downイベントを発火
            if not success then
                pcall(function()
                    button:FireEvent("MouseButton1Down")
                end)
            end
            
            -- Activatedイベントを発火
            pcall(function()
                local activated = button.Activated
                if activated then
                    activated:Fire()
                end
            end)
            
            -- クリック音が設定されていれば再生
            pcall(function()
                local clickSound = button:FindFirstChildOfClass("Sound")
                if clickSound then
                    clickSound:Play()
                end
            end)
            
            -- 視覚的フィードバック（色変化）
            pcall(function()
                local originalColor = button.BackgroundColor3
                button.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
                
                task.delay(0.05, function()
                    if button and button:IsDescendantOf(game) then
                        button.BackgroundColor3 = originalColor
                    end
                end)
            end)
        end
    end
end

-- メインクリックループ
local function mainClickLoop()
    while isClicking do
        local currentTime = tick()
        
        if currentTime - lastClickTime >= clickSpeed then
            -- 検出されたボタンをクリック
            for _, button in pairs(targetButtons) do
                if button and button:IsDescendantOf(game) then
                    clickButton(button)
                end
            end
            
            lastClickTime = currentTime
        end
        
        -- 高頻度更新
        RunService.RenderStepped:Wait()
    end
end

-- ボタン検出ループ
local function buttonDetectionLoop()
    while true do
        findGameButtons()
        task.wait(2) -- 2秒ごとにボタンを再検出
    end
end

-- トグルボタンのクリック処理
toggleButton.MouseButton1Click:Connect(function()
    isClicking = not isClicking
    
    if isClicking then
        -- クリック開始
        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
        clickStatus.Text = "クリック中..."
        clickStatus.TextColor3 = Color3.fromRGB(255, 255, 150)
        displayFrame.BackgroundColor3 = Color3.fromRGB(40, 50, 40)
        
        -- ボタン検索を更新
        findGameButtons()
        
        -- クリックループ開始
        task.spawn(mainClickLoop)
        
        -- アニメーション
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(toggleButton, tweenInfo, {Rotation = 360})
        tween:Play()
        task.delay(0.3, function()
            toggleButton.Rotation = 0
        end)
    else
        -- クリック停止
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        clickStatus.Text = "停止中"
        clickStatus.TextColor3 = Color3.fromRGB(200, 200, 255)
        displayFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        
        -- アニメーション
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(toggleButton, tweenInfo, {Rotation = -180})
        tween:Play()
        task.delay(0.3, function()
            toggleButton.Rotation = 0
        end)
    end
end)

-- タッチジェスチャー（表示フレームをドラッグ移動）
local dragStartPos, frameStartPos = nil, nil

displayFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
        frameStartPos = displayFrame.Position
    end
end)

displayFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        if dragStartPos then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStartPos
            displayFrame.Position = UDim2.new(
                frameStartPos.X.Scale, 
                frameStartPos.X.Offset + delta.X,
                frameStartPos.Y.Scale, 
                frameStartPos.Y.Offset + delta.Y
            )
        end
    end
end)

displayFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStartPos = nil
    end
end)

-- 初期設定
findGameButtons()

-- ボタン検出ループ開始
task.spawn(buttonDetectionLoop)

-- ゲーム読み込み完了を待機
game:GetService("ContentProvider"):PreloadAsync({playerGui})

-- プレイヤーがリスポーンしたときの処理
player.CharacterAdded:Connect(function()
    task.wait(1) -- UIが読み込まれるのを待機
    findGameButtons()
end)

-- 画面サイズ変更時の調整
UserInputService.WindowFocusReleased:Connect(function()
    if isClicking then
        isClicking = false
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        clickStatus.Text = "中断"
    end
end)

print("="..string.rep("=", 50))
print("Fling Things and People 専用オートクリッカー")
print("Place ID: 9604086456")
print("使用方法:")
print("1. 赤いボタンをクリック/タップでオン/オフ")
print("2. 表示フレームをドラッグして移動可能")
print("3. 検出されたボタン: " .. #targetButtons .. "個")
print("="..string.rep("=", 50))
