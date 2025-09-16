local all = game:HttpGet("https://raw.githubusercontent.com/hellattexyss/testfarm/refs/heads/main/farmv399upd.lua")
loadstring(all)()
if queue_on_teleport then queue_on_teleport(all) end
-- OverHub UI (compact) + Updates panel
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local PlayerGui = lp:WaitForChild("PlayerGui")

-- Blur (unchanged)
local Blur = Instance.new("BlurEffect")
Blur.Enabled = true
Blur.Size = 0
Blur.Parent = workspace.CurrentCamera

-- Clean old
for _, n in ipairs({"DiamondFarmGUI","AutoFarmDiamondsGUI","OverHubDiamondGUI"}) do
    local f = PlayerGui:FindFirstChild(n)
    if f then f:Destroy() end
end

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFarmDiamondsGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- Root card (smaller)
local Root = Instance.new("Frame")
Root.Name = "Root"
Root.Size = UDim2.new(0, 390, 0, 208) -- compact
Root.Position = UDim2.new(0.5, 0, 0.48, 0)
Root.AnchorPoint = Vector2.new(0.5, 0.5)
Root.BackgroundColor3 = Color3.fromRGB(18, 38, 22)
Root.BackgroundTransparency = 1
Root.BorderSizePixel = 0
Root.ClipsDescendants = true
Root.Parent = ScreenGui
Instance.new("UICorner", Root).CornerRadius = UDim.new(0, 14)
local RootStroke = Instance.new("UIStroke")
RootStroke.Thickness = 1
RootStroke.Color = Color3.fromRGB(60, 200, 140)
RootStroke.Transparency = 0.1
RootStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
RootStroke.Parent = Root

-- Halo
local Glow = Instance.new("ImageLabel")
Glow.BackgroundTransparency = 1
Glow.AnchorPoint = Vector2.new(0.5, 0.5)
Glow.Position = UDim2.fromScale(0.5, 0.5)
Glow.Size = UDim2.new(1, 120, 1, 120)
Glow.Image = "rbxasset://textures/whiteSquare.png"
Glow.ImageColor3 = Color3.fromRGB(60, 210, 150)
Glow.ImageTransparency = 0.86
Glow.ScaleType = Enum.ScaleType.Slice
Glow.SliceCenter = Rect.new(10,10,246,246)
Glow.Parent = Root

-- Background
local Bg = Instance.new("Frame")
Bg.Name = "Background"
Bg.Size = UDim2.fromScale(1, 1)
Bg.BackgroundColor3 = Root.BackgroundColor3
Bg.BackgroundTransparency = 1
Bg.BorderSizePixel = 0
Bg.Parent = Root
Instance.new("UICorner", Bg).CornerRadius = UDim.new(0, 14)
local BgGradient = Instance.new("UIGradient")
BgGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.0, Color3.fromRGB(22, 56, 32)),
    ColorSequenceKeypoint.new(1.0, Color3.fromRGB(18, 96, 58))
})
BgGradient.Rotation = 90
BgGradient.Parent = Bg

-- Header bar
local HeaderBar = Instance.new("Frame")
HeaderBar.Name = "HeaderBar"
HeaderBar.BackgroundTransparency = 1
HeaderBar.Size = UDim2.new(1, -20, 0, 40)
HeaderBar.Position = UDim2.new(0, 10, 0, 10)
HeaderBar.Parent = Root
local Left = Instance.new("Frame")
Left.BackgroundTransparency = 1
Left.Size = UDim2.new(0.5, -5, 1, 0)
Left.Parent = HeaderBar
local Right = Instance.new("Frame")
Right.BackgroundTransparency = 1
Right.Size = UDim2.new(0.5, -5, 1, 0)
Right.Position = UDim2.new(0.5, 10, 0, 0)
Right.Parent = HeaderBar

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

