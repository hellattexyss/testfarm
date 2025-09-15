--========================
-- OverHub GUI + Clipboard + Drag + Diamond Label + Queue/Lobby
--========================

-- Re-queue loader across teleports
pcall(function()
    if queue_on_teleport then
        queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/Rx1m/CpsHub/refs/heads/main/Cpsnerfv2"))()')
    end
end) -- use queue_on_teleport in supported envs [4]

-- Lobby auto-teleport helper for specific place
pcall(function()
    if game.PlaceId == 79546208627805 then
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 9e9)
        local TeleportEvent = RemoteEvents:WaitForChild("TeleportEvent", 9e9)

        local function TeleportAdd(num)
            local args = {[1] = "Add",[2] = num}
            TeleportEvent:FireServer(unpack(args))
            task.wait(0.5)
            TeleportEvent:FireServer("Chosen", nil, 1)
        end

        task.spawn(function()
            while true do
                TeleportAdd(3); TeleportAdd(2); TeleportAdd(1)
                task.wait(0.3)
            end
        end)
    end
end) -- per-lobby remote usage; keep isolated [9][18]

-- Services
local plrs = game:GetService("Players")
local ts = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local ws = game:GetService("Workspace")
local rs = game:GetService("ReplicatedStorage")
local tps = game:GetService("TeleportService")
local hs = game:GetService("HttpService")

-- Settings (webhook optional)
getgenv().WebhookURL = getgenv().WebhookURL or ""
getgenv().MaxServerTime = getgenv().MaxServerTime or 15

-- Player refs
local lp = plrs.LocalPlayer
local pgui = lp:WaitForChild("PlayerGui") -- ensure UI parent [24]

-- Clean any older GUI to avoid duplicates
for _, n in ipairs({"DiamondFarmGUI","AutoFarmDiamondsGUI"}) do
    local f = pgui:FindFirstChild(n)
    if f then f:Destroy() end
end -- avoid stacking [24]

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "DiamondFarmGUI"
gui.ResetOnSpawn = false
gui.Parent = pgui -- correct placement [24]

-- Root panel (matches previous look)
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 280, 0, 160)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = main

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(128,0,255)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255,0,128)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0,128,255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20,20,20)),
})
gradient.Rotation = 45
gradient.Parent = main

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundTransparency = 1
TopBar.Parent = main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "CPS Nerf / mrpopcat14"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -35, 0, 5)
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255,255,255)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 20
MinimizeButton.Parent = TopBar

local ButtonsFrame = Instance.new("Frame")
ButtonsFrame.Size = UDim2.new(1, 0, 1, -40)
ButtonsFrame.Position = UDim2.new(0, 0, 0, 40)
ButtonsFrame.BackgroundTransparency = 1
ButtonsFrame.Parent = main

local DiamondCountLabel = Instance.new("TextLabel")
DiamondCountLabel.Size = UDim2.new(1, -20, 0, 30)
DiamondCountLabel.Position = UDim2.new(0, 10, 0, 10)
DiamondCountLabel.BackgroundTransparency = 1
DiamondCountLabel.Text = "Diamonds: 0"
DiamondCountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
DiamondCountLabel.Font = Enum.Font.GothamBold
DiamondCountLabel.TextSize = 16
DiamondCountLabel.TextXAlignment = Enum.TextXAlignment.Left
DiamondCountLabel.Parent = ButtonsFrame

local DiscordButton = Instance.new("TextButton")
DiscordButton.Size = UDim2.new(0, 180, 0, 40)
DiscordButton.AnchorPoint = Vector2.new(0.5,0.5)
DiscordButton.Position = UDim2.new(0.5, 0, 0.5, 30)
DiscordButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
DiscordButton.BackgroundTransparency = 0.5
DiscordButton.BorderSizePixel = 0
DiscordButton.Text = "Copy Discord Invite"
DiscordButton.TextColor3 = Color3.fromRGB(255,255,255)
DiscordButton.Font = Enum.Font.GothamBold
DiscordButton.TextSize = 14
DiscordButton.Parent = ButtonsFrame

