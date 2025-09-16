-- OverHub Diamonds Autofarm — unified UI + farm core (Part 1/2)
-- auto-queue on teleport to re-run the same hosted script with configured globals
local RAW_URL = "https://raw.githubusercontent.com/hellattexyss/testfarm/refs/heads/main/farmv399upd.lua"

-- preserve existing globals if already set by the user before loadstring
getgenv().Webhook = getgenv().Webhook or getgenv().WebhookURL or ""
getgenv().AutoExecute = (getgenv().AutoExecute == nil) and true or getgenv().AutoExecute

-- queue re-exec on teleport (most executors expose queue_on_teleport or queueonteleport)
local q = queue_on_teleport or queueonteleport or syn and syn.queue_on_teleport
pcall(function()
    if q then
        q(([[
            if getgenv then
                getgenv().Webhook = %q
                getgenv().AutoExecute = %s
            end
            if (getgenv and getgenv().AutoExecute) and not _G.StopAuto then
                _G.StopAuto = false
                loadstring(game:HttpGet(%q))()
            end
        ]]):format(tostring(getgenv().Webhook or ""), tostring(getgenv().AutoExecute and true or false), RAW_URL))
    end
end)

-- also support queue_on_teleport style used in some scripts
pcall(function()
    if queue_on_teleport then
        queue_on_teleport(([[
            if getgenv then
                getgenv().Webhook = %q
                getgenv().AutoExecute = %s
            end
            if (getgenv and getgenv().AutoExecute) and not _G.StopAuto then
                _G.StopAuto = false
                loadstring(game:HttpGet(%q))()
            end
        ]]):format(tostring(getgenv().Webhook or ""), tostring(getgenv().AutoExecute and true or false), RAW_URL))
    end
end)
-- Green compact UI, live diamond counter, clipboard fallbacks, state, and base helpers.

-- Services
local Players = game:GetService("Players")  -- UI host
local TweenService = game:GetService("TweenService")  -- tweens
local StarterGui = game:GetService("StarterGui")  -- clipboard fallback
local UserInputService = game:GetService("UserInputService")  -- drag
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- External config (optional)
local WEBHOOK_URL = rawget(getgenv(), "Webhook") or (getgenv().WebhookURL or "")
local MAX_SERVER_TIME = tonumber(getgenv().MaxServerTime) or 15

-- Local player/UI refs
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local placeId = game.PlaceId

-- Camera blur
local camera = workspace.CurrentCamera
local Blur = Instance.new("BlurEffect")
Blur.Enabled = true
Blur.Size = 0
Blur.Parent = camera

-- Cleanup old GUIs
for _, n in ipairs({"DiamondFarmGUI","AutoFarmDiamondsGUI"}) do
    local f = PlayerGui:FindFirstChild(n)
    if f then f:Destroy() end
end

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFarmDiamondsGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- Root panel (reduced size)
local Root = Instance.new("Frame")
Root.Name = "Root"
Root.Size = UDim2.new(0, 370, 0, 210)
Root.Position = UDim2.new(0.5, 0, 0.48, 0)
Root.AnchorPoint = Vector2.new(0.5, 0.5)
Root.BackgroundColor3 = Color3.fromRGB(18, 38, 22)
Root.BackgroundTransparency = 1
Root.BorderSizePixel = 0
Root.ClipsDescendants = true
Root.Parent = ScreenGui

local RootCorner = Instance.new("UICorner")
RootCorner.CornerRadius = UDim.new(0, 12)
RootCorner.Parent = Root

local RootStroke = Instance.new("UIStroke")
RootStroke.Thickness = 1
RootStroke.Color = Color3.fromRGB(60, 200, 140)
RootStroke.Transparency = 0.1
RootStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
RootStroke.Parent = Root

