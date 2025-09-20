-- Aureon UI Library
-- Based on the provided Sirius code, fully reconstructed and organized.
-- Centered GUI with proper AnchorPoint and Position settings.
-- Added drag functionality for the main GUI frame.
-- Page transition animations: old page slides out left, new page slides in from right.
-- Dynamic time update using os.date for local timezone.
-- All UI elements from the provided document are included.
-- Library can be loaded via loadstring from GitHub.
-- URL: https://raw.githubusercontent.com/V1trixz/AureonLib/refs/heads/main/AureonLib.lua

local Aureon = {}

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Helper for tweens
local function createTween(instance, tweenInfo, properties)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Drag functionality
local function makeDraggable(frame)
    local dragging = false
    local dragInput, dragStart, startPos

    local function updateInput(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateInput(input)
        end
    end)
end

-- Main function to create the UI
function Aureon:CreateUI()
    local player = Players.LocalPlayer
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Aureon"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false

    -- Main frame (centered and draggable)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 600, 0, 400)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.Parent = screenGui

    local UICorner = Instance.new("UICorner")
    UICorner.Parent = mainFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Parent = mainFrame

    -- Make main frame draggable
    makeDraggable(mainFrame)

    -- SmartBar (bottom navigation)
    local smartBar = self:CreateSmartBar(mainFrame)

    -- Pages container
    local pages = Instance.new("Frame")
    pages.Name = "Pages"
    pages.Size = UDim2.new(1, 0, 1, -70)
    pages.Position = UDim2.new(0, 0, 0, 0)
    pages.BackgroundTransparency = 1
    pages.Parent = mainFrame

    -- Create pages
    local homePage = self:CreateHomePage(pages)
    local characterPage = self:CreateCharacterPage(pages)
    local scriptsPage = self:CreateScriptsPage(pages)
    local playerlistPage = self:CreatePlayerlistPage(pages)
    local musicPage = self:CreateMusicPage(pages)
    local settingsPage = self:CreateSettingsPage(pages)
    local notifications = self:CreateNotifications(pages)
    local customScriptPrompt = self:CreateCustomScriptPrompt(pages)

    -- Hide all pages initially
    local allPages = {homePage, characterPage, scriptsPage, playerlistPage, musicPage, settingsPage, notifications, customScriptPrompt}
    for _, page in ipairs(allPages) do
        page.Visible = false
        page.Position = UDim2.new(1, 0, 0, 0)
    end

    -- Current page
    local currentPage = nil

    -- Switch page with animation
    local function switchPage(newPage)
        if currentPage == newPage then return end

        if currentPage then
            createTween(currentPage, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(-1, 0, 0, 0)})
            wait(0.5)
            currentPage.Visible = false
        end

        newPage.Position = UDim2.new(1, 0, 0, 0)
        newPage.Visible = true
        createTween(newPage, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(0, 0, 0, 0)})

        currentPage = newPage
    end

    -- Connect buttons to pages
    smartBar.Buttons.Home.Interact.MouseButton1Click:Connect(function() switchPage(homePage) end)
    smartBar.Buttons.Character.Interact.MouseButton1Click:Connect(function() switchPage(characterPage) end)
    smartBar.Buttons.Scripts.Interact.MouseButton1Click:Connect(function() switchPage(scriptsPage) end)
    smartBar.Buttons.Playerlist.Interact.MouseButton1Click:Connect(function() switchPage(playerlistPage) end)
    smartBar.Buttons.Music.Interact.MouseButton1Click:Connect(function() switchPage(musicPage) end)
    smartBar.Buttons.Settings.Interact.MouseButton1Click:Connect(function() switchPage(settingsPage) end)

    -- Show home by default
    switchPage(homePage)

    -- Setup time
    self:SetupTime(smartBar.Time)

    -- Animate main frame entry
    mainFrame.Position = UDim2.new(0.5, 0, 1.5, 0)
    createTween(mainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.5, 0)})

    return screenGui
end