local discordCorner = Instance.new("UICorner")
discordCorner.CornerRadius = UDim.new(0, 6)
discordCorner.Parent = DiscordButton

DiscordButton.MouseEnter:Connect(function()
    ts:Create(DiscordButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
end)
DiscordButton.MouseLeave:Connect(function()
    ts:Create(DiscordButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
end)
DiscordButton.MouseButton1Click:Connect(function()
    local env = getfenv and getfenv() or _G
    local f = (env and env.setclipboard) or _G.setclipboard or _G.toclipboard
    if f and typeof(f) == "function" then pcall(f, "https://discord.gg/pdp65qN3Ck") end
    ts:Create(DiscordButton, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true), {Size = UDim2.new(0,170,0,36)}):Play()
end) -- executor-first clipboard, no prompts [13]

local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        ts:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0,280,0,40)}):Play()
        ts:Create(DiscordButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1,-90,0,20)}):Play()
        DiamondCountLabel.Visible = false
    else
        ts:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0,280,0,160)}):Play()
        ts:Create(DiscordButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5,0,0.5,30)}):Play()
        DiamondCountLabel.Visible = true
    end
end)

-- Rotating gradient flair
task.spawn(function()
    while true do
        gradient.Rotation += 1
        task.wait(0.02)
    end
end)

-- Drag support [25]
local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
local function updateDrag(input)
    local delta = input.Position - dragStart
    main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
uis.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

-- Expose key UI refs for the farm core
_G.OverHubUI = { DiamondCountLabel = DiamondCountLabel }

-- END SNIPPET 1
--========================
-- Autofarm Core + Diamond Counter + Chest + Hopping + Webhook
--========================

local plrs = game:GetService("Players")
local ws = game:GetService("Workspace")
local rs = game:GetService("ReplicatedStorage")
local tps = game:GetService("TeleportService")
local hs = game:GetService("HttpService")

local lp = plrs.LocalPlayer
local placeId = game.PlaceId
local takeDiamonds = rs:WaitForChild("RemoteEvents"):WaitForChild("RequestTakeDiamonds")
local itemsFolder = ws:WaitForChild("Items")

local username = lp.Name
local displayName = lp.DisplayName

local DiamondCountLabel = (_G.OverHubUI and _G.OverHubUI.DiamondCountLabel) or nil

local diamondsCollectedThisServer = 0
local webhookSentThisServer = false
local collectedDiamonds = {}

-- Diamond counter source from Interface.DiamondCount.Count [24]
local function getDiamondCount()
    local ok, result = pcall(function()
        local countObj = plrs[username].PlayerGui.Interface.DiamondCount.Count
        return tonumber(countObj.Text) or 0
    end)
    return ok and result or 0
end
local function updateDiamondDisplay()
    if DiamondCountLabel then
        DiamondCountLabel.Text = "Diamonds: " .. tostring(getDiamondCount())
    end
end
local function setupDiamondListener()
    local ok, countObj = pcall(function()
        return plrs[username].PlayerGui.Interface.DiamondCount.Count
    end)
    if ok and countObj and countObj:IsA("TextLabel") then
        countObj:GetPropertyChangedSignal("Text"):Connect(updateDiamondDisplay)
        updateDiamondDisplay()
    else
        if DiamondCountLabel then DiamondCountLabel.Text = "Diamonds: N/A" end
    end
    task.spawn(function()
        while true do
            updateDiamondDisplay()
            task.wait(1)
        end
    end)
end
task.spawn(setupDiamondListener) -- keep GUI synced [24]

