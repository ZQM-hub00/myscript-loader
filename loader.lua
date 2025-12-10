-- loader.lua / version corrigée & stabilisée
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ====== CONFIG.JSON URL ======
local configURL = "https://raw.githubusercontent.com/ZQM-hub00/myscript-loader/refs/heads/main/config.json"

-- ====== SECURE HTTP GET ======
local function SafeGet(url)
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok then
        warn("⚠️ HTTP ERROR:", result)
        return nil
    end
    return result
end

-- ====== CORNERS ======
local function round(gui, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = gui
end

local function stroke(gui, t, col)
    local s = Instance.new("UIStroke")
    s.Thickness = t or 2
    s.Color = col or Color3.fromRGB(200,200,200)
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = gui
end

-- ====== DRAGGABLE ======
local function makeDraggable(frame)
    frame.Active = true
    local dragging = false
    local dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ====== UI CREATION ======
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Interface"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local function makeFrame(parent, titleRich)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 320, 0, 240)
    f.Position = UDim2.new(0.5, 0, 0.5, 0)
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.BackgroundColor3 = Color3.fromRGB(18,18,18)
    f.Visible = false
    f.Parent = parent
    round(f, 14)
    stroke(f, 2)

    makeDraggable(f)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 34)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(230,230,230)
    title.Text = titleRich
    title.RichText = true
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = f

    return f
end

local function makeClose(parent, onClose)
    local x = Instance.new("TextButton")
    x.Size = UDim2.new(0, 30, 0, 30)
    x.Position = UDim2.new(1, -35, 0, 5)
    x.BackgroundColor3 = Color3.fromRGB(0,0,0)
    x.TextColor3 = Color3.fromRGB(230,230,230)
    x.Text = "X"
    x.TextSize = 16
    x.Font = Enum.Font.GothamBold
    x.AutoButtonColor = false

    round(x, 10)
    stroke(x, 2)

    x.Parent = parent
    x.MouseButton1Click:Connect(function()
        if onClose then onClose() end
    end)
end

local function makeBack(parent, mainFrame, currentFrame)
    local arrow = Instance.new("TextButton")
    arrow.Size = UDim2.new(0, 30, 0, 30)
    arrow.Position = UDim2.new(0, 5, 1, -35)
    arrow.BackgroundColor3 = Color3.fromRGB(0,0,0)
    arrow.TextColor3 = Color3.fromRGB(230,230,230)
    arrow.Text = "<-"
    arrow.TextSize = 16
    arrow.Font = Enum.Font.GothamBold
    arrow.AutoButtonColor = false

    round(arrow, 10)
    stroke(arrow, 2)

    arrow.Parent = parent
    arrow.MouseButton1Click:Connect(function()
        currentFrame.Visible = false
        mainFrame.Visible = true
    end)
end

local function makeButton(parent, text, pos, link, isSecondary)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 280, 0, 42)
    b.Position = pos
    b.BackgroundColor3 = Color3.fromRGB(0,0,0)
    b.TextColor3 = Color3.fromRGB(230,230,230)
    b.Text = text
    b.TextSize = 16
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = false

    round(b, 10)
    stroke(b, 2)

    b:SetAttribute("Link", link or "")
    b.Parent = parent

    local normal = b.Size
    local hover = UDim2.new(0, 290, 0, 46)

    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), {Size = hover}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), {Size = normal}):Play()
    end)

    if isSecondary then
        b.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(b:GetAttribute("Link"))
                local old = b.Text
                b.Text = "✔ Copied 📋"
                task.delay(1.5, function()
                    b.Text = old
                end)
            end
        end)
    end

    return b
end

local function makeSubtitle(frame, text)
    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -20, 0, 20)
    sub.Position = UDim2.new(0, 10, 0, 130)
    sub.BackgroundTransparency = 1
    sub.TextColor3 = Color3.fromRGB(255,255,255)
    sub.Text = text
    sub.TextSize = 13
    sub.Font = Enum.Font.GothamSemibold
    sub.TextXAlignment = Enum.TextXAlignment.Center
    sub.Parent = frame
    stroke(sub, 1)
    return sub
end

-- ====== MAIN UI ======
local mainFrame = makeFrame(screenGui, "Choose an option")
makeClose(mainFrame, function() mainFrame.Visible = false end)

local keylessBtn = makeButton(mainFrame, "Keyless 🔑", UDim2.new(0.5,-140,0,60), "")
local withKeyBtn = makeButton(mainFrame, "WithKey 🔒", UDim2.new(0.5,-140,0,120), "")

local keylessFrame = makeFrame(screenGui, "Continue with <u>Roblox</u> 🎮")
makeClose(keylessFrame, function() keylessFrame.Visible = false end)
makeBack(keylessFrame, mainFrame, keylessFrame)
local keylessAction = makeButton(keylessFrame, "Keyless 🔑", UDim2.new(0.5,-140,0,80), "", true)
local keylessSubtitle = makeSubtitle(keylessFrame, "Fast access with Roblox ⏹️")

local withKeyFrame = makeFrame(screenGui, "Continue with <u>Discord</u> 💬")
makeClose(withKeyFrame, function() withKeyFrame.Visible = false end)
makeBack(withKeyFrame, mainFrame, withKeyFrame)
local withKeyAction = makeButton(withKeyFrame, "WithKey 🔒", UDim2.new(0.5,-140,0,80), "", true)
local withKeySubtitle = makeSubtitle(withKeyFrame, "Community access with Discord 💬")

-- ====== NAVIGATION ======
keylessBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    keylessFrame.Visible = true
end)
withKeyBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    withKeyFrame.Visible = true
end)

-- ====== ANIMATION ======
mainFrame.Visible = true
mainFrame.BackgroundTransparency = 1
mainFrame.Size = UDim2.new(0,0,0,0)

TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0,320,0,240)}):Play()
TweenService:Create(mainFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()

-- ====== LOAD CONFIG ======
local raw = SafeGet(configURL)
if raw then
    local ok, cfg = pcall(function()
        return HttpService:JSONDecode(raw)
    end)
    if ok and typeof(cfg) == "table" then
        keylessAction:SetAttribute("Link", cfg.roblox_link or "")
        withKeyAction:SetAttribute("Link", cfg.discord_link or "")
        keylessSubtitle.Text = cfg.roblox_subtitle or "Fast access with Roblox ⏹️"
        withKeySubtitle.Text = cfg.discord_subtitle or "Community access with Discord 💬"
    else
        warn("⚠️ JSON ERROR dans config.json")
    end
else
    warn("⚠️ Impossible de charger config.json")
end