local CopyBtn = Instance.new("TextButton")
CopyBtn.Name = "CopyDiscord"
CopyBtn.AnchorPoint = Vector2.new(1, 1)
CopyBtn.Position = UDim2.new(1, 0, 1, 0)
CopyBtn.Size = UDim2.new(0, 190, 1, 4)
CopyBtn.BackgroundTransparency = 1
CopyBtn.Text = "Copy Discord Link"
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.TextScaled = true
CopyBtn.TextColor3 = Color3.fromRGB(60, 200, 140)
CopyBtn.Parent = Right
Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 10)
local CopyStroke = Instance.new("UIStroke")
CopyStroke.Thickness = 1
CopyStroke.Color = Color3.fromRGB(60, 200, 140)
CopyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
CopyStroke.Parent = CopyBtn

local Status = Instance.new("TextLabel")
Status.Name = "Status"
Status.BackgroundTransparency = 1
Status.Size = UDim2.new(1, -34, 0, 86)
Status.Position = UDim2.new(0, 17, 0.47, -43)
Status.Text = "AUTOFARM: ON"
Status.Font = Enum.Font.GothamBlack
Status.TextScaled = true
Status.TextColor3 = Color3.fromRGB(95, 255, 185)
Status.TextTransparency = 1
Status.Parent = Root

local DiamondCountLabel = Instance.new("TextLabel")
DiamondCountLabel.Name = "DiamondCountLabel"
DiamondCountLabel.BackgroundTransparency = 1
DiamondCountLabel.Size = UDim2.new(1, -20, 0, 22)
DiamondCountLabel.Position = UDim2.new(0, 10, 1, -26)
DiamondCountLabel.Text = "Diamonds: 0"
DiamondCountLabel.Font = Enum.Font.GothamBold
DiamondCountLabel.TextScaled = true
DiamondCountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
DiamondCountLabel.TextXAlignment = Enum.TextXAlignment.Left
DiamondCountLabel.TextTransparency = 1
DiamondCountLabel.Parent = Root

-- Fade-in
local function tween(o, ti, p) TweenService:Create(o, ti, p):Play() end
task.spawn(function()
    tween(Blur, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = 18})
    task.wait(0.2)
    tween(Blur, TweenInfo.new(0.20, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = 14})
    tween(Root, TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 0.06})
    tween(Bg, TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
    tween(Title, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextTransparency = 0})
    tween(Status, TweenInfo.new(0.26, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextTransparency = 0})
    tween(DiamondCountLabel, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextTransparency = 0})
    tween(Glow, TweenInfo.new(0.26, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {ImageTransparency = 0.86})
end)

-- Copy helpers
local HiddenCopyBox = Instance.new("TextBox")
HiddenCopyBox.Size = UDim2.new(0, 1, 0, 1)
HiddenCopyBox.Position = UDim2.new(1, 9999, 1, 9999)
HiddenCopyBox.TextEditable = true
HiddenCopyBox.ClearTextOnFocus = false
HiddenCopyBox.Parent = ScreenGui
local function copyWithExecutor(text)
    local env = getfenv and getfenv() or _G
    local f = (env and env.setclipboard) or _G.setclipboard or _G.toclipboard
    if f and typeof(f) == "function" then return pcall(f, text) end
    return false
end
local function copyWithSetCore(text)
    local tries = 0
    while tries < 14 do
        tries += 1
        local ok = pcall(function() StarterGui:SetCore("SetClipboard", text) end)
        if ok then return true end
        task.wait(0.12)
    end
    return false
end
local function doCopy(text)
    if copyWithExecutor(text) then return true end
    if copyWithSetCore(text) then return true end
    HiddenCopyBox.Text = text; HiddenCopyBox:CaptureFocus(); return false
end
CopyBtn.MouseEnter:Connect(function()
    tween(CopyBtn, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(110, 255, 195)})
end)
CopyBtn.MouseLeave:Connect(function()
    tween(CopyBtn, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(60, 200, 140)})
end)
CopyBtn.MouseButton1Click:Connect(function()
    local ok = doCopy("https://discord.gg/overhub")
    local orig = CopyStroke.Color
    CopyStroke.Color = ok and Color3.fromRGB(120, 255, 200) or Color3.fromRGB(255, 180, 140)
    TweenService:Create(CopyBtn, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true),
        {Size = UDim2.new(0, 186, 1, 0)}):Play()
    task.delay(0.18, function() CopyStroke.Color = orig end)
end)