-- Create SmartBar
function Aureon:CreateSmartBar(parent)
    local SmartBar = Instance.new("Frame")
    SmartBar.Name = "SmartBar"
    SmartBar.Size = UDim2.new(1, 0, 0, 70)
    SmartBar.Position = UDim2.new(0, 0, 1, -70)
    SmartBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    SmartBar.Parent = parent

    local UICorner = Instance.new("UICorner")
    UICorner.Parent = SmartBar

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Parent = SmartBar

    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 70, 1, 60)
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://3523728077"
    Shadow.Parent = SmartBar

    local Time = Instance.new("TextLabel")
    Time.Name = "Time"
    Time.Size = UDim2.new(0, 60, 0, 19)
    Time.Position = UDim2.new(0.072, 0, 0.5, 0)
    Time.BackgroundTransparency = 1
    Time.TextColor3 = Color3.fromRGB(255, 255, 255)
    Time.Text = os.date("%H:%M")
    Time.Parent = SmartBar

    local Buttons = Instance.new("Frame")
    Buttons.Name = "Buttons"
    Buttons.Size = UDim2.new(1, 0, 1, 0)
    Buttons.Position = UDim2.new(0.5, 0, 0.5, 0)
    Buttons.BackgroundTransparency = 1
    Buttons.Parent = SmartBar

    self:CreateNavButton(Buttons, "Home", UDim2.new(0.175, 0, 0.5, 0), "rbxassetid://9080449299")
    self:CreateNavButton(Buttons, "Character", UDim2.new(0.25, 0, 0.5, 0), "rbxassetid://9080470458")
    self:CreateNavButton(Buttons, "Scripts", UDim2.new(0.325, 0, 0.5, 0), "rbxassetid://9080478424")
    self:CreateNavButton(Buttons, "Playerlist", UDim2.new(0.4, 0, 0.5, 0), "rbxassetid://9080475789")
    self:CreateNavButton(Buttons, "Music", UDim2.new(0.475, 0, 0.5, 0), "rbxassetid://9080473484")
    self:CreateNavButton(Buttons, "Settings", UDim2.new(0.94, 0, 0.5, 0), "rbxassetid://3605022185")

    return SmartBar
end

-- Create navigation button
function Aureon:CreateNavButton(parent, name, position, image)
    local Frame = Instance.new("Frame")
    Frame.Name = name
    Frame.Size = UDim2.new(0, 36, 0, 36)
    Frame.Position = position
    Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parent

    local UICorner = Instance.new("UICorner")
    UICorner.Parent = Frame

    local Icon = Instance.new("ImageButton")
    Icon.Name = "Icon"
    Icon.Size = UDim2.new(0, 24, 0, 24)
    Icon.Position = UDim2.new(0.5, 0, 0.5, 0)
    Icon.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
    Icon.BackgroundTransparency = 1
    Icon.Image = image
    Icon.Parent = Frame

    local UIStroke = Instance.new("UIStroke")
    local UIGradient = Instance.new("UIGradient")
    UIGradient.Parent = UIStroke
    UIStroke.Parent = Frame

    local UIGradientFrame = Instance.new("UIGradient")
    UIGradientFrame.Parent = Frame

    local Interact = Instance.new("TextButton")
    Interact.Name = "Interact"
    Interact.Size = UDim2.new(1, 0, 1, 0)
    Interact.Position = UDim2.new(0.5, 0, 0.5, 0)
    Interact.BackgroundTransparency = 1
    Interact.Text = ""
    Interact.Parent = Frame

    -- Hover animation
    Interact.MouseEnter:Connect(function()
        createTween(Icon, TweenInfo.new(0.2), {ImageTransparency = 0.2})
    end)
    Interact.MouseLeave:Connect(function()
        createTween(Icon, TweenInfo.new(0.2), {ImageTransparency = 0})
    end)

    return Frame
end

-- Setup time update
function Aureon:SetupTime(timeLabel)
    local function update()
        timeLabel.Text = os.date("%H:%M")
    end
    update()
    RunService.Heartbeat:Connect(function()
        if os.time() % 60 == 0 then
            update()
        end
    end)
end

-- Create Home Page
function Aureon:CreateHomePage(parent)
    local Home = Instance.new("Frame")
    Home.Name = "HomePage"
    Home.Size = UDim2.new(1, 0, 1, 0)
    Home.BackgroundTransparency = 1
    Home.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 0.1, 0)
    Label.Position = UDim2.new(0.25, 0, 0.4, 0)
    Label.BackgroundTransparency = 1
    Label.Text = "Welcome to Aureon Home"
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Parent = Home

    return Home
end