-- Subtle halo
local Glow = Instance.new("ImageLabel")
Glow.Name = "Glow"
Glow.BackgroundTransparency = 1
Glow.AnchorPoint = Vector2.new(0.5, 0.5)
Glow.Position = UDim2.fromScale(0.5, 0.5)
Glow.Size = UDim2.new(1, 90, 1, 90)
Glow.Image = "rbxasset://textures/whiteSquare.png"
Glow.ImageColor3 = Color3.fromRGB(60, 210, 150)
Glow.ImageTransparency = 0.86
Glow.ScaleType = Enum.ScaleType.Slice
Glow.SliceCenter = Rect.new(10,10,246,246)
Glow.Parent = Root

-- Background gradient
local Bg = Instance.new("Frame")
Bg.Name = "Background"
Bg.Size = UDim2.fromScale(1, 1)
Bg.BackgroundColor3 = Root.BackgroundColor3
Bg.BackgroundTransparency = 1
Bg.BorderSizePixel = 0
Bg.Parent = Root

local BgCorner = Instance.new("UICorner")
BgCorner.CornerRadius = UDim.new(0, 12)
BgCorner.Parent = Bg

local BgGradient = Instance.new("UIGradient")
BgGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.0, Color3.fromRGB(22, 56, 32)),
    ColorSequenceKeypoint.new(1.0, Color3.fromRGB(18, 96, 58))
})
BgGradient.Rotation = 90
BgGradient.Parent = Bg

-- Header
local HeaderBar = Instance.new("Frame")
HeaderBar.Name = "HeaderBar"
HeaderBar.BackgroundTransparency = 1
HeaderBar.Size = UDim2.new(1, -18, 0, 34)
HeaderBar.Position = UDim2.new(0, 9, 0, 9)
HeaderBar.Parent = Root

local Left = Instance.new("Frame")
Left.BackgroundTransparency = 1
Left.Size = UDim2.new(0.5, -4, 1, 0)
Left.Parent = HeaderBar

local Right = Instance.new("Frame")
Right.BackgroundTransparency = 1
Right.Size = UDim2.new(0.5, -4, 1, 0)
Right.Position = UDim2.new(0.5, 8, 0, 0)
Right.Parent = HeaderBar

-- Title (smaller)
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.BackgroundTransparency = 1
Title.AnchorPoint = Vector2.new(0, 1)
Title.Position = UDim2.new(0, 0, 1, 0)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = "OverHub Autofarm"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextTransparency = 1
Title.Parent = Left

-- Copy Discord button (reduced)
local CopyBtn = Instance.new("TextButton")
CopyBtn.Name = "CopyDiscord"
CopyBtn.AnchorPoint = Vector2.new(1, 1)
CopyBtn.Position = UDim2.new(1, 0, 1, 0)
CopyBtn.Size = UDim2.new(0, 160, 1, 2)
CopyBtn.BackgroundTransparency = 1
CopyBtn.Text = "Copy Discord Link"
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.TextScaled = true
CopyBtn.TextColor3 = Color3.fromRGB(60, 200, 140)
CopyBtn.Parent = Right

local CopyCorner = Instance.new("UICorner")
CopyCorner.CornerRadius = UDim.new(0, 8)
CopyCorner.Parent = CopyBtn

local CopyStroke = Instance.new("UIStroke")
CopyStroke.Thickness = 1
CopyStroke.Color = Color3.fromRGB(60, 200, 140)
CopyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
CopyStroke.Parent = CopyBtn

-- Status (center, reduced)
local Status = Instance.new("TextLabel")
Status.Name = "Status"
Status.BackgroundTransparency = 1
Status.Size = UDim2.new(1, -28, 0, 72)
Status.Position = UDim2.new(0, 14, 0.47, -36)
Status.Text = "AUTOFARM: ON"
Status.Font = Enum.Font.GothamBlack
Status.TextScaled = true
Status.TextColor3 = Color3.fromRGB(95, 255, 185)
Status.TextTransparency = 1
Status.Parent = Root