-- Webhook on hop (optional; uses GET wrapper many executors provide) [13]
local function sendWebhook()
    if not getgenv().WebhookURL or getgenv().WebhookURL == "" then return end
    if diamondsCollectedThisServer == 0 then return end
    if webhookSentThisServer then return end
    webhookSentThisServer = true

    local timeStr = os.date("%Y-%m-%d %H:%M:%S")
    local jobId = game.JobId
    local balance = getDiamondCount()

    local message = string.format(
        "💎 Diamond Collection Report\n👤 Player: %s (@%s)\n🌐 Server ID: ||%s||\n💰 Current Balance: %d\n📊 Collected This Session: %d\n⏰ Time: %s",
        displayName, username, jobId, balance, diamondsCollectedThisServer, timeStr
    )
    local data = { content = message }
    local json = hs:JSONEncode(data)

    pcall(function()
        -- Most exploits expose request(); fallback to HttpGet-as-post in some envs
        if request then
            request({Url = getgenv().WebhookURL, Method = "POST", Headers = {["Content-Type"]="application/json"}, Body = json})
        else
            game:HttpGet(getgenv().WebhookURL, {Method="POST", Headers={["Content-Type"]="application/json"}, Body=json})
        end
    end)
end

-- HRP tracking
local hrp
local function updateHRP()
    if lp.Character then
        hrp = lp.Character:WaitForChild("HumanoidRootPart")
    end
end
updateHRP()
lp.CharacterAdded:Connect(updateHRP)

local activeDiamonds = {}

-- Collector: guard per-instance; increments per-server tracker
local function collectDiamond(diamond)
    if activeDiamonds[diamond] or collectedDiamonds[diamond] then return end
    activeDiamonds[diamond] = true
    collectedDiamonds[diamond] = true
    diamondsCollectedThisServer += 1

    task.spawn(function()
        while diamond.Parent and hrp do
            pcall(takeDiamonds.FireServer, takeDiamonds, diamond)
            pcall(function() hrp.CFrame = diamond.CFrame + Vector3.new(0,3,0) end)
            task.wait(0.02)
        end
        activeDiamonds[diamond] = nil
    end)
end

-- Scan + reactive
local function scanDiamonds()
    for _, d in ipairs(itemsFolder:GetChildren()) do
        if string.find(string.lower(d.Name), "diamond") then
            collectDiamond(d)
        end
    end
end
itemsFolder.ChildAdded:Connect(function(child)
    if string.find(string.lower(child.Name), "diamond") then
        collectDiamond(child)
    end
end)

-- Chest tapping
local function fireChests()
    local chests = {}
    for _, obj in ipairs(ws:GetDescendants()) do
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
            for i = 1, 5 do
                pcall(fireproximityprompt, prompt)
                task.wait(0.05)
            end
        end)
    end
    return #chests
end

-- Stronghold chest finder + teleport tapper
local function findStrongholdChest()
    local chest = ws:FindFirstChild("Stronghold Diamond Chest")
    if chest then
        return chest.PrimaryPart or chest:FindFirstChildWhichIsA("BasePart")
    end
    for _, obj in ipairs(ws:GetDescendants()) do
        if obj:IsA("Model") and string.find(string.lower(obj.Name), "stronghold") and string.find(string.lower(obj.Name), "chest") then
            return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        end
    end
    for _, obj in ipairs(ws:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("Part")) and string.find(string.lower(obj.Name), "stronghold") then
            return obj:FindFirstChild("PrimaryPart") or obj:FindFirstChildWhichIsA("BasePart")
        end
    end
    return nil
end

local function teleportToChest()
    if not hrp then return false end
    local chestPart = findStrongholdChest()
    if chestPart then
        if DiamondCountLabel then DiamondCountLabel.Text = "Teleporting to chest..." end
        pcall(function() hrp.CFrame = chestPart.CFrame + Vector3.new(0, 5, 0) end)
        for _, child in ipairs(chestPart.Parent:GetDescendants()) do
            if child:IsA("ProximityPrompt") then
                for i = 1, 8 do
                    pcall(fireproximityprompt, child)
                    task.wait(0.05)
                end
            end
        end
        return true
    end
    return false