-- Create Character Page
function Aureon:CreateCharacterPage(parent)
    local Character = Instance.new("Frame")
    Character.Name = "CharacterPage"
    Character.Size = UDim2.new(1, 0, 1, 0)
    Character.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Character.BackgroundTransparency = 0.2
    Character.Parent = parent

    local UICorner = Instance.new("UICorner")
    UICorner.Parent = Character

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 180, 0, 18)
    Title.Position = UDim2.new(0.238, 0, 0.102, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Character"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Parent = Character

    return Character
end

-- Create Scripts Page
function Aureon:CreateScriptsPage(parent)
    local Scripts = Instance.new("Frame")
    Scripts.Name = "ScriptsPage"
    Scripts.Size = UDim2.new(1, 0, 1, 0)
    Scripts.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Scripts.BackgroundTransparency = 0.2
    Scripts.Parent = parent

    local UICorner = Instance.new("UICorner")
    UICorner.Parent = Scripts

    local UIGradient = Instance.new("UIGradient")
    UIGradient.Parent = Scripts

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0, 189, 0, 17)
    Title.Position = UDim2.new(0.141, 0, 0.055, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Script Search"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Parent = Scripts

    local Icon = Instance.new("ImageButton")
    Icon.Name = "Icon"
    Icon.Size = UDim2.new(0, 24, 0, 24)
    Icon.Position = UDim2.new(0.116, 0, 0.075, 0)
    Icon.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
    Icon.Image = "rbxassetid://9080478424"
    Icon.Parent = Scripts

    local Search = Instance.new("Frame")
    Search.Name = "Search"
    Search.Size = UDim2.new(0, 400, 0, 30)
    Search.Position = UDim2.new(0.155, 0, 0.15, 0)
    Search.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Search.Parent = Scripts

    local UICornerSearch = Instance.new("UICorner")
    UICornerSearch.Parent = Search

    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(1, -30, 1, 0)
    TextBox.Position = UDim2.new(0, 30, 0, 0)
    TextBox.BackgroundTransparency = 1
    TextBox.Text = ""
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.Parent = Search

    local List = Instance.new("ScrollingFrame")
    List.Name = "List"
    List.Size = UDim2.new(1, 0, 0.7, 0)
    List.Position = UDim2.new(0, 0, 0.2, 0)
    List.BackgroundTransparency = 1
    List.Parent = Scripts

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = List

    local Template = Instance.new("Frame")
    Template.Name = "Template"
    Template.Size = UDim2.new(1, 0, 0, 100)
    Template.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Template.Parent = List

    local UICornerTemplate = Instance.new("UICorner")
    UICornerTemplate.Parent = Template

    local ScriptTitle = Instance.new("TextLabel")
    ScriptTitle.Name = "ScriptTitle"
    ScriptTitle.Size = UDim2.new(0, 405, 0, 17)
    ScriptTitle.Position = UDim2.new(0.037, 0, 0.161, 0)
    ScriptTitle.BackgroundTransparency = 1
    ScriptTitle.Text = "scriptname"
    ScriptTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScriptTitle.Parent = Template

    local ScriptDescription = Instance.new("TextLabel")
    ScriptDescription.Name = "ScriptDescription"
    ScriptDescription.Size = UDim2.new(0, 405, 0, 50)
    ScriptDescription.Position = UDim2.new(0.037, 0, 0.282, 0)
    ScriptDescription.BackgroundTransparency = 1
    ScriptDescription.Text = "description"
    ScriptDescription.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScriptDescription.Parent = Template

    local ScriptAuthor = Instance.new("TextLabel")
    ScriptAuthor.Name = "ScriptAuthor"
    ScriptAuthor.Size = UDim2.new(0, 405, 0, 13)
    ScriptAuthor.Position = UDim2.new(0.037, 0, 0.855, 0)
    ScriptAuthor.BackgroundTransparency = 1
    ScriptAuthor.Text = "uploaded by unknown"
    ScriptAuthor.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScriptAuthor.Parent = Template

    local Tags = Instance.new("Frame")
    Tags.Name = "Tags"
    Tags.Size = UDim2.new(0, 386, 0, 30)
    Tags.Position = UDim2.new(0.284, 0, 0.041, 0)
    Tags.BackgroundTransparency = 1
    Tags.Parent = Template

    local UIListLayoutTags = Instance.new("UIListLayout")
    UIListLayoutTags.Parent = Tags

    local Verified = Instance.new("Frame")
    Verified.Name = "Verified"
    Verified.Size = UDim2.new(0, 140, 1, 0)
    Verified.Position = UDim2.new(0.269, 0, 0, 0)
    Verified.BackgroundColor3 = Color3.fromRGB(0, 141, 211)
    Verified.Parent = Tags

    local UICornerVerified = Instance.new("UICorner")
    UICornerVerified.Parent = Verified

    local TitleVerified = Instance.new("TextLabel")
    TitleVerified.Size = UDim2.new(0.8, 0, 0, 15)
    TitleVerified.Position = UDim2.new(0.5, 0, 0.5, 0)
    TitleVerified.BackgroundTransparency = 1
    TitleVerified.Text = "Verified Creator"
    TitleVerified.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleVerified.Parent = Verified

    local Execute = Instance.new("TextButton")
    Execute.Name = "Execute"
    Execute.Size = UDim2.new(0, 74, 0, 36)
    Execute.Position = UDim2.new(0.912, 0, 0.845, 0)
    Execute.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    Execute.Text = "Run"
    Execute.TextColor3 = Color3.fromRGB(255, 255, 255)
    Execute.Parent = Template

    local UICornerExecute = Instance.new("UICorner")
    UICornerExecute.Parent = Execute

    Execute.MouseButton1Click:Connect(function()
        print("Execute script: " .. ScriptTitle.Text)
    end)

    local NoScriptsTitle = Instance.new("TextLabel")
    NoScriptsTitle.Name = "NoScriptsTitle"
    NoScriptsTitle.Size = UDim2.new(0, 195, 0, 17)
    NoScriptsTitle.Position = UDim2.new(0.5, 0, 0.483, 0)
    NoScriptsTitle.BackgroundTransparency = 1
    NoScriptsTitle.Text = "No Scripts Found"
    NoScriptsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    NoScriptsTitle.Parent = Scripts

    local NoScriptsDesc = Instance.new("TextLabel")
    NoScriptsDesc.Name = "NoScriptsDesc"
    NoScriptsDesc.Size = UDim2.new(0, 355, 0, 15)
    NoScriptsDesc.Position = UDim2.new(0.5, 0, 0.515, 0)
    NoScriptsDesc.BackgroundTransparency = 1
    NoScriptsDesc.Text = "Try searching with a different query"
    NoScriptsDesc.TextColor3 = Color3.fromRGB(255, 255, 255)
    NoScriptsDesc.Parent = Scripts

    return Scripts
end

-- Create Playerlist Page
function Aureon:CreatePlayerlistPage(parent)
    local Playerlist = Instance.new("Frame")
    Playerlist.Name = "PlayerlistPage"
    Playerlist.Size = UDim2.new(1, 0, 1, 0)
    Playerlist.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Playerlist.BackgroundTransparency = 0.2
    Playerlist.Parent = parent

    local UICorner = Instance.new("UICorner")
    UICorner.Parent = Playerlist

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 0.1, 0)
    Label.Position = UDim2.new(0.25, 0, 0.4, 0)
    Label.BackgroundTransparency = 1
    Label.Text = "Playerlist"
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Parent = Playerlist

    return Playerlist