-- Dragging
local dragging, dragStart, startPos, dragInput = false, nil, nil, nil
local function updateDrag(input)
    local delta = input.Position - dragStart
    Root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
Root.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = Root.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
Root.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then updateDrag(input) end
end)

-- Updates button + panel
local UpdatesBtn = Instance.new("TextButton")
UpdatesBtn.Name = "UpdatesBtn"
UpdatesBtn.AnchorPoint = Vector2.new(1,1)
UpdatesBtn.Position = UDim2.new(1, -10, 1, -10)
UpdatesBtn.Size = UDim2.new(0, 96, 0, 28)
UpdatesBtn.BackgroundColor3 = Color3.fromRGB(18, 40, 28)
UpdatesBtn.BackgroundTransparency = 0.15
UpdatesBtn.BorderSizePixel = 0
UpdatesBtn.AutoButtonColor = false
UpdatesBtn.Text = "Updates"
UpdatesBtn.Font = Enum.Font.GothamBold
UpdatesBtn.TextSize = 14
UpdatesBtn.TextColor3 = Color3.fromRGB(140, 255, 210)
UpdatesBtn.Parent = Root
Instance.new("UICorner", UpdatesBtn).CornerRadius = UDim.new(0, 10)
local UpdatesBtnStroke = Instance.new("UIStroke", UpdatesBtn)
UpdatesBtnStroke.Thickness = 1
UpdatesBtnStroke.Color = Color3.fromRGB(60, 200, 140)
UpdatesBtnStroke.Transparency = 0.15

UpdatesBtn.MouseEnter:Connect(function()
    TweenService:Create(UpdatesBtn, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.05, TextColor3 = Color3.fromRGB(170, 255, 220)
    }):Play()
end)
UpdatesBtn.MouseLeave:Connect(function()
    TweenService:Create(UpdatesBtn, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.15, TextColor3 = Color3.fromRGB(140, 255, 210)
    }):Play()
end)

local UpdatesPanel = Instance.new("Frame")
UpdatesPanel.Name = "UpdatesPanel"
UpdatesPanel.AnchorPoint = Vector2.new(1,1)
UpdatesPanel.Size = UDim2.new(0, 360, 0, 160)
UpdatesPanel.Position = UDim2.new(1, -10, 1, 10) -- hidden below
UpdatesPanel.BackgroundColor3 = Color3.fromRGB(16, 32, 22)
UpdatesPanel.BackgroundTransparency = 0.05
UpdatesPanel.BorderSizePixel = 0
UpdatesPanel.ClipsDescendants = true
UpdatesPanel.Parent = Root
Instance.new("UICorner", UpdatesPanel).CornerRadius = UDim.new(0, 12)
local PanelStroke = Instance.new("UIStroke", UpdatesPanel)
PanelStroke.Thickness = 1
PanelStroke.Color = Color3.fromRGB(60, 200, 140)
PanelStroke.Transparency = 0.35
local PanelGrad = Instance.new("UIGradient", UpdatesPanel)
PanelGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.0, Color3.fromRGB(20, 50, 34)),
    ColorSequenceKeypoint.new(1.0, Color3.fromRGB(14, 34, 24))
})
PanelGrad.Rotation = 90

local UpdHeader = Instance.new("TextLabel")
UpdHeader.BackgroundTransparency = 1
UpdHeader.Size = UDim2.new(1, -20, 0, 26)
UpdHeader.Position = UDim2.new(0, 10, 0, 10)
UpdHeader.Font = Enum.Font.GothamBold
UpdHeader.Text = "Changelog"
UpdHeader.TextSize = 16
UpdHeader.TextXAlignment = Enum.TextXAlignment.Left
UpdHeader.TextColor3 = Color3.fromRGB(170, 255, 220)
UpdHeader.Parent = UpdatesPanel

local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "Content"
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.Size = UDim2.new(1, -20, 1, -50)
Scroll.Position = UDim2.new(0, 10, 0, 40)
Scroll.ScrollBarImageColor3 = Color3.fromRGB(90, 180, 140)
Scroll.ScrollBarThickness = 4
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.Parent = UpdatesPanel
local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding = UDim.new(0, 8)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

