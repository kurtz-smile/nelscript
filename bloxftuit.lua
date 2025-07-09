--[[
    NelScript Premium for Blox Fruits
    Version: 2.0.1
    Password: NELPASSKEY
    Follow: https://facebook.com/nelwynesc
]]

-- Initialization
if _G.NelScriptLoaded then return end
_G.NelScriptLoaded = true

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- Player
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Main Variables
local NelScript = {
    UI = nil,
    FloatingIcon = nil,
    Settings = {
        AutoFarm = false,
        FruitESP = false,
        AutoQuest = false,
        NoClip = false,
        UIVisible = true
    },
    Connections = {}
}

-- Create Notification Function
local function Notify(title, message, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = message,
        Duration = duration or 3
    })
end

-- Open Facebook Link
local function OpenFacebook()
    local url = "https://facebook.com/nelwynesc"
    
    -- Try to copy to clipboard
    pcall(function()
        setclipboard(url)
        Notify("NelScript", "Facebook link copied to clipboard!", 5)
    end)
    
    -- Try to open in browser
    pcall(function()
        local Http = game:GetService("HttpService")
        local TeleportService = game:GetService("TeleportService")
        local result = Http:JSONEncode({url = url})
        TeleportService:SetTeleportGui(result)
    end)
end

-- Create Floating Icon
local function CreateFloatingIcon()
    -- Destroy existing icon if it exists
    if NelScript.FloatingIcon then
        NelScript.FloatingIcon:Destroy()
    end

    local Icon = Instance.new("ImageButton")
    Icon.Name = "NelScriptFloatingIcon"
    Icon.Image = "rbxassetid://7072706620" -- Default Roblox icon (replace with your own)
    Icon.Size = UDim2.new(0, 50, 0, 50)
    Icon.Position = UDim2.new(1, -60, 1, -60)
    Icon.AnchorPoint = Vector2.new(1, 1)
    Icon.BackgroundTransparency = 1
    Icon.ZIndex = 999
    Icon.Parent = CoreGui

    -- Add UIScale for hover effect
    local UIScale = Instance.new("UIScale")
    UIScale.Scale = 1
    UIScale.Parent = Icon

    -- Add glowing effect
    local Glow = Instance.new("ImageLabel")
    Glow.Name = "Glow"
    Glow.Image = "rbxassetid://5028857084" -- Glow effect
    Glow.Size = UDim2.new(1.5, 0, 1.5, 0)
    Glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Glow.AnchorPoint = Vector2.new(0.5, 0.5)
    Glow.BackgroundTransparency = 1
    Glow.ZIndex = Icon.ZIndex - 1
    Glow.Parent = Icon

    -- Animation variables
    local HoverScale = 1.2
    local NormalScale = 1
    local PulseScale = 1.1
    local isDragging = false
    local dragStartPos = nil
    local iconStartPos = nil

    -- Pulse animation
    task.spawn(function()
        while Icon and Icon.Parent do
            TweenService:Create(UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Scale = PulseScale}):Play()
            wait(0.5)
            TweenService:Create(UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Scale = NormalScale}):Play()
            wait(2)
        end
    end)

    -- Hover effects
    Icon.MouseEnter:Connect(function()
        TweenService:Create(UIScale, TweenInfo.new(0.15), {Scale = HoverScale}):Play()
        TweenService:Create(Glow, TweenInfo.new(0.15), {ImageTransparency = 0.7}):Play()
    end)

    Icon.MouseLeave:Connect(function()
        if not isDragging then
            TweenService:Create(UIScale, TweenInfo.new(0.15), {Scale = NormalScale}):Play()
            TweenService:Create(Glow, TweenInfo.new(0.15), {ImageTransparency = 1}):Play()
        end
    end)

    -- Drag functionality
    Icon.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStartPos = Vector2.new(input.Position.X, input.Position.Y)
            iconStartPos = Vector2.new(Icon.Position.X.Offset, Icon.Position.Y.Offset)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStartPos
            Icon.Position = UDim2.new(0, iconStartPos.X + delta.X, 0, iconStartPos.Y + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
            -- Snap to edges
            local pos = Icon.Position
            local viewportSize = workspace.CurrentCamera.ViewportSize
            
            if pos.X.Offset < viewportSize.X/2 then
                pos = UDim2.new(0, 10, pos.Y.Scale, pos.Y.Offset)
            else
                pos = UDim2.new(1, -60, pos.Y.Scale, pos.Y.Offset)
            end
            
            if pos.Y.Offset < viewportSize.Y/2 then
                pos = UDim2.new(pos.X.Scale, pos.X.Offset, 0, 10)
            else
                pos = UDim2.new(pos.X.Scale, pos.X.Offset, 1, -60)
            end
            
            TweenService:Create(Icon, TweenInfo.new(0.2), {Position = pos}):Play()
        end
    end)

    -- Toggle UI on click
    Icon.MouseButton1Click:Connect(function()
        if not isDragging then
            NelScript.Settings.UIVisible = not NelScript.Settings.UIVisible
            if NelScript.UI then
                NelScript.UI.Enabled = NelScript.Settings.UIVisible
                Notify("NelScript", NelScript.Settings.UIVisible and "UI Enabled" or "UI Disabled", 2)
            end
        end
    end)

    -- Right click to toggle icon visibility
    Icon.MouseButton2Click:Connect(function()
        Icon.Visible = not Icon.Visible
        Notify("NelScript", Icon.Visible and "Floating Icon Shown" or "Floating Icon Hidden", 2)
    end)

    NelScript.FloatingIcon = Icon
    return Icon
