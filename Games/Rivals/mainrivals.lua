local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

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
    OriginalCFrame = nil
}

local DarkTheme = {
    SchemeColor = Color3.fromRGB(25, 25, 25),
    Background = Color3.fromRGB(15, 15, 15),
    Header = Color3.fromRGB(20, 20, 20),
    TextColor = Color3.fromRGB(255, 255, 255),
    ElementColor = Color3.fromRGB(35, 35, 35)
}

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
    Title = 'Silent Hub',
    SubTitle = 'by Example',
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Theme = DarkTheme
})

local Tabs = {
    Combat = Window:AddTab({ Title = "Combat", Icon = "swords" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Movement = Window:AddTab({ Title = "Movement", Icon = "move" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

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

SaveManager:SetLibrary(Fluent)
SaveManager:SetFolder("SilentHub")
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

Window:SelectTab(1)

Fluent:Notify({
    Title = "Script Loaded",
    Content = "Silent Hub has been initialized",
    Duration = 5
})
