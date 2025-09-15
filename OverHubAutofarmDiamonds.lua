-- OverHub Autofarm GUI (unchanged visuals)
local Players = game:GetService("Players") -- UI host [22]
local TweenService = game:GetService("TweenService") -- tweens [22]
local UserInputService = game:GetService("UserInputService") -- drag [24]
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService") -- hops [3]
local HttpService = game:GetService("HttpService")

-- Persist loader across teleports (executor-provided)
pcall(function()
    if queue_on_teleport then
        queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/hellattexyss/testfarm/refs/heads/main/OverHubAutofarmDiamonds.lua"))()')
    end
end) -- queue_on_teleport when available in executor [23]

-- Place-specific lobby queue automation (79546208627805)
pcall(function()
    if game.PlaceId == 79546208627805 then
        local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents", 9e9)
        local TeleportEvent = RemoteEvents:WaitForChild("TeleportEvent", 9e9)
        local function TeleportAdd(num)
            local args = {[1] = "Add",[25] = num}
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
end) -- lobby remote cycling isolated to target place [3]

-- Optional tuning
getgenv().WebhookURL = getgenv().WebhookURL or ""
getgenv().MaxServerTime = getgenv().MaxServerTime or 15

-- Player/UI
local lp = Players.LocalPlayer
local PlayerGui = lp:WaitForChild("PlayerGui") -- UI parent [22]

-- Remove old duplicates
for _, n in ipairs({"DiamondFarmGUI","AutoFarmDiamondsGUI"}) do
    local f = PlayerGui:FindFirstChild(n)
    if f then f:Destroy() end
end -- keep one instance [22]

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DiamondFarmGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Card
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 160)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = MainFrame

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(128,0,255)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255,0,128)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0,128,255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20,20,20)),
})
gradient.Rotation = 45
gradient.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

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
ButtonsFrame.Parent = MainFrame

local DiamondCountLabel = Instance.new("TextLabel")
DiamondCountLabel.Size = UDim2.new(1, -20, 0, 30)
DiamondCountLabel.Position = UDim2.new(0, 10, 0, 10)
DiamondCountLabel.BackgroundTransparency = 1
DiamondCountLabel.Text = "Diamonds: 0"
DiamondCountLabel.TextColor3 = Color3.fromRGB(255,255,255)
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
    TweenService:Create(DiscordButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
end)
DiscordButton.MouseLeave:Connect(function()
    TweenService:Create(DiscordButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
end)
DiscordButton.MouseButton1Click:Connect(function()
    local env = getfenv and getfenv() or _G
    local f = (env and env.setclipboard) or _G.setclipboard or _G.toclipboard
    if f and typeof(f) == "function" then pcall(f, "https://discord.gg/pdp65qN3Ck") end
    TweenService:Create(DiscordButton, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true), {Size = UDim2.new(0,170,0,36)}):Play()
end) -- executor-first clipboard path [26]

local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0,280,0,40)}):Play()
        TweenService:Create(DiscordButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1,-90,0,20)}):Play()
        DiamondCountLabel.Visible = false
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0,280,0,160)}):Play()
        TweenService:Create(DiscordButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5,0,0.5,30)}):Play()
        DiamondCountLabel.Visible = true
    end
end)

-- Rotate gradient flair
task.spawn(function()
    while true do
        gradient.Rotation += 1
        task.wait(0.02)
    end
end)

-- Drag (mouse + touch) [24]
local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
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
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- expose UI ref for core
_G.OverHubUI = { Label = DiamondCountLabel }
-- END OF SNIPPET 1
-- Autofarm core + counter + hop + stronghold

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local lp = Players.LocalPlayer
local placeId = game.PlaceId
local takeDiamonds = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RequestTakeDiamonds")
local itemsFolder = Workspace:WaitForChild("Items")

local username = lp.Name
local displayName = lp.DisplayName
local Label = _G.OverHubUI and _G.OverHubUI.Label

local diamondsCollectedThisServer = 0
local webhookSentThisServer = false
local collectedDiamonds = {}

local function getDiamondCount()
    local ok, result = pcall(function()
        local countObj = Players[username].PlayerGui.Interface.DiamondCount.Count
        return tonumber(countObj.Text) or 0
    end)
    return ok and result or 0
end
local function updateDiamondDisplay()
    if Label then Label.Text = "Diamonds: " .. tostring(getDiamondCount()) end
end
local function setupDiamondListener()
    local ok, countObj = pcall(function()
        return Players[username].PlayerGui.Interface.DiamondCount.Count
    end)
    if ok and countObj and countObj:IsA("TextLabel") then
        countObj:GetPropertyChangedSignal("Text"):Connect(updateDiamondDisplay)
        updateDiamondDisplay()
    else
        if Label then Label.Text = "Diamonds: N/A" end
    end
    task.spawn(function()
        while true do
            updateDiamondDisplay()
            task.wait(1)
        end
    end)