end

-- Create Main UI
local function CreateMainUI()
    -- Destroy existing UI if it exists
    if NelScript.UI then
        NelScript.UI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NelScriptUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    -- Add rounded corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    -- Add drop shadow
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(60, 60, 80)
    UIStroke.Thickness = 2
    UIStroke.Parent = MainFrame

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local TitleCorner = UICorner:Clone()
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Text = "NelScript Premium v2.0.1"
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar

    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Text = "X"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
    CloseButton.AnchorPoint = Vector2.new(1, 0.5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TitleBar

    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui.Enabled = false
        NelScript.Settings.UIVisible = false
    end)

    -- Tab System
    local TabButtons = Instance.new("Frame")
    TabButtons.Name = "TabButtons"
    TabButtons.Size = UDim2.new(1, 0, 0, 40)
    TabButtons.Position = UDim2.new(0, 0, 0, 40)
    TabButtons.BackgroundTransparency = 1
    TabButtons.Parent = MainFrame

    local TabContent = Instance.new("Frame")
    TabContent.Name = "TabContent"
    TabContent.Size = UDim2.new(1, -20, 1, -100)
    TabContent.Position = UDim2.new(0, 10, 0, 90)
    TabContent.BackgroundTransparency = 1
    TabContent.Parent = MainFrame

    -- Tab scrolling
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = TabButtons

    local Tabs = {
        {Name = "Main", Icon = "⚙️"},
        {Name = "Farming", Icon = "🌾"},
        {Name = "Fruits", Icon = "🍎"},
        {Name = "Player", Icon = "👤"},
        {Name = "Settings", Icon = "🔧"}
    }

    local CurrentTab = nil

    local function CreateTab(tabData)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabData.Name.."Tab"
        TabButton.Text = tabData.Icon.." "..tabData.Name
        TabButton.Size = UDim2.new(0, 80, 1, 0)
        TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabButton.Font = Enum.Font.Gotham
        TabButton.Parent = TabButtons

        local TabFrame = Instance.new("ScrollingFrame")
        TabFrame.Name = tabData.Name.."Frame"
        TabFrame.Size = UDim2.new(1, 0, 1, 0)
        TabFrame.BackgroundTransparency = 1
        TabFrame.Visible = false
        TabFrame.ScrollBarThickness = 3
        TabFrame.Parent = TabContent

        local TabContentLayout = Instance.new("UIListLayout")
        TabContentLayout.Padding = UDim.new(0, 10)
        TabContentLayout.Parent = TabFrame

        TabButton.MouseButton1Click:Connect(function()
            if CurrentTab then
                CurrentTab.Frame.Visible = false
                CurrentTab.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            end
            
            TabFrame.Visible = true
            TabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            CurrentTab = {Frame = TabFrame, Button = TabButton}
        end)

        -- Activate first tab
        if not CurrentTab then
            TabFrame.Visible = true
            TabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            CurrentTab = {Frame = TabFrame, Button = TabButton}
        end

        return TabFrame
    end

    -- Create all tabs
    local MainTab = CreateTab(Tabs[1])
    local FarmTab = CreateTab(Tabs[2])
    local FruitTab = CreateTab(Tabs[3])
    local PlayerTab = CreateTab(Tabs[4])
    local SettingsTab = CreateTab(Tabs[5])

    -- Main Tab Content
    local function CreateSection(parent, title)
        local Section = Instance.new("Frame")
        Section.Name = title.."Section"
        Section.Size = UDim2.new(1, 0, 0, 0)
        Section.BackgroundTransparency = 1
        Section.Parent = parent

        local SectionTitle = Instance.new("TextLabel")
        SectionTitle.Name = "Title"
        SectionTitle.Text = title
        SectionTitle.Size = UDim2.new(1, 0, 0, 20)
        SectionTitle.BackgroundTransparency = 1
        SectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        SectionTitle.Font = Enum.Font.GothamBold
        SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        SectionTitle.Parent = Section

        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Padding = UDim.new(0, 10)
        ContentLayout.Parent = Section

        Section.AutomaticSize = Enum.AutomaticSize.Y

        return Section
    end

    -- Main Tab
    local WelcomeSection = CreateSection(MainTab, "Welcome")
    
    local WelcomeLabel = Instance.new("TextLabel")
    WelcomeLabel.Text = "Thanks for using NelScript!\nFollow our Facebook page for updates:"
    WelcomeLabel.TextWrapped = true
    WelcomeLabel.Size = UDim2.new(1, 0, 0, 40)
    WelcomeLabel.BackgroundTransparency = 1
    WelcomeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    WelcomeLabel.Font = Enum.Font.Gotham
    WelcomeLabel.Parent = WelcomeSection

    local FacebookButton = Instance.new("TextButton")
    FacebookButton.Text = "Open Facebook Page"
    FacebookButton.Size = UDim2.new(1, 0, 0, 30)
    FacebookButton.BackgroundColor3 = Color3.fromRGB(60, 90, 150)
    FacebookButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    FacebookButton.Font = Enum.Font.Gotham
    FacebookButton.Parent = WelcomeSection

    FacebookButton.MouseButton1Click:Connect(OpenFacebook)

    -- Farming Tab
    local AutoFarmSection = CreateSection(FarmTab, "Auto Farming")
    
    local AutoFarmToggle = Instance.new("TextButton")
    AutoFarmToggle.Text = "Auto Farm Level: OFF"
    AutoFarmToggle.Size = UDim2.new(1, 0, 0, 30)
    AutoFarmToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    AutoFarmToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoFarmToggle.Font = Enum.Font.Gotham
    AutoFarmToggle.Parent = AutoFarmSection

    AutoFarmToggle.MouseButton1Click:Connect(function()
        NelScript.Settings.AutoFarm = not NelScript.Settings.AutoFarm
        AutoFarmToggle.Text = "Auto Farm Level: " .. (NelScript.Settings.AutoFarm and "ON" or "OFF")
        AutoFarmToggle.BackgroundColor3 = NelScript.Settings.AutoFarm and Color3.fromRGB(80, 160, 80) or Color3.fromRGB(60, 60, 70)
        Notify("Auto Farm", NelScript.Settings.AutoFarm and "Enabled" or "Disabled", 2)
    end)

    local AutoQuestToggle = Instance.new("TextButton")
    AutoQuestToggle.Text = "Auto Quest: OFF"
    AutoQuestToggle.Size = UDim2.new(1, 0, 0, 30)
    AutoQuestToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    AutoQuestToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoQuestToggle.Font = Enum.Font.Gotham
    AutoQuestToggle.Parent = AutoFarmSection

    AutoQuestToggle.MouseButton1Click:Connect(function()
        NelScript.Settings.AutoQuest = not NelScript.Settings.AutoQuest
        AutoQuestToggle.Text = "Auto Quest: " .. (NelScript.Settings.AutoQuest and "ON" or "OFF")
        AutoQuestToggle.BackgroundColor3 = NelScript.Settings.AutoQuest and Color3.fromRGB(80, 160, 80) or Color3.fromRGB(60, 60, 70)
        Notify("Auto Quest", NelScript.Settings.AutoQuest and "Enabled" or "Disabled", 2)
    end)

    -- Fruits Tab
    local FruitFinderSection = CreateSection(FruitTab, "Fruit ESP")
    
    local FruitESPToggle = Instance.new("TextButton")
    FruitESPToggle.Text = "Fruit ESP: OFF"
    FruitESPToggle.Size = UDim2.new(1, 0, 0, 30)
    FruitESPToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    FruitESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    FruitESPToggle.Font = Enum.Font.Gotham
    FruitESPToggle.Parent = FruitFinderSection

    FruitESPToggle.MouseButton1Click:Connect(function()
        NelScript.Settings.FruitESP = not NelScript.Settings.FruitESP
        FruitESPToggle.Text = "Fruit ESP: " .. (NelScript.Settings.FruitESP and "ON" or "OFF")
        FruitESPToggle.BackgroundColor3 = NelScript.Settings.FruitESP and Color3.fromRGB(80, 160, 80) or Color3.fromRGB(60, 60, 70)
        Notify("Fruit ESP", NelScript.Settings.FruitESP and "Enabled" or "Disabled", 2)
    end)

    -- Player Tab
    local PlayerSection = CreateSection(PlayerTab, "Player Options")
    
    local NoClipToggle = Instance.new("TextButton")
    NoClipToggle.Text = "NoClip: OFF"
    NoClipToggle.Size = UDim2.new(1, 0, 0, 30)
    NoClipToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    NoClipToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    NoClipToggle.Font = Enum.Font.Gotham
    NoClipToggle.Parent = PlayerSection

    NoClipToggle.MouseButton1Click:Connect(function()
        NelScript.Settings.NoClip = not NelScript.Settings.NoClip
        NoClipToggle.Text = "NoClip: " .. (NelScript.Settings.NoClip and "ON" or "OFF")
        NoClipToggle.BackgroundColor3 = NelScript.Settings.NoClip and Color3.fromRGB(80, 160, 80) or Color3.fromRGB(60, 60, 70)
        Notify("NoClip", NelScript.Settings.NoClip and "Enabled" or "Disabled", 2)
    end)

    -- Settings Tab
    local UISection = CreateSection(SettingsTab, "UI Settings")
    
    local ToggleUIButton = Instance.new("TextButton")
    ToggleUIButton.Text = "Toggle UI Visibility"
    ToggleUIButton.Size = UDim2.new(1, 0, 0, 30)
    ToggleUIButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    ToggleUIButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleUIButton.Font = Enum.Font.Gotham
    ToggleUIButton.Parent = UISection

    ToggleUIButton.MouseButton1Click:Connect(function()
        NelScript.Settings.UIVisible = not NelScript.Settings.UIVisible
        ScreenGui.Enabled = NelScript.Settings.UIVisible
        Notify("UI", NelScript.Settings.UIVisible and "Shown" or "Hidden", 2)
    end)

    local ToggleIconButton = Instance.new("TextButton")
    ToggleIconButton.Text = "Toggle Floating Icon"
    ToggleIconButton.Size = UDim2.new(1, 0, 0, 30)
    ToggleIconButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    ToggleIconButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleIconButton.Font = Enum.Font.Gotham
    ToggleIconButton.Parent = UISection

    ToggleIconButton.MouseButton1Click:Connect(function()
        if NelScript.FloatingIcon then
            NelScript.FloatingIcon.Visible = not NelScript.FloatingIcon.Visible
            Notify("Floating Icon", NelScript.FloatingIcon.Visible and "Shown" or "Hidden", 2)
        end
    end)

    NelScript.UI = ScreenGui
    return ScreenGui
