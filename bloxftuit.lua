--[[
    NelScript for Blox Fruits
    Version: 1.3.7
    Password: NELPASSKEY
    Follow: https://facebook.com/nelwynesc
]]

-- Initialization
if _G.NelScriptExecuted then return end
_G.NelScriptExecuted = true

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TPService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Player
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Main Variables
local NelScript = {
    Settings = {
        AutoFarm = false,
        FruitFinder = false,
        AutoQuest = false,
        NoClip = false
    },
    Connections = {},
    Fruits = {},
    Islands = {}
}

-- UI Library (Fake Kavo UI)
local function CreateFakeKavo()
    local Library = {}
    
    function Library:CreateWindow(name)
        local ScreenGui = Instance.new("ScreenGui")
        local MainFrame = Instance.new("Frame")
        
        ScreenGui.Name = "NelScriptUI"
        ScreenGui.Parent = CoreGui
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        
        MainFrame.Name = "MainFrame"
        MainFrame.Size = UDim2.new(0, 450, 0, 500)
        MainFrame.Position = UDim2.new(0.5, -225, 0.5, -250)
        MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        MainFrame.Parent = ScreenGui
        
        local Title = Instance.new("TextLabel")
        Title.Name = "Title"
        Title.Text = name
        Title.Size = UDim2.new(1, 0, 0, 30)
        Title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.Font = Enum.Font.GothamBold
        Title.Parent = MainFrame
        
        local TabHolder = Instance.new("Frame")
        TabHolder.Name = "TabHolder"
        TabHolder.Size = UDim2.new(1, 0, 0, 30)
        TabHolder.Position = UDim2.new(0, 0, 0, 30)
        TabHolder.BackgroundTransparency = 1
        TabHolder.Parent = MainFrame
        
        local PageHolder = Instance.new("Frame")
        PageHolder.Name = "PageHolder"
        PageHolder.Size = UDim2.new(1, -20, 1, -80)
        PageHolder.Position = UDim2.new(0, 10, 0, 70)
        PageHolder.BackgroundTransparency = 1
        PageHolder.Parent = MainFrame
        
        -- Close Button
        local CloseButton = Instance.new("TextButton")
        CloseButton.Name = "CloseButton"
        CloseButton.Text = "X"
        CloseButton.Size = UDim2.new(0, 30, 0, 30)
        CloseButton.Position = UDim2.new(1, -30, 0, 0)
        CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        CloseButton.Parent = MainFrame
        
        CloseButton.MouseButton1Click:Connect(function()
            ScreenGui:Destroy()
        end)
        
        local Window = {
            GUI = ScreenGui,
            Tabs = {}
        }
        
        function Window:NewTab(name)
            local TabButton = Instance.new("TextButton")
            TabButton.Name = name.."Tab"
            TabButton.Text = name
            TabButton.Size = UDim2.new(0, 100, 1, 0)
            TabButton.Position = UDim2.new(0, (#Window.Tabs * 100), 0, 0)
            TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabButton.Parent = TabHolder
            
            local Page = Instance.new("ScrollingFrame")
            Page.Name = name.."Page"
            Page.Size = UDim2.new(1, 0, 1, 0)
            Page.Position = UDim2.new(0, 0, 0, 0)
            Page.BackgroundTransparency = 1
            Page.Visible = false
            Page.Parent = PageHolder
            
            local Tab = {
                Name = name,
                Page = Page,
                Sections = {}
            }
            
            table.insert(Window.Tabs, Tab)
            
            if #Window.Tabs == 1 then
                Page.Visible = true
                TabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            end
            
            TabButton.MouseButton1Click:Connect(function()
                for _, v in pairs(Window.Tabs) do
                    v.Page.Visible = false
                end
                for _, v in pairs(TabHolder:GetChildren()) do
                    if v:IsA("TextButton") then
                        v.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                    end
                end
                Page.Visible = true
                TabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            end)
            
            function Tab:NewSection(name)
                local SectionFrame = Instance.new("Frame")
                SectionFrame.Name = name.."Section"
                SectionFrame.Size = UDim2.new(1, 0, 0, 30)
                SectionFrame.Position = UDim2.new(0, 0, 0, (#self.Sections * 35))
                SectionFrame.BackgroundTransparency = 1
                SectionFrame.Parent = Page
                
                local SectionTitle = Instance.new("TextLabel")
                SectionTitle.Name = "Title"
                SectionTitle.Text = name
                SectionTitle.Size = UDim2.new(1, 0, 0, 20)
                SectionTitle.BackgroundTransparency = 1
                SectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
                SectionTitle.Font = Enum.Font.Gotham
                SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
                SectionTitle.Parent = SectionFrame
                
                local Section = {
                    Name = name,
                    Frame = SectionFrame,
                    Elements = {},
                    YOffset = 25
                }
                
                table.insert(self.Sections, Section)
                
                function Section:NewButton(name, callback)
                    local Button = Instance.new("TextButton")
                    Button.Name = name
                    Button.Text = name
                    Button.Size = UDim2.new(1, -10, 0, 25)
                    Button.Position = UDim2.new(0, 5, 0, self.YOffset)
                    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
                    Button.Parent = self.Frame
                    
                    self.YOffset = self.YOffset + 30
                    Page.CanvasSize = UDim2.new(0, 0, 0, self.YOffset + 10)
                    
                    Button.MouseButton1Click:Connect(callback)
                    
                    table.insert(self.Elements, Button)
                    return Button
                end
                
                function Section:NewToggle(name, callback)
                    local ToggleFrame = Instance.new("Frame")
                    ToggleFrame.Name = name.."Toggle"
                    ToggleFrame.Size = UDim2.new(1, -10, 0, 25)
                    ToggleFrame.Position = UDim2.new(0, 5, 0, self.YOffset)
                    ToggleFrame.BackgroundTransparency = 1
                    ToggleFrame.Parent = self.Frame
                    
                    local ToggleButton = Instance.new("TextButton")
                    ToggleButton.Name = "Button"
                    ToggleButton.Text = name
                    ToggleButton.Size = UDim2.new(0.8, 0, 1, 0)
                    ToggleButton.Position = UDim2.new(0, 0, 0, 0)
                    ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    ToggleButton.TextXAlignment = Enum.TextXAlignment.Left
                    ToggleButton.Parent = ToggleFrame
                    
                    local ToggleStatus = Instance.new("Frame")
                    ToggleStatus.Name = "Status"
                    ToggleStatus.Size = UDim2.new(0, 20, 0, 20)
                    ToggleStatus.Position = UDim2.new(1, -25, 0.5, -10)
                    ToggleStatus.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                    ToggleStatus.Parent = ToggleFrame
                    
                    self.YOffset = self.YOffset + 30
                    Page.CanvasSize = UDim2.new(0, 0, 0, self.YOffset + 10)
                    
                    local Toggled = false
                    
                    local function UpdateToggle()
                        Toggled = not Toggled
                        if Toggled then
                            ToggleStatus.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
                        else
                            ToggleStatus.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                        end
                        callback(Toggled)
                    end
                    
                    ToggleButton.MouseButton1Click:Connect(UpdateToggle)
                    
                    table.insert(self.Elements, ToggleFrame)
                    return ToggleFrame
                end
                
                function Section:NewLabel(text)
                    local Label = Instance.new("TextLabel")
                    Label.Name = "Label"
                    Label.Text = text
                    Label.Size = UDim2.new(1, -10, 0, 20)
                    Label.Position = UDim2.new(0, 5, 0, self.YOffset)
                    Label.BackgroundTransparency = 1
                    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    Label.Font = Enum.Font.Gotham
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.Parent = self.Frame
                    
                    self.YOffset = self.YOffset + 25
                    Page.CanvasSize = UDim2.new(0, 0, 0, self.YOffset + 10)
                    
                    table.insert(self.Elements, Label)
                    return Label
                end
                
                return Section
            end
            
            return Tab
        end
        
        return Window
    end
    
    return Library
end

-- Create Floating Icon
local function CreateFloatingIcon()
    local Icon = Instance.new("ImageButton")
    Icon.Name = "NelScriptIcon"
    Icon.Image = "rbxassetid://1234567890" -- Replace with your image ID
    Icon.Size = UDim2.new(0, 50, 0, 50)
    Icon.Position = UDim2.new(1, -60, 1, -60)
    Icon.AnchorPoint = Vector2.new(1, 1)
    Icon.BackgroundTransparency = 1
    Icon.ZIndex = 999
    Icon.Parent = CoreGui
    
    local UIScale = Instance.new("UIScale")
    UIScale.Parent = Icon
    
    local HoverScale = 1.1
    local NormalScale = 1
    
    Icon.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(UIScale, TweenInfo.new(0.1), {Scale = HoverScale}):Play()
    end)
    
    Icon.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(UIScale, TweenInfo.new(0.1), {Scale = NormalScale}):Play()
    end)
    
    return Icon
end

-- Password Verification
local function VerifyPassword()
    local Library = CreateFakeKavo()
    local Window = Library:CreateWindow("NelScript Authentication")
    local MainTab = Window:NewTab("Verification")
    local MainSection = MainTab:NewSection("Password Required")
    
    MainSection:NewLabel("Follow facebook.com/nelwynesc first!")
    
    local PasswordBox = Instance.new("TextBox")
    PasswordBox.Name = "PasswordBox"
    PasswordBox.PlaceholderText = "Enter Password (NELPASSKEY)"
    PasswordBox.Size = UDim2.new(1, -10, 0, 25)
    PasswordBox.Position = UDim2.new(0, 5, 0, MainSection.YOffset)
    PasswordBox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    PasswordBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    PasswordBox.Parent = MainSection.Frame
    
    MainSection.YOffset = MainSection.YOffset + 30
    
    local SubmitButton = MainSection:NewButton("Submit", function()
        if PasswordBox.Text == "NELPASSKEY" then
            Window.GUI:Destroy()
            _G.NelVerified = true
            InitNelScript()
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "NelScript",
                Text = "Incorrect Password!",
                Duration = 3
            })
        end
    end)
    
    -- Auto-close after 5 minutes if not verified
    task.delay(300, function()
        if not _G.NelVerified then
            Window.GUI:Destroy()
            _G.NelScriptExecuted = false
        end
    end)