end
task.spawn(setupDiamondListener) -- GUI-bound counter [22]

local function sendWebhook()
    if not getgenv().WebhookURL or getgenv().WebhookURL == "" then return end
    if diamondsCollectedThisServer == 0 then return end
    if webhookSentThisServer then return end
    webhookSentThisServer = true

    local json = HttpService:JSONEncode({
        content = string.format(
            "💎 Diamond Collection Report\n👤 Player: %s (@%s)\n🌐 Server ID: ||%s||\n💰 Current Balance: %d\n📊 Collected This Session: %d\n⏰ Time: %s",
            displayName, username, game.JobId, getDiamondCount(), diamondsCollectedThisServer, os.date("%Y-%m-%d %H:%M:%S")
        )
    })
    pcall(function()
        if request then
            request({Url = getgenv().WebhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = json})
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
            for i = 1, 5 do
                pcall(fireproximityprompt, prompt)
                task.wait(0.05)
            end
        end)
    end
    return #chests
end

local function findStrongholdChest()
    local chest = Workspace:FindFirstChild("Stronghold Diamond Chest")
    if chest then return chest.PrimaryPart or chest:FindFirstChildWhichIsA("BasePart") end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and string.find(string.lower(obj.Name), "stronghold") and string.find(string.lower(obj.Name), "chest") then
            return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if (obj:IsA("Model") or obj:IsA("Part")) and string.find(string.lower(obj.Name), "stronghold") then
            return obj:FindFirstChild("PrimaryPart") or obj:FindFirstChildWhichIsA("BasePart")
        end
    end
    return nil
end
local function teleportToChest()
    if not hrp then return false end
    local part = findStrongholdChest()
    if part then
        if Label then Label.Text = "Teleporting to chest..." end
        pcall(function() hrp.CFrame = part.CFrame + Vector3.new(0,5,0) end)
        for _, child in ipairs(part.Parent:GetDescendants()) do
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

local function hopServer()
    if Label then Label.Text = "Finding server..." end
    pcall(sendWebhook)

    local servers = {}
    local ok, result = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
        local response = game:HttpGet(url)
        return HttpService:JSONDecode(response)
    end)
    if ok and result and result.data then
        for _, s in ipairs(result.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                table.insert(servers, s.id)
            end
        end
        if #servers > 0 then
            local target = servers[math.random(1, #servers)]
            TeleportService:TeleportToPlaceInstance(placeId, target, lp) -- consistent with prior flow [2]
            return true
        else
            TeleportService:Teleport(placeId, lp) -- fallback [4]
            return true
        end
    else
        TeleportService:Teleport(placeId, lp)
        return true
    end
end

local function isDead()
    local chars = Workspace:FindFirstChild("Characters")
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
    local chars = Workspace:FindFirstChild("Characters")
    if chars then
        for _, child in ipairs(chars:GetChildren()) do
            local me = string.find(child.Name:lower(), lp.Name:lower()) ~= nil
            if displayName and string.find(child.Name:lower(), displayName:lower()) then me = true end
            if not me then pcall(function() child:Destroy() end) end
        end
    end
end

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
local function prepTeleport()
    local flag = Instance.new("BoolValue")
    flag.Name = "DiamondFarmTeleported"
    flag.Value = true
    flag.Parent = ReplicatedStorage
end
local function hopWithAuto()
    prepTeleport()
    webhookSentThisServer = false
    diamondsCollectedThisServer = 0
    collectedDiamonds = {}
    local ok = pcall(hopServer)
    if not ok then pcall(function() TeleportService:Teleport(placeId, lp) end) end
    return true
end

cleanChars()

function startFarm()
    task.spawn(function()
        local hopCount = 0
        local chestCheck = 0
        local serverStart = tick()

        while true do
            cleanChars()

            if tick() - serverStart > (getgenv().MaxServerTime or 15) then
                if Label then Label.Text = "Auto-hopping (timeout)" end
                hopWithAuto()
                serverStart = tick()
                task.wait(2)
                continue
            end

            if isDead() then
                if Label then Label.Text = "Dead, hopping..." end
                pcall(sendWebhook)
                hopWithAuto()
                serverStart = tick()
                task.wait(5)
            end

            if lp.Character and hrp then
                local _ = fireChests()
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

TeleportService.TeleportInitFailed:Connect(function(player, result, err)
    if Label then Label.Text = "Teleport failed" end
    task.wait(2)
    hopWithAuto()
end) -- basic retry hook [3]

setupAutoExec()
startFarm()