end

-- Create Music Page
function Aureon:CreateMusicPage(parent)
    local Music = Instance.new("Frame")
    Music.Name = "MusicPage"
    Music.Size = UDim2.new(0, 300, 0, 379)
    Music.Position = UDim2.new(0.5, 0, 0.5, 0)
    Music.AnchorPoint = Vector2.new(0.5, 0.5)
    Music.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Music.Parent = parent

    local UICorner = Instance.new("UICorner")
    UICorner.Parent = Music

    local UIGradient = Instance.new("UIGradient")
    UIGradient.Parent = Music

    local UIStroke = Instance.new("UIStroke")
    local UIGradientStroke = Instance.new("UIGradient")
    UIGradientStroke.Parent = UIStroke
    UIStroke.Parent = Music

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0, 144, 0, 17)
    Title.Position = UDim2.new(0.172, 0, 0.055, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Music"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Parent = Music

    local Icon = Instance.new("ImageButton")
    Icon.Name = "Icon"
    Icon.Size = UDim2.new(0, 24, 0, 24)
    Icon.Position = UDim2.new(0.117, 0, 0.075, 0)
    Icon.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
    Icon.Image = "rbxassetid://9080473484"
    Icon.Parent = Music

    local Queue = Instance.new("Frame")
    Queue.Name = "Queue"
    Queue.Size = UDim2.new(0, 254, 0, 187)
    Queue.Position = UDim2.new(0.077, 0, 0.319, 0)
    Queue.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    Queue.Parent = Music

    local UICornerQueue = Instance.new("UICorner")
    UICornerQueue.Parent = Queue

    local List = Instance.new("ScrollingFrame")
    List.Name = "List"
    List.Size = UDim2.new(1, 0, 1, 0)
    List.BackgroundTransparency = 1
    List.Parent = Queue

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = List

    local Template = Instance.new("Frame")
    Template.Name = "Template"
    Template.Size = UDim2.new(0, 254, 0, 40)
    Template.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Template.Parent = List

    local UICornerTemplate = Instance.new("UICorner")
    UICornerTemplate.Parent = Template

    local FileName = Instance.new("TextLabel")
    FileName.Name = "FileName"
    FileName.Size = UDim2.new(0, 186, 0, 15)
    FileName.Position = UDim2.new(0.055, 0, 0.3, 0)
    FileName.BackgroundTransparency = 1
    FileName.Text = "songname"
    FileName.TextColor3 = Color3.fromRGB(255, 255, 255)
    FileName.Parent = Template

    local Duration = Instance.new("TextLabel")
    Duration.Name = "Duration"
    Duration.Size = UDim2.new(0, 55, 0, 15)
    Duration.Position = UDim2.new(0.729, 0, 0.5, 0)
    Duration.BackgroundTransparency = 1
    Duration.Text = "2:41"
    Duration.TextColor3 = Color3.fromRGB(255, 255, 255)
    Duration.Parent = Template

    local Close = Instance.new("ImageButton")
    Close.Name = "Close"
    Close.Size = UDim2.new(0, 21, 0, 21)
    Close.Position = UDim2.new(0.856, 0, 0.5, 0)
    Close.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
    Close.Image = "rbxassetid://3926305904"
    Close.Parent = Template

    local QueueTitle = Instance.new("TextLabel")
    QueueTitle.Name = "QueueTitle"
    QueueTitle.Size = UDim2.new(0, 144, 0, 12)
    QueueTitle.Position = UDim2.new(0.007, 0, -0.073, 0)
    QueueTitle.BackgroundTransparency = 1
    QueueTitle.Text = "QUEUE"
    QueueTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    QueueTitle.Parent = Queue

    local Add = Instance.new("Frame")
    Add.Name = "Add"
    Add.Size = UDim2.new(0, 32, 0, 32)
    Add.Position = UDim2.new(0.817, 0, 0.15, 0)
    Add.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Add.Parent = Music

    local UICornerAdd = Instance.new("UICorner")
    UICornerAdd.Parent = Add

    local InteractAdd = Instance.new("TextButton")
    InteractAdd.Size = UDim2.new(1, 0, 1, 0)
    InteractAdd.BackgroundTransparency = 1
    InteractAdd.Text = ""
    InteractAdd.Parent = Add

    local IconAdd = Instance.new("ImageLabel")
    IconAdd.Size = UDim2.new(0, 24, 0, 24)
    IconAdd.Position = UDim2.new(0.5, 0, 0.5, 0)
    IconAdd.BackgroundTransparency = 1
    IconAdd.Image = "rbxassetid://3944675151"
    IconAdd.Parent = Add

    local Menu = Instance.new("Frame")
    Menu.Name = "Menu"
    Menu.Size = UDim2.new(0, 254, 0, 34)
    Menu.Position = UDim2.new(0.5, 0, 0.88, 0)
    Menu.BackgroundTransparency = 1
    Menu.Parent = Music

    local TogglePlaying = Instance.new("ImageButton")
    TogglePlaying.Name = "TogglePlaying"
    TogglePlaying.Size = UDim2.new(0, 25, 0, 25)
    TogglePlaying.Position = UDim2.new(0.5, 0, 0.5, 0)
    TogglePlaying.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
    TogglePlaying.Image = "rbxassetid://3926307971"
    TogglePlaying.Parent = Menu

    local Next = Instance.new("ImageButton")
    Next.Name = "Next"
    Next.Size = UDim2.new(0, 25, 0, 25)
    Next.Position = UDim2.new(0.625, 0, 0.5, 0)
    Next.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
    Next.Image = "rbxassetid://3926307971"
    Next.Parent = Menu

    return Music
end

-- Create Settings Page
function Aureon:CreateSettingsPage(parent)
    local Settings = Instance.new("Frame")
    Settings.Name = "SettingsPage"
    Settings.Size = UDim2.new(1, 0, 1, 0)
    Settings.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Settings.BackgroundTransparency = 0.2
    Settings.Parent = parent

    local UICorner = Instance.new("UICorner")
    UICorner.Parent = Settings

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 239, 0, 20)
    Title.Position = UDim2.new(0.091, 0, 0.057, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Detections"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Parent = Settings

    local Shadow = Instance.new("ImageLabel")
    Shadow.Size = UDim2.new(0, 685, 0, 623)
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://3523728077"
    Shadow.Parent = Settings

    local SettingTypes = Instance.new("Frame")
    SettingTypes.Name = "SettingTypes"
    SettingTypes.Size = UDim2.new(0, 613, 0, 287)
    SettingTypes.Position = UDim2.new(0, 0, 0.224, 0)
    SettingTypes.BackgroundTransparency = 1
    SettingTypes.Parent = Settings

    local UIGridLayout = Instance.new("UIGridLayout")
    UIGridLayout.Parent = SettingTypes

    local Template = Instance.new("Frame")
    Template.Name = "Template"
    Template.Size = UDim2.new(0, 100, 0, 100)
    Template.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Template.Parent = SettingTypes

    local UICornerTemplate = Instance.new("UICorner")
    UICornerTemplate.Parent = Template

    local UIStrokeTemplate = Instance.new("UIStroke")
    local UIGradientTemplate = Instance.new("UIGradient")
    UIGradientTemplate.Parent = UIStrokeTemplate
    UIStrokeTemplate.Parent = Template

    local UIGradientFrame = Instance.new("UIGradient")
    UIGradientFrame.Parent = Template

    local TitleTemplate = Instance.new("TextLabel")
    TitleTemplate.Size = UDim2.new(0, 133, 0, 17)
    TitleTemplate.Position = UDim2.new(0.183, 0, 0.74, 0)
    TitleTemplate.BackgroundTransparency = 1
    TitleTemplate.Text = "GENERAL"
    TitleTemplate.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleTemplate.Parent = Template

    local ShadowTemplate = Instance.new("ImageLabel")
    ShadowTemplate.Size = UDim2.new(0, 205, 0, 179)
    ShadowTemplate.Position = UDim2.new(0.5, 0, 0.49, 0)
    ShadowTemplate.BackgroundTransparency = 1
    ShadowTemplate.Image = "rbxassetid://3523728077"
    ShadowTemplate.Parent = Template

    local InteractTemplate = Instance.new("TextButton")
    InteractTemplate.Size = UDim2.new(1, 0, 1, 0)
    InteractTemplate.Position = UDim2.new(0.5, 0, 0.5, 0)
    InteractTemplate.BackgroundTransparency = 1
    InteractTemplate.Text = ""
    InteractTemplate.Parent = Template

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(0, 282, 0, 30)
    Subtitle.Position = UDim2.new(0.045, 0, 0.112, 0)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "The basic and essential settings that you can quickly modify to tweak your experience"
    Subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    Subtitle.Parent = Settings

    local Back = Instance.new("ImageButton")
    Back.Name = "Back"
    Back.Size = UDim2.new(0, 25, 0, 25)
    Back.Position = UDim2.new(0.041, 0, 0.052, 0)
    Back.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
    Back.Image = "rbxassetid://3926305904"
    Back.Parent = Settings

    local SettingLists = Instance.new("Frame")
    SettingLists.Name = "SettingLists"
    SettingLists.Size = UDim2.new(0, 613, 0, 287)
    SettingLists.Position = UDim2.new(0, 0, 0.224, 0)
    SettingLists.BackgroundTransparency = 1
    SettingLists.Parent = Settings

    local UIPageLayout = Instance.new("UIPageLayout")
    UIPageLayout.Parent = SettingLists

    local TemplatePage = Instance.new("ScrollingFrame")
    TemplatePage.Name = "Template"
    TemplatePage.Size = UDim2.new(1, 0, 1, 0)
    TemplatePage.BackgroundTransparency = 1
    TemplatePage.Parent = SettingLists

    local SwitchTemplate = Instance.new("Frame")
    SwitchTemplate.Name = "SwitchTemplate"
    SwitchTemplate.Size = UDim2.new(0, 558, 0, 40)
    SwitchTemplate.Position = UDim2.new(0.047, 0, 0, 0)
    SwitchTemplate.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    SwitchTemplate.Parent = TemplatePage

    local UICornerSwitch = Instance.new("UICorner")
    UICornerSwitch.Parent = SwitchTemplate

    local TitleSwitch = Instance.new("TextLabel")
    TitleSwitch.Size = UDim2.new(0, 333, 0, 16)
    TitleSwitch.Position = UDim2.new(0, 18, 0, 12)
    TitleSwitch.BackgroundTransparency = 1
    TitleSwitch.Text = "Switch"
    TitleSwitch.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleSwitch.Parent = SwitchTemplate

    local UIStrokeSwitch = Instance.new("UIStroke")
    UIStrokeSwitch.Parent = SwitchTemplate

    local Switch = Instance.new("Frame")
    Switch.Size = UDim2.new(0, 43, 0, 21)
    Switch.Position = UDim2.new(1, -12, 0.5, 0)
    Switch.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Switch.Parent = SwitchTemplate

    local UICornerSwitchInner = Instance.new("UICorner")
    UICornerSwitchInner.Parent = Switch

    local UIStrokeSwitchInner = Instance.new("UIStroke")
    UIStrokeSwitchInner.Parent = Switch

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 17, 0, 17)
    Indicator.Position = UDim2.new(1, -40, 0.5, 0)
    Indicator.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
    Indicator.Parent = Switch

    local UICornerIndicator = Instance.new("UICorner")
    UICornerIndicator.Parent = Indicator

    local UIStrokeIndicator = Instance.new("UIStroke")
    UIStrokeIndicator.Parent = Indicator

    local InteractSwitch = Instance.new("TextButton")
    InteractSwitch.Size = UDim2.new(0.369, 0, 1, 0)
    InteractSwitch.Position = UDim2.new(0.815, 0, 0.5, 0)
    InteractSwitch.BackgroundTransparency = 1
    InteractSwitch.Text = ""
    InteractSwitch.Parent = SwitchTemplate

    local DescriptionSwitch = Instance.new("TextLabel")
    DescriptionSwitch.Size = UDim2.new(0, 333, 0, 57)
    DescriptionSwitch.Position = UDim2.new(0, 18, 0, 30)
    DescriptionSwitch.BackgroundTransparency = 1
    DescriptionSwitch.Text = "Button"
    DescriptionSwitch.TextColor3 = Color3.fromRGB(255, 255, 255)
    DescriptionSwitch.Parent = SwitchTemplate

    local LicenseDisplay = Instance.new("TextLabel")
    LicenseDisplay.Size = UDim2.new(0, 333, 0, 12)
    LicenseDisplay.Position = UDim2.new(0, 18, 0, 13)
    LicenseDisplay.BackgroundTransparency = 1
    LicenseDisplay.Text = "PRO FEATURE"
    LicenseDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
    LicenseDisplay.Parent = SwitchTemplate

    local UIListLayoutPage = Instance.new("UIListLayout")
    UIListLayoutPage.Parent = TemplatePage

    local Placeholder = Instance.new("Frame")
    Placeholder.Size = UDim2.new(0, 0, 0, 0)
    Placeholder.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Placeholder.Parent = TemplatePage

    return Settings
