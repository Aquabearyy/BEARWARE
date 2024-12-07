local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local httpService = game:GetService("HttpService")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local PlayerGui = LocalPlayer.PlayerGui
local Backpack = LocalPlayer.Backpack

local ThemeManager = {}
ThemeManager.Folder = "SilentHub"
ThemeManager.Settings = {
    Theme = "Default"
}

function ThemeManager:SetFolder(folder)
    self.Folder = folder
    if not isfolder(self.Folder) then
        makefolder(self.Folder)
    end
end

function ThemeManager:SetLibrary(library)
    self.Library = library
end

function ThemeManager:SaveSettings()
    writefile(self.Folder .. "/theme.json", httpService:JSONEncode(self.Settings))
end

function ThemeManager:LoadSettings()
    local path = self.Folder .. "/theme.json"
    if isfile(path) then
        local data = readfile(path)
        local success, decoded = pcall(httpService.JSONDecode, httpService, data)
        if success then
            self.Settings.Theme = decoded.Theme
        end
    end
end

local Settings = {
    AimbotEnabled = false,
    WallCheck = true,
    AimbotHitChance = 100,
    FOV = 100,
    ShowFOV = false,
    RainbowFOV = false,
    FOVThickness = 2,
    HighlightESP = false,
    NoClip = false,
    InfJump = false,
    CFSpeed = false,
    SpeedValue = 1,
    OriginalCFrame = nil,
    UIKeybind = "RightControl"
}

local Config = {
    ['Farm Fish'] = false
}

local AllFuncs = {}

AllFuncs['Farm Fish'] = function()
    local RodName = ReplicatedStorage.playerstats[LocalPlayer.Name].Stats.rod.Value
    while Config['Farm Fish'] and task.wait() do
        if Backpack:FindFirstChild(RodName) then
            LocalPlayer.Character.Humanoid:EquipTool(Backpack:FindFirstChild(RodName))
        end
        if LocalPlayer.Character:FindFirstChild(RodName) and LocalPlayer.Character:FindFirstChild(RodName):FindFirstChild("bobber") then
            local XyzClone = game:GetService("ReplicatedStorage").resources.items.items.GPS.GPS.gpsMain.xyz:Clone()
            XyzClone.Parent = game.Players.LocalPlayer.PlayerGui:WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("backpack")
            XyzClone.Name = "Lure"
            XyzClone.Text = "<font color='#ff4949'>Lure </font>: 0%"
            repeat
                pcall(function()
                    PlayerGui:FindFirstChild("shakeui").safezone:FindFirstChild("button").Size = UDim2.new(1001, 0, 1001, 0)
                    game:GetService("VirtualUser"):Button1Down(Vector2.new(1, 1))
                    game:GetService("VirtualUser"):Button1Up(Vector2.new(1, 1))
                end)
                XyzClone.Text = "<font color='#ff4949'>Lure </font>: "..tostring(math.floor(LocalPlayer.Character:FindFirstChild(RodName).values.lure.Value * 100) / 100).."%"
                RunService.Heartbeat:Wait()
            until not LocalPlayer.Character:FindFirstChild(RodName) or LocalPlayer.Character:FindFirstChild(RodName).values.bite.Value or not Config['Farm Fish']
            XyzClone.Text = "<font color='#ff4949'>FISHING!</font>"
            delay(1.5, function()
                XyzClone:Destroy()
            end)
            repeat
                ReplicatedStorage.events.reelfinished:FireServer(1000000000000000000000000, true)
                task.wait(.5)
            until not LocalPlayer.Character:FindFirstChild(RodName) or not LocalPlayer.Character:FindFirstChild(RodName).values.bite.Value or not Config['Farm Fish']
        else
            LocalPlayer.Character:FindFirstChild(RodName).events.cast:FireServer(1000000000000000000000000)
            task.wait(2)
        end
    end
end

local Highlights = {}
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = Settings.FOVThickness
FOVCircle.NumSides = 50
FOVCircle.Radius = Settings.FOV
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.ZIndex = 999
FOVCircle.Transparency = 1
FOVCircle.Color = Color3.new(1, 1, 1)

local function GetClosestPlayer()
    if math.random(1, 100) > Settings.AimbotHitChance then return nil end
    
    local MaxFOV = Settings.FOV
    local Target = nil
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("Head") then
            local Head = Player.Character.Head
            local Vector, OnScreen = Camera:WorldToViewportPoint(Head.Position)
            local Distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Vector.X, Vector.Y)).Magnitude
            
            if OnScreen and Distance <= MaxFOV then
                if Settings.WallCheck then
                    local rayOrigin = Camera.CFrame.Position
                    local rayDirection = (Head.Position - rayOrigin).Unit * 500
                    
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                    
                    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                    if raycastResult and raycastResult.Instance:IsDescendantOf(Head.Parent) then
                        MaxFOV = Distance
                        Target = Player
                    end
                else
                    MaxFOV = Distance
                    Target = Player
                end
            end
        end
    end
    
    return Target
end