local StatusGlow = Instance.new("Frame")
StatusGlow.Name = "StatusGlow"
StatusGlow.BackgroundColor3 = Color3.fromRGB(95, 255, 185)
StatusGlow.BackgroundTransparency = 0.88
StatusGlow.Size = UDim2.new(0.92, 0, 0, 78)
StatusGlow.Position = UDim2.new(0.04, 0, 0.47, -39)
StatusGlow.BorderSizePixel = 0
StatusGlow.Parent = Root
local StatusGlowCorner = Instance.new("UICorner")
StatusGlowCorner.CornerRadius = UDim.new(0, 10)
StatusGlowCorner.Parent = StatusGlow
local StatusGlowGrad = Instance.new("UIGradient")
StatusGlowGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.0, Color3.fromRGB(95, 255, 185)),
    ColorSequenceKeypoint.new(1.0, Color3.fromRGB(60, 220, 150))
})
StatusGlowGrad.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0.0, 0.35),
    NumberSequenceKeypoint.new(0.5, 0.75),
    NumberSequenceKeypoint.new(1.0, 1.0)
}
StatusGlowGrad.Parent = StatusGlow

-- Bottom diamond counter (smaller)
local DiamondCountLabel = Instance.new("TextLabel")
DiamondCountLabel.Name = "DiamondCountLabel"
DiamondCountLabel.BackgroundTransparency = 1
DiamondCountLabel.Size = UDim2.new(1, -16, 0, 18)
DiamondCountLabel.Position = UDim2.new(0, 8, 1, -24)
DiamondCountLabel.Text = "Diamonds: 0"
DiamondCountLabel.Font = Enum.Font.GothamBold
DiamondCountLabel.TextScaled = true
DiamondCountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
DiamondCountLabel.TextXAlignment = Enum.TextXAlignment.Left
DiamondCountLabel.TextTransparency = 1
DiamondCountLabel.Parent = Root

-- Helper tween
local function tween(obj, ti, props)
    TweenService:Create(obj, ti, props):Play()
end

-- Fade-in sequence
task.spawn(function()
    tween(Blur, TweenInfo.new(0.32, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = 16})
    task.wait(0.18)
    tween(Blur, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = 12})
    tween(Root, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 0.06})
    tween(Bg, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
    tween(Title, TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextTransparency = 0})
    tween(Status, TweenInfo.new(0.24, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextTransparency = 0})
    tween(DiamondCountLabel, TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextTransparency = 0})
    tween(Glow, TweenInfo.new(0.24, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {ImageTransparency = 0.86})
end)

-- Clipboard helpers
local DISCORD_LINK = "https://discord.gg/overhub"

local HiddenCopyBox = Instance.new("TextBox")
HiddenCopyBox.Name = "HiddenCopyBox"
HiddenCopyBox.Size = UDim2.new(0, 1, 0, 1)
HiddenCopyBox.Position = UDim2.new(1, 9999, 1, 9999)
HiddenCopyBox.TextEditable = true
HiddenCopyBox.ClearTextOnFocus = false
HiddenCopyBox.Text = ""
HiddenCopyBox.Parent = ScreenGui

local function copyWithExecutor(text)
    local env = getfenv and getfenv() or _G
    local f = (env and env.setclipboard) or _G.setclipboard or _G.toclipboard
    if f and typeof(f) == "function" then
        return pcall(f, text)
    end
    return false
end

local function copyWithSetCore(text)
    local tries, max = 0, 10
    while tries < max do
        tries += 1
        local ok = pcall(function()
            StarterGui:SetCore("SetClipboard", text)
        end)
        if ok then return true end
        task.wait(0.12)
    end
    return false
end

local function copyWithTextBox(text)
    HiddenCopyBox.Text = text
    HiddenCopyBox:CaptureFocus()
    HiddenCopyBox.CursorPosition = #HiddenCopyBox.Text + 1
    HiddenCopyBox.SelectionStart = 1
    return false