end

-- Create Notifications
function Aureon:CreateNotifications(parent)
    local Notifications = Instance.new("Frame")
    Notifications.Name = "Notifications"
    Notifications.Size = UDim2.new(0, 339, 0, 820)
    Notifications.Position = UDim2.new(1, -35, 0, 50)
    Notifications.BackgroundTransparency = 1
    Notifications.Parent = parent

    local Template = Instance.new("Frame")
    Template.Name = "Template"
    Template.Size = UDim2.new(0, 320, 0, 400)
    Template.Position = UDim2.new(0.5, 0, 0, 9)
    Template.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Template.Parent = Notifications

    local UICorner = Instance.new("UICorner")
    UICorner.Parent = Template

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 233, 0, 14)
    Title.Position = UDim2.new(0.543, 0, 0, 15)
    Title.BackgroundTransparency = 1
    Title.Text = "Moderator Joined"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Parent = Template

    local Description = Instance.new("TextLabel")
    Description.Size = UDim2.new(0, 241, 0, 350)
    Description.Position = UDim2.new(0.556, 0, 0.5, 7)
    Description.BackgroundTransparency = 1
    Description.Text = "We've turned off any features you were using that may increase detection..."
    Description.TextColor3 = Color3.fromRGB(255, 255, 255)
    Description.Parent = Template

    local Icon = Instance.new("ImageButton")
    Icon.Size = UDim2.new(0, 24, 0, 24)
    Icon.Position = UDim2.new(0, 17, 0.5, 0)
    Icon.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
    Icon.Image = "rbxassetid://14670760191"
    Icon.Parent = Template

    local BlurModule = Instance.new("Frame")
    BlurModule.Size = UDim2.new(1, -21, 1, -21)
    BlurModule.Position = UDim2.new(0.5, 0, 0.5, 0)
    BlurModule.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BlurModule.BackgroundTransparency = 0.8
    BlurModule.Parent = Template

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Parent = Template

    local Time = Instance.new("TextLabel")
    Time.Size = UDim2.new(0, 41, 0, 17)
    Time.Position = UDim2.new(1, -10, 0, 15)
    Time.BackgroundTransparency = 1
    Time.Text = "now"
    Time.TextColor3 = Color3.fromRGB(255, 255, 255)
    Time.Parent = Template

    local Interact = Instance.new("TextButton")
    Interact.Size = UDim2.new(1, 0, 1, 0)
    Interact.Position = UDim2.new(0.5, 0, 0.5, 0)
    Interact.BackgroundTransparency = 1
    Interact.Text = ""
    Interact.Parent = Template

    return Notifications