end

-- Main Script Initialization
local function InitNelScript()
    -- Create floating icon
    local Icon = CreateFloatingIcon()
    
    -- Create main UI
    local Library = CreateFakeKavo()
    local Window = Library:CreateWindow("NelScript v1.3.7")
    
    -- Main Tab
    local MainTab = Window:NewTab("Main")
    local MainSection = MainTab:NewSection("Auto Farm")
    
    MainSection:NewToggle("Auto Farm Level", function(state)
        NelScript.Settings.AutoFarm = state
        if state then
            -- Auto farm logic would go here
            warn("Auto Farm Enabled")
        else
            warn("Auto Farm Disabled")
        end
    end)
    
    MainSection:NewToggle("Auto Quest", function(state)
        NelScript.Settings.AutoQuest = state
        if state then
            -- Auto quest logic would go here
            warn("Auto Quest Enabled")
        else
            warn("Auto Quest Disabled")
        end
    end)
    
    -- Fruit Tab
    local FruitTab = Window:NewTab("Fruits")
    local FruitSection = FruitTab:NewSection("Fruit Options")
    
    FruitSection:NewToggle("Fruit Finder", function(state)
        NelScript.Settings.FruitFinder = state
        if state then
            -- Fruit finder logic would go here
            warn("Fruit Finder Enabled")
        else
            warn("Fruit Finder Disabled")
        end
    end)
    
    -- Player Tab
    local PlayerTab = Window:NewTab("Player")
    local PlayerSection = PlayerTab:NewSection("Player Options")
    
    PlayerSection:NewToggle("No Clip", function(state)
        NelScript.Settings.NoClip = state
        if state then
            -- No clip logic would go here
            warn("No Clip Enabled")
        else
            warn("No Clip Disabled")
        end
    end)
    
    -- Settings Tab
    local SettingsTab = Window:NewTab("Settings")
    local SettingsSection = SettingsTab:NewSection("Script Settings")
    
    SettingsSection:NewButton("Destroy UI", function()
        Window.GUI:Destroy()
    end)
    
    -- Icon click to toggle UI
    Icon.MouseButton1Click:Connect(function()
        Window.GUI.Enabled = not Window.GUI.Enabled
    end)
end

-- Start verification process
VerifyPassword()