end

local function doCopy(text)
    if copyWithExecutor(text) then return true end -- executor path
    if copyWithSetCore(text) then return true end -- SetCore path
    copyWithTextBox(text) -- silent fallback
    return false
end

-- Copy btn interactions
CopyBtn.MouseEnter:Connect(function()
    tween(CopyBtn, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(110, 255, 195)})
end)
CopyBtn.MouseLeave:Connect(function()
    tween(CopyBtn, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(60, 200, 140)})
end)
CopyBtn.MouseButton1Click:Connect(function()
    local ok = doCopy(DISCORD_LINK)
    local orig = CopyStroke.Color
    CopyStroke.Color = ok and Color3.fromRGB(120, 255, 200) or Color3.fromRGB(255, 180, 140)
    TweenService:Create(CopyBtn, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true),
        {Size = UDim2.new(0, 154, 1, 0)}):Play()
    task.delay(0.18, function() CopyStroke.Color = orig end)
end)

-- Dragging (header)
local dragging, dragStart, startPos, dragInput = false, nil, nil, nil
local function updateDrag(input)
    local delta = input.Position - dragStart
    Root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
HeaderBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Root.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
HeaderBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

-- Expose UI refs
_G.OverhubUI = {
    Root = Root,
    DiamondCountLabel = DiamondCountLabel,
    Status = Status,
}

-- FARM CORE STATE + COUNTER BINDING
local Player = Players.LocalPlayer
local executorUsername = Player.Name
local displayName = Player.DisplayName
local ItemsFolder = Workspace:WaitForChild("Items")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local TakeDiamonds = RemoteEvents:WaitForChild("RequestTakeDiamonds")
local TeleportEvent = RemoteEvents:FindFirstChild("TeleportEvent") -- for PlaceId==79546208627805

local ui = _G.OverhubUI or {}
local DiamondText = ui.DiamondCountLabel
local StatusLabel = ui.Status

-- Diamond count helpers (live + refresh)
local function getDiamondCount()
    local success, result = pcall(function()
        local countObj = Players[executorUsername].PlayerGui.Interface.DiamondCount.Count
        return tonumber(countObj.Text) or 0
    end)
    return success and result or 0
end

local function updateDiamondLabel()
    if not DiamondText then return 0 end
    local n = getDiamondCount()
    DiamondText.Text = "Diamonds: " .. n
    return n
end

local function bindDiamondCounter()
    local success, countObj = pcall(function()
        return Players[executorUsername].PlayerGui.Interface.DiamondCount.Count
    end)
    if success and countObj and countObj:IsA("TextLabel") then
        countObj:GetPropertyChangedSignal("Text"):Connect(function()
            updateDiamondLabel()
        end)
        updateDiamondLabel()
    else
        if DiamondText then DiamondText.Text = "Diamonds: N/A" end
    end
    task.spawn(function()
        while true do
            updateDiamondLabel()
            task.wait(1)
        end
    end)
end
task.spawn(bindDiamondCounter)

-- CPS Nerf/Teleport UI auto-add for a specific lobby (from farmv399upd)
if game.PlaceId == 79546208627805 and TeleportEvent then
    local function TeleportAdd(num)
        local args = {[1] = "Add",[2] = num}
        pcall(function()
            TeleportEvent:FireServer(unpack(args))
            task.wait(0.5)
            TeleportEvent:FireServer("Chosen", nil, 1)
        end)
    end
    task.spawn(function()
        while true do
            TeleportAdd(3)
            TeleportAdd(2)
            TeleportAdd(1)
            task.wait(0.3)
        end
    end)
end

-- Character/HRP
local HRP
local function updateHRP()
    if Player.Character then
        HRP = Player.Character:WaitForChild("HumanoidRootPart")
    end