local Window = Fluent:CreateWindow({
    Title = "Silent Hub",
    SubTitle = "Private Script",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = ThemeManager.Settings.Theme,
    MinimizeKey = Enum.KeyCode[Settings.UIKeybind]
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "swords" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Movement = Window:AddTab({ Title = "Movement", Icon = "move" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Farming = Tabs.Main:AddSection("Farming")

Farming:AddToggle("AutoFarm", {
    Title = "Auto Farm Fish",
    Default = false,
    Callback = function(Value)
        Config['Farm Fish'] = Value
        if Value then
            task.spawn(AllFuncs['Farm Fish'])
        end
    end
})

local AimbotSection = Tabs.Combat:AddSection("Silent Aim")

AimbotSection:AddToggle("SilentEnabled", {
    Title = "Silent Aim",
    Default = false,
    Callback = function(Value)
        Settings.AimbotEnabled = Value
    end
})

AimbotSection:AddToggle("ShowFOV", {
    Title = "Show FOV",
    Default = false,
    Callback = function(Value)
        Settings.ShowFOV = Value
        FOVCircle.Visible = Value
    end
})

AimbotSection:AddToggle("RainbowFOV", {
    Title = "Rainbow FOV",
    Default = false,
    Callback = function(Value)
        Settings.RainbowFOV = Value
    end
})

AimbotSection:AddSlider("FOVSize", {
    Title = "FOV Size",
    Default = 100,
    Min = 30,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        Settings.FOV = Value
        FOVCircle.Radius = Value
    end
})

AimbotSection:AddSlider("FOVThickness", {
    Title = "FOV Thickness",
    Default = 2,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Callback = function(Value)
        Settings.FOVThickness = Value
        FOVCircle.Thickness = Value
    end
})

AimbotSection:AddSlider("HitChance", {
    Title = "Hit Chance",
    Default = 100,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        Settings.AimbotHitChance = Value
    end
})

local VisualsSection = Tabs.Visuals:AddSection("ESP")

VisualsSection:AddToggle("HighlightESP", {
    Title = "Highlight ESP",
    Default = false,
    Callback = function(Value)
        Settings.HighlightESP = Value
        if not Value then
            for _, highlight in pairs(Highlights) do
                highlight:Destroy()
            end
            table.clear(Highlights)
        end
    end
})

local MovementSection = Tabs.Movement:AddSection("Movement")

MovementSection:AddToggle("CFSpeed", {
    Title = "CFrame Speed",
    Default = false,
    Callback = function(Value)
        Settings.CFSpeed = Value
    end
})

MovementSection:AddToggle("InfJump", {
    Title = "Infinite Jump",
    Default = false,
    Callback = function(Value)
        Settings.InfJump = Value
    end
})

MovementSection:AddToggle("NoClip", {
    Title = "NoClip",
    Default = false,
    Callback = function(Value)
        Settings.NoClip = Value
    end
})

MovementSection:AddSlider("SpeedValue", {
    Title = "Speed Value",
    Default = 1,
    Min = 0,
    Max = 5,
    Rounding = 1,
    Callback = function(Value)
        Settings.SpeedValue = Value
    end
})

local InterfaceSection = Tabs.Settings:AddSection("Interface")

InterfaceSection:AddKeybind("UIKeybind", {
    Title = "Toggle UI",
    Mode = "Toggle",
    Default = Settings.UIKeybind,
    ChangedCallback = function(New)
        Settings.UIKeybind = New.Name
        Window.MinimizeKey = Enum.KeyCode[New.Name]
    end
})

local ThemeDropdown = InterfaceSection:AddDropdown("Theme", {
    Title = "Theme",
    Description = "Changes the interface theme",
    Values = Fluent.Themes,
    Default = table.find(Fluent.Themes, ThemeManager.Settings.Theme) or 1,
    Callback = function(Value)
        Fluent:SetTheme(Value)
        ThemeManager.Settings.Theme = Value
        ThemeManager:SaveSettings()
    end
})

RunService.RenderStepped:Connect(function()
    if Settings.ShowFOV then
        FOVCircle.Position = UserInputService:GetMouseLocation()
        if Settings.RainbowFOV then
            FOVCircle.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        end
    end
    
    if Settings.HighlightESP then
        for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer then
                if Player.Character and not Highlights[Player] then
                    local Highlight = Instance.new("Highlight")
                    Highlight.FillColor = Color3.new(1, 0, 0)
                    Highlight.OutlineColor = Color3.new(1, 1, 1)
                    Highlight.FillTransparency = 0.5
                    Highlight.OutlineTransparency = 0
                    Highlight.Parent = Player.Character
                    Highlights[Player] = Highlight
                end
            end
        end
    end
    
    if Settings.NoClip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    if Settings.CFSpeed and LocalPlayer.Character then
        local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local moveDirection = LocalPlayer.Character.Humanoid.MoveDirection
            if moveDirection.Magnitude > 0 then
                humanoidRootPart.CFrame = humanoidRootPart.CFrame + moveDirection * Settings.SpeedValue
            end
        end
    end
end)

Mouse.Button1Down:Connect(function()
    if Settings.AimbotEnabled and math.random(1, 100) <= Settings.AimbotHitChance then
        local Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild("Head") then
            Settings.OriginalCFrame = Camera.CFrame
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character.Head.Position)
        end
    end
end)

Mouse.Button1Up:Connect(function()
    if Settings.AimbotEnabled and Settings.OriginalCFrame then
        Camera.CFrame = Settings.OriginalCFrame
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space and Settings.InfJump then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if Highlights[player] then
        Highlights[player]:Destroy()
        Highlights[player] = nil
    end
end)

ThemeManager:SetLibrary(Fluent)
ThemeManager:SetFolder("SilentHub")
ThemeManager:LoadSettings()

SaveManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("SilentHub/configs")
SaveManager:BuildConfigSection(Tabs.Settings)

SaveManager:SetIgnoreIndexes({
    "Theme",
    "UIKeybind"
})

Window:SelectTab(1)

Fluent:Notify({
    Title = "Silent Hub",
    Content = "The script has been loaded.",
    Duration = 8
})
