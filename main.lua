-- 超高速スマホ用クリッカー
-- 作成者: あなたの名前
-- バージョン: 1.0

-- サービス参照
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- ローカルプレイヤー
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- クリック状態
local isClicking = false
local clickSpeed = 0.001 -- クリック間隔（秒）
local lastClickTime = 0

-- 表示用フレーム
local displayFrame = Instance.new("Frame")
displayFrame.Name = "AutoClickerDisplay"
displayFrame.Size = UDim2.new(0, 120, 0, 60)
displayFrame.Position = UDim2.new(0, 10, 0, 10)
displayFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
displayFrame.BackgroundTransparency = 0.3
displayFrame.BorderSizePixel = 2
displayFrame.BorderColor3 = Color3.fromRGB(100, 100, 200)

-- コーナーを丸く
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = displayFrame

-- 表示テキスト
local statusText = Instance.new("TextLabel")
statusText.Name = "StatusText"
statusText.Size = UDim2.new(1, -10, 0.6, 0)
statusText.Position = UDim2.new(0, 5, 0, 5)
statusText.BackgroundTransparency = 1
statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
statusText.Text = "オートクリッカー"
statusText.Font = Enum.Font.SourceSansBold
statusText.TextSize = 16
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = displayFrame

-- 状態表示テキスト
local clickStatus = Instance.new("TextLabel")
clickStatus.Name = "ClickStatus"
clickStatus.Size = UDim2.new(1, -10, 0.4, 0)
clickStatus.Position = UDim2.new(0, 5, 0.6, 0)
clickStatus.BackgroundTransparency = 1
clickStatus.TextColor3 = Color3.fromRGB(200, 200, 255)
clickStatus.Text = "OFF"
clickStatus.Font = Enum.Font.SourceSans
clickStatus.TextSize = 14
clickStatus.TextXAlignment = Enum.TextXAlignment.Left
clickStatus.Parent = displayFrame

-- スクリーンGUIの作成
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoClickerGUI"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999
displayFrame.Parent = screenGui

-- GUIをプレイヤーのGUIに追加
screenGui.Parent = player:WaitForChild("PlayerGui")

-- タッチジェスチャー検出用
local touchStartPos = nil
local touchStartTime = 0
local longPressThreshold = 1.0 -- 長押し検出の閾値（秒）

-- クリック関数
local function performClick()
    -- ここで実際のクリックアクションをシミュレート
    -- 注意: Robloxのセキュリティ制限により、実際のマウスクリックをシミュレートするのは難しい場合があります
    
    -- 代わりに、マウスの位置にあるオブジェクトを取得してクリックイベントを発生させる
    local target = mouse.Target
    if target then
        -- クリック可能なオブジェクトに対してイベントを発火
        local clickDetector = target:FindFirstChildOfClass("ClickDetector")
        if clickDetector then
            clickDetector:FireServer()
        end
        
        -- ツールを使用している場合はツールのアクションを実行
        local character = player.Character
        if character then
            local tool = character:FindFirstChildOfClass("Tool")
            if tool then
                local remote = tool:FindFirstChild("RemoteEvent") or tool:FindFirstChild("RemoteFunction")
                if remote then
                    remote:FireServer("Activate")
                end
            end
        end
    end
end

-- クリックループ
local function clickLoop()
    while isClicking do
        local currentTime = tick()
        if currentTime - lastClickTime >= clickSpeed then
            performClick()
            lastClickTime = currentTime
        end
        RunService.RenderStepped:Wait()
    end
end

-- 表示フレームのタッチ処理
local function handleFrameInput(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        if input.UserInputState == Enum.UserInputState.Begin then
            touchStartPos = input.Position
            touchStartTime = tick()
            
            -- トグルクリック状態
            isClicking = not isClicking
            clickStatus.Text = isClicking and "ON (高速)" or "OFF"
            displayFrame.BackgroundColor3 = isClicking and 
                Color3.fromRGB(40, 60, 40) or 
                Color3.fromRGB(30, 30, 40)
            
            if isClicking then
                -- クリックループ開始
                task.spawn(clickLoop)
            end
        end
    end
end

-- 入力イベントの接続
displayFrame.InputBegan:Connect(handleFrameInput)

-- グローバルタッチジェスチャー（長押しでオン/オフ切り替え）
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.Touch then
        touchStartPos = input.Position
        touchStartTime = tick()
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.Touch and touchStartPos then
        local touchDuration = tick() - touchStartTime
        local touchEndPos = input.Position
        
        -- 長押しの検出（表示フレーム外で）
        if touchDuration >= longPressThreshold then
            local isInFrame = false
            local framePos = displayFrame.AbsolutePosition
            local frameSize = displayFrame.AbsoluteSize
            
            -- タッチ位置がフレーム内かチェック
            if touchEndPos.X >= framePos.X and touchEndPos.X <= framePos.X + frameSize.X and
               touchEndPos.Y >= framePos.Y and touchEndPos.Y <= framePos.Y + frameSize.Y then
                isInFrame = true
            end
            
            -- フレーム外での長押しでオン/オフ切り替え
            if not isInFrame then
                isClicking = not isClicking
                clickStatus.Text = isClicking and "ON (高速)" or "OFF"
                displayFrame.BackgroundColor3 = isClicking and 
                    Color3.fromRGB(40, 60, 40) or 
                    Color3.fromRGB(30, 30, 40)
                
                if isClicking then
                    -- クリックループ開始
                    task.spawn(clickLoop)
                end
            end
        end
    end
end)

-- デバイスがモバイルかチェック
if UserInputService.TouchEnabled then
    statusText.Text = "モバイルクリッカー"
else
    statusText.Text = "PCモード: クリック無効"
    clickStatus.Text = "モバイルのみ"
end

-- 画面サイズ変更時の調整
UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(function()
    if UserInputService.TouchEnabled then
        statusText.Text = "モバイルクリッカー"
    end
end)

-- クリーンアップ関数
local function cleanup()
    isClicking = false
    if screenGui then
        screenGui:Destroy()
    end
end

-- プレイヤーが退出したときのクリーンアップ
player.CharacterRemoving:Connect(cleanup)

print("超高速スマホ用クリッカーがロードされました。")
print("左上の表示をタップでオン/オフ切り替え")
print("画面の他の場所で長押し(1秒)でも切り替え可能")