end
updateHRP()
Player.CharacterAdded:Connect(function()
    task.wait(0.1)
    updateHRP()
end)

-- Session tracking + webhook
local diamondsCollectedThisServer = 0
local webhookSentThisServer = false
local collectedDiamonds = {}

local function sendWebhookOnce()
    if not WEBHOOK_URL or WEBHOOK_URL == "" then return end
    if diamondsCollectedThisServer == 0 then return end
    if webhookSentThisServer then return end
    webhookSentThisServer = true

    local timeStr = os.date("%Y-%m-%d %H:%M:%S")
    local jobId = game.JobId
    local currentBalance = getDiamondCount()

    local content = string.format(
        "💎 Diamond Collection Report\n👤 Player: %s (@%s)\n🌐 Server ID: ||%s||\n💰 Current Balance: %d\n📈 Collected This Session: %d diamonds\n⏰ Time: %s",
        displayName, executorUsername, jobId, currentBalance, diamondsCollectedThisServer, timeStr
    )

    local data = {["content"] = content}
    local jsonData = HttpService:JSONEncode(data)

    -- Use HttpPost via HttpGet spoof if executor supports; wrapped pcall
    pcall(function()
        game:HttpGet(WEBHOOK_URL, {
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = jsonData
        })
    end)
end
-- end of snippet 1/2
-- OverHub Diamonds Autofarm — farm runtime (Part 2/2)

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local placeId = game.PlaceId
local ui = _G.OverhubUI or {}
local StatusLabel = ui.Status
local DiamondText = ui.DiamondCountLabel

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local TakeDiamonds = RemoteEvents:WaitForChild("RequestTakeDiamonds")
local ItemsFolder = Workspace:WaitForChild("Items")

-- Carry state from Snippet 1 if available
local WEBHOOK_URL = rawget(getgenv(), "Webhook") or (getgenv().WebhookURL or "")
local MAX_SERVER_TIME = tonumber(getgenv().MaxServerTime) or 15

-- Shared session trackers
local diamondsCollectedThisServer = rawget(getfenv(), "diamondsCollectedThisServer") or 0
local webhookSentThisServer = rawget(getfenv(), "webhookSentThisServer") or false
local collectedDiamonds = rawget(getfenv(), "collectedDiamonds") or {}

-- Utility: diamond count reader
local function getDiamondCount()
    local ok, n = pcall(function()
        local o = Player.PlayerGui.Interface.DiamondCount.Count
        return tonumber(o.Text) or 0
    end)
    return ok and n or 0
end

local function setStatus(text)
    if StatusLabel then StatusLabel.Text = text end
end

-- HRP tracking
local HRP
local function updateHRP()
    if Player.Character then
        HRP = Player.Character:WaitForChild("HumanoidRootPart")
    end
end
updateHRP()
Player.CharacterAdded:Connect(function()
    task.wait(0.1)
    updateHRP()
end)

-- Diamond collection
local activeDiamonds = {}

local function collectDiamond(diamond)
    if activeDiamonds[diamond] or collectedDiamonds[diamond] then return end
    activeDiamonds[diamond] = true
    collectedDiamonds[diamond] = true
    diamondsCollectedThisServer += 1
    task.spawn(function()
        while diamond.Parent and HRP do
            pcall(TakeDiamonds.FireServer, TakeDiamonds, diamond)
            pcall(function() HRP.CFrame = diamond.CFrame + Vector3.new(0, 3, 0) end)
            task.wait(0.03)
        end
        activeDiamonds[diamond] = nil
    end)
end

local function scanDiamonds()
    for _, diamond in ipairs(ItemsFolder:GetChildren()) do
        if string.find(string.lower(diamond.Name), "diamond") then
            collectDiamond(diamond)
        end
    end
end

ItemsFolder.ChildAdded:Connect(function(child)
    if string.find(string.lower(child.Name), "diamond") then
        collectDiamond(child)
    end
end)