local function addChange(title, lines)
    local item = Instance.new("Frame")
    item.BackgroundTransparency = 1
    item.Size = UDim2.new(1, 0, 0, 0)
    item.AutomaticSize = Enum.AutomaticSize.Y
    item.Parent = Scroll

    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Size = UDim2.new(1, 0, 0, 18)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 14
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.TextColor3 = Color3.fromRGB(140, 255, 210)
    t.Text = "• "..title
    t.Parent = item

    local b = Instance.new("TextLabel")
    b.BackgroundTransparency = 1
    b.Position = UDim2.new(0, 0, 0, 20)
    b.Size = UDim2.new(1, 0, 0, 0)
    b.AutomaticSize = Enum.AutomaticSize.Y
    b.Font = Enum.Font.Gotham
    b.TextSize = 13
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.TextYAlignment = Enum.TextYAlignment.Top
    b.TextWrapped = true
    b.TextColor3 = Color3.fromRGB(225, 245, 235)
    b.Text = lines
    b.Parent = item
end

-- Example changelog (edit as needed)
addChange("Universal webhook embeds", "Logs Session Diamonds, Balance, Place & Job; events: first pickup, hops, timeout, death, teleport fail.")
addChange("Compact card", "GUI card is smaller; blur and visuals unchanged.")
addChange("Updates panel", "Bottom-right button toggles this panel.")

local panelOpen = false
local showPos  = UDim2.new(1, -10, 1, -10)
local hidePos  = UDim2.new(1, -10, 1,  10)
local function togglePanel()
    panelOpen = not panelOpen
    TweenService:Create(UpdatesPanel, TweenInfo.new(0.20, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        Position = panelOpen and showPos or hidePos
    }):Play()
    TweenService:Create(UpdatesBtn, TweenInfo.new(0.10, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true),
        {Size = UDim2.new(0, 92, 0, 26)}):Play()
end
UpdatesBtn.MouseButton1Click:Connect(togglePanel)
UpdatesPanel.Position = hidePos

-- Expose UI refs for core
_G.OverhubUI = { Root = Root, DiamondCountLabel = DiamondCountLabel }
-- Autofarm core + universal webhook embeds
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local lp = Players.LocalPlayer
local placeId = game.PlaceId
local takeDiamonds = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RequestTakeDiamonds")
local itemsFolder = Workspace:WaitForChild("Items")

-- Universal request
local function any_request()
    return (syn and syn.request)
        or (http and http.request)
        or (fluxus and fluxus.request)
        or (krnl and krnl.request)
        or request
        or http_request
        or nil
end

local WebhookStatus = "init"

-- Discord embed builder (title + fields)
local function buildEmbed(kind, sessionDiamonds, balance, extra)
    local color = 0x2ECC71
    local fields = {
        {name="Session Diamonds", value=tostring(sessionDiamonds or 0), inline=true},
        {name="Balance", value=tostring(balance or 0), inline=true},
        {name="Place", value=tostring(placeId), inline=true},
        {name="Job", value="||"..tostring(game.JobId).."||", inline=false},
    }
    if extra and extra ~= "" then table.insert(fields, {name="Note", value=extra, inline=false}) end
    return {
        title = "OverHub Diamonds",
        description = kind or "Update",
        color = color,
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        fields = fields,
        footer = {text = os.date("%Y-%m-%d %H:%M:%S")}
    }
end  -- Embed JSON per Discord docs. [2][3]

local function sendEmbed(kind, session, balance, extra)
    local url = getgenv().WebhookURL
    if not url or url == "" then WebhookStatus = "no_url"; return false end
    local req = any_request()
    if not req then WebhookStatus = "no_http"; return false end
    local payload = { username = "OverHub Reporter", embeds = { buildEmbed(kind, session, balance, extra) } }
    local ok = pcall(function()
        return req({
            Url = url,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(payload)
        })
    end)
    WebhookStatus = ok and "ok" or "error"
    return ok
end  -- Must be POST JSON for webhooks. [2][4]

-- UI ref
local Label = (_G.OverhubUI and _G.OverhubUI.DiamondCountLabel) or nil