end

-- Create CustomScriptPrompt
function Aureon:CreateCustomScriptPrompt(parent)
    local CustomScriptPrompt = Instance.new("Frame")
    CustomScriptPrompt.Name = "CustomScriptPrompt"
    CustomScriptPrompt.Size = UDim2.new(0, 310, 0, 315)
    CustomScriptPrompt.Position = UDim2.new(0.5, 0, 0.5, 0)
    CustomScriptPrompt.AnchorPoint = Vector2.new(0.5, 0.5)
    CustomScriptPrompt.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    CustomScriptPrompt.Parent = parent

    local UICorner = Instance.new("UICorner")
    UICorner.Parent = CustomScriptPrompt

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 197, 0, 17)
    Title.Position = UDim2.new(0.06, 0, 0.068, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Import Script"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Parent = CustomScriptPrompt

    local Close = Instance.new("ImageButton")
    Close.Size = UDim2.new(0, 18, 0, 18)
    Close.Position = UDim2.new(1, -15, 0, 15)
    Close.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
    Close.Image = "rbxassetid://3926305904"
    Close.Parent = CustomScriptPrompt

    Close.MouseButton1Click:Connect(function()
        CustomScriptPrompt.Visible = false
    end)

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(0, 232, 0, 29)
    Subtitle.Position = UDim2.new(0.06, 0, 0.123, 0)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Import your own script and loadstring for Aureon to use."
    Subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    Subtitle.Parent = CustomScriptPrompt

    local UIGradient = Instance.new("UIGradient")
    UIGradient.Parent = CustomScriptPrompt

    local IDBox = Instance.new("Frame")
    IDBox.Name = "IDBox"
    IDBox.Size = UDim2.new(0, 232, 0, 30)
    IDBox.Position = UDim2.new(0.057, 0, 0.304, 0)
    IDBox.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    IDBox.Parent = CustomScriptPrompt

    local UICornerID = Instance.new("UICorner")
    UICornerID.Parent = IDBox

    local IDTextBox = Instance.new("TextBox")
    IDTextBox.Name = "IDTextBox"
    IDTextBox.Size = UDim2.new(0, 205, 0, 30)
    IDTextBox.Position = UDim2.new(0.049, 0, 0, 0)
    IDTextBox.BackgroundTransparency = 1
    IDTextBox.Text = ""
    IDTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    IDTextBox.Parent = IDBox

    local DescBox = Instance.new("Frame")
    DescBox.Name = "DescBox"
    DescBox.Size = UDim2.new(0, 232, 0, 67)
    DescBox.Position = UDim2.new(0.057, 0, 0.419, 0)
    DescBox.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    DescBox.Parent = CustomScriptPrompt

    local UICornerDesc = Instance.new("UICorner")
    UICornerDesc.Parent = DescBox

    local DescTextBox = Instance.new("TextBox")
    DescTextBox.Name = "DescTextBox"
    DescTextBox.Size = UDim2.new(0, 209, 0, 55)
    DescTextBox.Position = UDim2.new(0.049, 0, 0.127, 0)
    DescTextBox.BackgroundTransparency = 1
    DescTextBox.Text = ""
    DescTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    DescTextBox.Parent = DescBox

    local ScriptBox = Instance.new("Frame")
    ScriptBox.Name = "ScriptBox"
    ScriptBox.Size = UDim2.new(0, 232, 0, 30)
    ScriptBox.Position = UDim2.new(0.057, 0, 0.65, 0)
    ScriptBox.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    ScriptBox.Parent = CustomScriptPrompt

    local UICornerScript = Instance.new("UICorner")
    UICornerScript.Parent = ScriptBox

    local ScriptTextBox = Instance.new("TextBox")
    ScriptTextBox.Name = "ScriptTextBox"
    ScriptTextBox.Size = UDim2.new(0, 205, 0, 30)
    ScriptTextBox.Position = UDim2.new(0.049, 0, 0, 0)
    ScriptTextBox.BackgroundTransparency = 1
    ScriptTextBox.Text = ""
    ScriptTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScriptTextBox.Parent = ScriptBox

    local Submit = Instance.new("TextButton")
    Submit.Name = "Submit"
    Submit.Size = UDim2.new(0, 90, 0, 33)
    Submit.Position = UDim2.new(0.675, 0, 0.864, 0)
    Submit.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    Submit.Text = "Submit"
    Submit.TextColor3 = Color3.fromRGB(255, 255, 255)
    Submit.Parent = CustomScriptPrompt

    local UICornerSubmit = Instance.new("UICorner")
    UICornerSubmit.Parent = Submit

    Submit.MouseButton1Click:Connect(function()
        print("Submitted script: " .. ScriptTextBox.Text)
    end)

    return CustomScriptPrompt
end

return Aureon