end

-- Server list -> hop to random public server [6]
local function hopServer()
    if DiamondCountLabel then DiamondCountLabel.Text = "Finding server..." end
    pcall(sendWebhook)

    local servers = {}
    local ok, result = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
        local response = game:HttpGet(url)
        return hs:JSONDecode(response)
    end)
    if ok and result and result.data then
        for _, s in ipairs(result.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                table.insert(servers, s.id)
            end
        end
        if #servers > 0 then
            local target = servers[math.random(1, #servers)]
            tps:TeleportToPlaceInstance(placeId, target, lp)
            return true
        else
            tps:Teleport(placeId, lp)
            return true
        end
    else
        tps:Teleport(placeId, lp)
        return true
    end
end

-- Status helpers
local function isDead()
    local chars = ws:FindFirstChild("Characters")
    if chars then
        for _, child in ipairs(chars:GetChildren()) do
            if string.find(child.Name:lower(), lp.Name:lower()) or (displayName and string.find(child.Name:lower(), displayName:lower())) then
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
    local chars = ws:FindFirstChild("Characters")
    if chars then
        for _, child in ipairs(chars:GetChildren()) do
            local isPlayer = string.find(child.Name:lower(), lp.Name:lower()) ~= nil
            if displayName and string.find(child.Name:lower(), displayName:lower()) then
                isPlayer = true
            end
            if not isPlayer then pcall(function() child:Destroy() end) end
        end
    end
end

-- Auto re-execute marker across hops
local function setupAutoExec()
    if not rs:FindFirstChild("DiamondFarmMarker") then
        local marker = Instance.new("StringValue")
        marker.Name = "DiamondFarmMarker"
        marker.Value = "DiamondFarmScript"
        marker.Parent = rs
    end
    if rs:FindFirstChild("DiamondFarmTeleported") then
        rs:FindFirstChild("DiamondFarmTeleported"):Destroy()
        task.wait(2)
        startFarm()
        return
    end
end
local function prepTeleport()
    local flag = Instance.new("BoolValue")
    flag.Name = "DiamondFarmTeleported"
    flag.Value = true
    flag.Parent = rs
end
local function hopWithAuto()
    prepTeleport()
    webhookSentThisServer = false
    diamondsCollectedThisServer = 0
    collectedDiamonds = {}
    local ok = pcall(hopServer)
    if not ok then pcall(function() tps:Teleport(placeId, lp) end) end
    return true
end

cleanChars()

-- Main farm loop with MaxServerTime auto-hop
function startFarm()
    task.spawn(function()
        local hopCount = 0
        local chestCheck = 0
        local serverStart = tick()

        while true do
            cleanChars()

            if tick() - serverStart > (getgenv().MaxServerTime or 15) then
                if DiamondCountLabel then DiamondCountLabel.Text = "Auto-hopping (timeout)" end
                hopWithAuto()
                serverStart = tick()
                task.wait(2)
                continue
            end

            if isDead() then
                if DiamondCountLabel then DiamondCountLabel.Text = "Dead, hopping..." end
                pcall(sendWebhook)
                hopWithAuto()
                serverStart = tick()
                task.wait(5)
            end

            if lp.Character and hrp then
                local opened = fireChests()
                scanDiamonds()

                chestCheck += 1
                if chestCheck >= 1 then
                    chestCheck = 0
                    if teleportToChest() then
                        if DiamondCountLabel then DiamondCountLabel.Text = "Found chest!" end
                        task.wait(1)
                    end
                end

                hopCount += 1
                if hopCount >= 3 then
                    hopCount = 0
                    task.wait(1)
                    pcall(sendWebhook)
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

-- Retry teleports on failures [6][27]
tps.TeleportInitFailed:Connect(function(player, result, errorMessage)
    if DiamondCountLabel then DiamondCountLabel.Text = "Teleport failed" end
    task.wait(2)
    hopWithAuto()
end)

setupAutoExec()
startFarm()
