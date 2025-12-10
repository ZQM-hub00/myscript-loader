-- loader.lua / FIXED FULL VERSION
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ====== CONFIG URL ======
local configURL = "https://raw.githubusercontent.com/ZQM-hub00/myscript-loader/refs/heads/main/config.json"

-- ====== SAFE HTTP ======
local function SafeGet(url)
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok then
        warn("[⚠] HTTP ERROR :", result)
        return nil
    end
    return result
end

-- ====== OPEN LINK (REAL FUNCTION) ======
local function OpenLink(url)
    if syn then
        syn.open_url(url)
    elseif request then
        request({ Url = url, Method = "GET" })
    elseif setclipboard then
        setclipboard(url)
        print("📋 Copied link:", url)
    else
        print("URL:", url)
    end
end

-- ====== CORNERS ======
local function round(gui, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = gui
end

local function stroke(gui, t)
    local s = Instance.new("UIStroke")
    s.Thickness = t or 2
    s.Color = Color3.fromRGB(200,200,200)
    s.Parent = gui
end

-- ====== DRAG ======
local function makeDraggable(frame)
    local dragging = false
    local dragStart, startPos
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ====== UI ======
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZQM_Interface"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local function makeFrame(titleText)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 320, 0, 240)
    f.Position = UDim2.new(0.5, 0, 0.5, 0)
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.BackgroundColor3 = Color3.fromRGB(18,18,18)
    f.Visible = false
    f.Parent = screenGui
    round(f, 14)
    stroke(f, 2)
    makeDraggable(f)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 34)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(230,230,230)
    title.Text = titleText
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = f

    return f
end

local function makeButton(parent, text, pos)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 280, 0, 42)
    b.Position = pos
    b.BackgroundColor3 = Color3.fromRGB(0,0,0)
    b.TextColor3 = Color3.fromRGB(230,230,230)
    b.Text = text
    b.TextSize = 16
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = false
    b.Parent = parent
    round(b, 10)
    stroke(b, 2)

    return b
end

local function makeClose(parent)
    local x = Instance.new("TextButton")
    x.Size = UDim2.new(0, 30, 0, 30)
    x.Position = UDim2.new(1, -35, 0, 5)
    x.BackgroundColor3 = Color3.fromRGB(0,0,0)
    x.Text = "X"
    x.TextColor3 = Color3.fromRGB(255,255,255)
    x.Font = Enum.Font.GothamBold
    x.TextSize = 16
    round(x, 10)
    stroke(x, 2)
    x.Parent = parent
    x.MouseButton1Click:Connect(function()
        parent.Visible = false
    end)
end

local function makeBack(parent, backTo)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 30, 0, 30)
    b.Position = UDim2.new(0, 5, 1, -35)
    b.BackgroundColor3 = Color3.fromRGB(0,0,0)
    b.Text = "<-"
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    round(b, 10)
    stroke(b, 2)
    b.Parent = parent

    b.MouseButton1Click:Connect(function()
        parent.Visible = false
        backTo.Visible = true
    end)
end

-- ====== MAIN ======
local main = makeFrame("Choose an option")
makeClose(main)

local keylessBtn = makeButton(main, "Keyless 🔑", UDim2.new(0.5,-140,0,70))
local withKeyBtn = makeButton(main, "WithKey 🔒", UDim2.new(0.5,-140,0,130))

-- ====== SUBPAGES ======
local robloxFrame = makeFrame("Continue with Roblox 🎮")
makeBack(robloxFrame, main)
makeClose(robloxFrame)

local discordFrame = makeFrame("Continue with Discord 💬")
makeBack(discordFrame, main)
makeClose(discordFrame)

local robloxBtn = makeButton(robloxFrame, "Open Roblox Link", UDim2.new(0.5,-140,0,80))
local discordBtn = makeButton(discordFrame, "Open Discord Link", UDim2.new(0.5,-140,0,80))

-- ====== BUTTON ACTIONS ======
keylessBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    robloxFrame.Visible = true
end)

withKeyBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    discordFrame.Visible = true
end)

-- ====== LOAD CONFIG ======
local raw = SafeGet(configURL)
if raw then
    local ok, cfg = pcall(function()
        return HttpService:JSONDecode(raw)
    end)
    if ok and typeof(cfg) == "table" then
        robloxBtn.MouseButton1Click:Connect(function()
            OpenLink(cfg.roblox_link)
        end)

        discordBtn.MouseButton1Click:Connect(function()
            OpenLink(cfg.discord_link)
        end)
    else
        warn("⚠ Invalid JSON config")
    end
else
    warn("⚠ Cannot load config.json")
end

-- ====== SHOW MAIN FRAME ======
main.Visible = true