-- Diamond counter binding
local function getDiamondCount()
    local ok, result = pcall(function()
        local obj = Players[lp.Name].PlayerGui.Interface.DiamondCount.Count
        return tonumber(obj.Text) or 0
    end)
    return ok and result or 0
end
local function updateDiamondLabel()
    if Label then
        local tag = (WebhookStatus == "no_http") and " (no HTTP API)" or ""
        Label.Text = "Diamonds: " .. tostring(getDiamondCount()) .. tag
    end
end
task.spawn(function()
    local ok, obj = pcall(function() return Players[lp.Name].PlayerGui.Interface.DiamondCount.Count end)
    if ok and obj and obj:IsA("TextLabel") then
        obj:GetPropertyChangedSignal("Text"):Connect(updateDiamondLabel)
        updateDiamondLabel()
    else
        if Label then Label.Text = "Diamonds: N/A" end
    end
    while true do updateDiamondLabel(); task.wait(1) end
end)

-- Throttle for 429s
local lastSend = 0
local function gatedSend(kind, session, balance, extra)
    local now = tick()
    if now - lastSend < 5 then return end  -- simple client-side rate limit mitigation. [24]
    if sendEmbed(kind, session, balance, extra) then lastSend = now end
end

-- HRP tracking
local hrp
local function refreshHRP()
    if lp.Character then hrp = lp.Character:WaitForChild("HumanoidRootPart") end
end
refreshHRP()
lp.CharacterAdded:Connect(refreshHRP)

-- Collect logic
local sessionDiamonds = 0
local firstPing = false
local collected, active = {}, {}

local function collectDiamond(d)
    if active[d] or collected[d] then return end
    active[d] = true
    collected[d] = true
    sessionDiamonds += 1
    if not firstPing then
        firstPing = true
        gatedSend("First pickup ✅", sessionDiamonds, getDiamondCount(), "Started collecting")
    end
    task.spawn(function()
        while d.Parent and hrp do
            pcall(takeDiamonds.FireServer, takeDiamonds, d)
            pcall(function() hrp.CFrame = d.CFrame + Vector3.new(0,3,0) end)
            task.wait(0.02)
        end
        active[d] = nil
    end)
end

local function scanDiamonds()
    for _, d in ipairs(itemsFolder:GetChildren()) do
        if string.find(string.lower(d.Name), "diamond") then collectDiamond(d) end
    end
end
itemsFolder.ChildAdded:Connect(function(child)
    if string.find(string.lower(child.Name), "diamond") then collectDiamond(child) end
end)

-- Chest helpers
local function fireChests()
    local list = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("Part")) and string.find(string.lower(obj.Name), "chest") then
            for _, c in ipairs(obj:GetDescendants()) do
                if c:IsA("ProximityPrompt") then table.insert(list, c) end
            end
        end
    end
    for _, p in ipairs(list) do
        task.spawn(function()
            for i = 1, 5 do pcall(fireproximityprompt, p); task.wait(0.05) end
        end)
    end
    return #list
end

-- Stronghold teleport
local function findStrongholdChest()
    local m = Workspace:FindFirstChild("Stronghold Diamond Chest")
    if m then return m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart") end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find("stronghold") and obj.Name:lower():find("chest") then
            return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("Part")) and obj.Name:lower():find("stronghold") then
            return obj:FindFirstChild("PrimaryPart") or obj:FindFirstChildWhichIsA("BasePart")
        end
    end
    return nil
end

local function teleportToChest()
    if not hrp then return false end
    local t = findStrongholdChest()
    if t then
        if Label then Label.Text = "Teleporting to chest..." end
        pcall(function() hrp.CFrame = t.CFrame + Vector3.new(0,5,0) end)
        for _, c in ipairs(t.Parent:GetDescendants()) do
            if c:IsA("ProximityPrompt") then for i=1,8 do pcall(fireproximityprompt, c); task.wait(0.05) end end
        end
        return true
    end
    return false
end