end

-- Password Verification
local function VerifyPassword()
    local PasswordGui = Instance.new("ScreenGui")
    PasswordGui.Name = "NelScriptPassword"
    PasswordGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    PasswordGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 200)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = PasswordGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Text = "NelScript Authentication"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame

    local TitleCorner = UICorner:Clone()
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = Title

    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Text = "Follow facebook.com/nelwynesc first!"
    InfoLabel.Size = UDim2.new(1, -20, 0, 40)
    InfoLabel.Position = UDim2.new(0, 10, 0, 50)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    InfoLabel.TextWrapped = true
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.Parent = MainFrame

    local FacebookButton = Instance.new("TextButton")
    FacebookButton.Text = "Copy Facebook Link"
    FacebookButton.Size = UDim2.new(1, -20, 0, 30)
    FacebookButton.Position = UDim2.new(0, 10, 0, 100)
    FacebookButton.BackgroundColor3 = Color3.fromRGB(60, 90, 150)
    FacebookButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    FacebookButton.Font = Enum.Font.Gotham
    FacebookButton.Parent = MainFrame

    FacebookButton.MouseButton1Click:Connect(OpenFacebook)

    local PasswordBox = Instance.new("TextBox")
    PasswordBox.PlaceholderText = "Enter Password (NELPASSKEY)"
    PasswordBox.Size = UDim2.new(1, -20, 0, 30)
    PasswordBox.Position = UDim2.new(0, 10, 0, 140)
    PasswordBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    PasswordBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    PasswordBox.Font = Enum.Font.Gotham
    PasswordBox.Parent = MainFrame

    local SubmitButton = Instance.new("TextButton")
    SubmitButton.Text = "Submit"
    SubmitButton.Size = UDim2.new(1, -20, 0, 30)
    SubmitButton.Position = UDim2.new(0, 10, 0, 180)
    SubmitButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitButton.Font = Enum.Font.GothamBold
    SubmitButton.Parent = MainFrame

    SubmitButton.MouseButton1Click:Connect(function()
        if PasswordBox.Text == "NELPASSKEY" then
            PasswordGui:Destroy()
            CreateFloatingIcon()
            CreateMainUI()
            Notify("NelScript", "Successfully authenticated!", 3)
        else
            PasswordBox.Text = ""
            PasswordBox.PlaceholderText = "Wrong password!"
            task.wait(0.5)
            PasswordBox.PlaceholderText = "Enter Password (NELPASSKEY)"
        end
    end)
end

-- Start the script
VerifyPassword()