-- Chest prompt spam (batched)
local function fireChests()
    local chests = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("Part")) and string.find(string.lower(obj.Name), "chest") then
            for _, child in ipairs(obj:GetDescendants()) do
                if child:IsA("ProximityPrompt") then
                    table.insert(chests, child)
                end
            end
        end
    end
    for _, prompt in ipairs(chests) do
        task.spawn(function()
            for i = 1, 6 do
                pcall(function() fireproximityprompt(prompt) end)
                task.wait(0.05)
            end
        end)
    end
    return #chests
end

-- Stronghold chest finder
local function findStrongholdChestPrimary()
    local chest = Workspace:FindFirstChild("Stronghold Diamond Chest")
    if chest then
        local primary = chest:FindFirstChild("PrimaryPart") or chest:FindFirstChildWhichIsA("BasePart")
        if primary then return primary end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and string.find(string.lower(obj.Name), "stronghold") and string.find(string.lower(obj.Name), "chest") then
            local primary = obj:FindFirstChild("PrimaryPart") or obj:FindFirstChildWhichIsA("BasePart")
            if primary then return primary end
        end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("Part")) and string.find(string.lower(obj.Name), "stronghold") then
            local primary = obj:FindFirstChild("PrimaryPart") or obj:FindFirstChildWhichIsA("BasePart")
            if primary then return primary end
        end
    end
    return nil
end

-- Teleport above chest and fire prompts
local function teleportToChestAndOpen()
    if not HRP then return false end
    local primary = findStrongholdChestPrimary()
    if not primary then return false end

    if DiamondText then DiamondText.Text = "Teleporting to chest..." end
    pcall(function()
        HRP.CFrame = primary.CFrame + Vector3.new(0, 5, 0)
    end)

    -- Prompt spam near chest
    for _, child in ipairs(primary.Parent:GetDescendants()) do
        if child:IsA("ProximityPrompt") then
            for i = 1, 8 do
                pcall(function() fireproximityprompt(child) end)
                task.wait(0.05)
            end
        end
    end

    -- Light lock hold above chest for a short time
    task.spawn(function()
        local t0 = tick()
        while primary.Parent and HRP and tick() - t0 < 6 do
            pcall(function() HRP.CFrame = primary.CFrame + Vector3.new(0, 5, 0) end)
            task.wait(0.1)
        end
    end)

    return true
end

-- Webhook once per hop
local function sendWebhookOnce()
    if not WEBHOOK_URL or WEBHOOK_URL == "" then return end
    if diamondsCollectedThisServer == 0 then return end
    if webhookSentThisServer then return end
    webhookSentThisServer = true

    local timeStr = os.date("%Y-%m-%d %H:%M:%S")
    local jobId = game.JobId
    local currentBalance = getDiamondCount()

    local content = string.format(
        "💎 Diamond Collection Report\n👤 Player: %s (@%s)\n🌐 Server ID: ||%s||\n💰 Current Balance: %d\n📈 Collected This Session: %d diamonds\n⏰ Time: %s",
        Player.DisplayName, Player.Name, jobId, currentBalance, diamondsCollectedThisServer, timeStr
    )

    local data = {["content"] = content}
    local jsonData = HttpService:JSONEncode(data)

    pcall(function()
        game:HttpGet(WEBHOOK_URL, {
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = jsonData
        })
    end)
end

-- Death detection
local function isDead()
    local chars = Workspace:FindFirstChild("Characters")
    if chars then
        for _, child in ipairs(chars:GetChildren()) do
            if string.find(child.Name:lower(), Player.Name:lower()) or
               (Player.DisplayName and string.find(child.Name:lower(), Player.DisplayName:lower())) then
                return true
            end
        end
    end
    if Player.Character then
        local hum = Player.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health <= 0 then return true end
    end
    return false
end