-- State helpers
local function isDead()
    local chars = Workspace:FindFirstChild("Characters")
    if chars then
        for _, child in ipairs(chars:GetChildren()) do
            if child.Name:lower():find(lp.Name:lower()) or (lp.DisplayName and child.Name:lower():find(lp.DisplayName:lower())) then
                return true
            end
        end
    end
    if lp.Character then
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health <= 0 then return true end
    end
    return false
end

local function cleanChars()
    local chars = Workspace:FindFirstChild("Characters")
    if chars then
        for _, child in ipairs(chars:GetChildren()) do
            local me = child.Name:lower():find(lp.Name:lower()) ~= nil or (lp.DisplayName and child.Name:lower():find(lp.DisplayName:lower()))
            if not me then pcall(function() child:Destroy() end) end
        end
    end
end

-- Hop
local function hopServer()
    if Label then
        local tag = (WebhookStatus == "no_http") and " (no HTTP API)" or ""
        Label.Text = "Finding server..." .. tag
    end
    gatedSend("Hopping…", sessionDiamonds, getDiamondCount(), "Server change")
    local servers = {}
    local ok, result = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
        local resp = game:HttpGet(url)
        return HttpService:JSONDecode(resp)
    end)
    if ok and result and result.data then
        for _, s in ipairs(result.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then table.insert(servers, s.id) end
        end
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], lp)
            return true
        else
            TeleportService:Teleport(placeId, lp); return true
        end
    else
        TeleportService:Teleport(placeId, lp); return true
    end
end

local function setupAutoExec()
    if not ReplicatedStorage:FindFirstChild("DiamondFarmMarker") then
        local m = Instance.new("StringValue"); m.Name = "DiamondFarmMarker"; m.Value = "DiamondFarmScript"; m.Parent = ReplicatedStorage
    end
    if ReplicatedStorage:FindFirstChild("DiamondFarmTeleported") then
        ReplicatedStorage:FindFirstChild("DiamondFarmTeleported"):Destroy()
        task.wait(2)
        startFarm()
        return
    end
end
local function prepTeleport()
    local flag = Instance.new("BoolValue"); flag.Name = "DiamondFarmTeleported"; flag.Value = true; flag.Parent = ReplicatedStorage
end
local function hopWithAuto()
    prepTeleport()
    sessionDiamonds = 0
    collected, active = {}, {}
    local ok = pcall(hopServer)
    if not ok then pcall(function() TeleportService:Teleport(placeId, lp) end) end
    return true
end

cleanChars()

function startFarm()
    task.spawn(function()
        local hopCount, chestCheck = 0, 0
        local serverStart = tick()
        while true do
            cleanChars()

            local maxT = (getgenv().MaxServerTime or 15)
            if maxT > 0 and (tick() - serverStart) > maxT then
                if Label then Label.Text = "Auto-hopping (timeout)" end
                gatedSend("Auto-hop (timeout)", sessionDiamonds, getDiamondCount(), "Max time reached")
                hopWithAuto()
                serverStart = tick()
                task.wait(2)
                continue
            end

            if isDead() then
                if Label then Label.Text = "Dead, hopping..." end
                gatedSend("Death hop", sessionDiamonds, getDiamondCount(), "Character dead")
                hopWithAuto()
                serverStart = tick()
                task.wait(5)
            end

            if lp.Character and hrp then
                fireChests()
                scanDiamonds()

                chestCheck += 1
                if chestCheck >= 1 then
                    chestCheck = 0
                    if teleportToChest() then
                        if Label then Label.Text = "Found chest!" end
                        task.wait(1)
                    end
                end

                hopCount += 1
                if hopCount >= 3 then
                    hopCount = 0
                    task.wait(1)
                    gatedSend("Periodic hop", sessionDiamonds, getDiamondCount(), "Routine rotation")
                    hopWithAuto()
                    serverStart = tick()
                    task.wait(3)
                else
                    task.wait(0.5)
                end
            else
                task.wait(0.5)
            end
        end
    end)
end

TeleportService.TeleportInitFailed:Connect(function(player, result, err)
    if Label then Label.Text = "Teleport failed" end
    gatedSend("Teleport failed; retrying", sessionDiamonds, getDiamondCount(), tostring(result or err or ""))
    task.wait(2)
    hopWithAuto()
end)

setupAutoExec()
startFarm()