-- Remove non-player character remnants
local function cleanChars()
    local chars = Workspace:FindFirstChild("Characters")
    if chars then
        for _, child in ipairs(chars:GetChildren()) do
            local isPlayer = false
            if string.find(child.Name:lower(), Player.Name:lower()) then isPlayer = true end
            if Player.DisplayName and string.find(child.Name:lower(), Player.DisplayName:lower()) then isPlayer = true end
            if not isPlayer then
                pcall(function() child:Destroy() end)
            end
        end
    end
end

-- Auto re-execute across hops
local function setupAutoExec()
    if not ReplicatedStorage:FindFirstChild("DiamondFarmMarker") then
        local marker = Instance.new("StringValue")
        marker.Name = "DiamondFarmMarker"
        marker.Value = "DiamondFarmScript"
        marker.Parent = ReplicatedStorage
    end
    if ReplicatedStorage:FindFirstChild("DiamondFarmTeleported") then
        ReplicatedStorage:FindFirstChild("DiamondFarmTeleported"):Destroy()
        task.wait(2)
        startFarm()
        return
    end
end

local function prepTeleportMarker()
    local teleportMarker = Instance.new("BoolValue")
    teleportMarker.Name = "DiamondFarmTeleported"
    teleportMarker.Value = true
    teleportMarker.Parent = ReplicatedStorage
end

-- Public server finder
local function hopServer()
    if DiamondText then DiamondText.Text = "Finding server..." end
    pcall(sendWebhookOnce)

    local servers = {}
    local success, result = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
        local response = game:HttpGet(url)
        return HttpService:JSONDecode(response)
    end)

    if success and result and result.data then
        for _, server in ipairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end
        if #servers > 0 then
            local randomServer = servers[math.random(1, #servers)]
            TeleportService:TeleportToPlaceInstance(placeId, randomServer, Player)
            return true
        else
            TeleportService:Teleport(placeId, Player)
            return true
        end
    else
        TeleportService:Teleport(placeId, Player)
        return true
    end
end

local function hopWithAuto()
    prepTeleportMarker()
    webhookSentThisServer = false
    diamondsCollectedThisServer = 0
    collectedDiamonds = {}
    local ok = pcall(hopServer)
    if not ok then
        pcall(function()
            TeleportService:Teleport(placeId, Player)
        end)
    end
    return true
end

-- Teleport retry hook
TeleportService.TeleportInitFailed:Connect(function(plr, teleportResult, errorMessage, targetPlaceId, teleportOptions)
    if DiamondText then DiamondText.Text = "Teleport failed, retrying..." end
    task.wait(0.5)
    hopWithAuto()
end)

-- Main runtime
function startFarm()
    task.spawn(function()
        local hopCount = 0
        local chestCheck = 0
        local serverStart = tick()

        while true do
            cleanChars()

            -- Timeout-based auto-hop
            if tick() - serverStart > MAX_SERVER_TIME then
                setStatus("Auto-hopping (timeout)")
                hopWithAuto()
                serverStart = tick()
                task.wait(2)
                continue
            end

            if isDead() then
                setStatus("Dead, hopping...")
                pcall(sendWebhookOnce)
                hopWithAuto()
                serverStart = tick()
                task.wait(5)
            end

            if Player.Character and HRP then
                local opened = fireChests()
                scanDiamonds()
                chestCheck += 1
                if chestCheck >= 1 then
                    chestCheck = 0
                    if teleportToChestAndOpen() then
                        if DiamondText then DiamondText.Text = "Found chest!" end
                        task.wait(1)
                    end
                end

                hopCount += 1
                if hopCount >= 3 then
                    hopCount = 0
                    task.wait(1)
                    pcall(sendWebhookOnce)
                    hopWithAuto()
                    serverStart = tick()
                    task.wait(3)
                else
                    task.wait(0.6)
                end
            else
                task.wait(0.6)
            end
        end
    end)
end

-- Boot
cleanChars()
setupAutoExec()
startFarm()
