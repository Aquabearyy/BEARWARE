local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local Settings = {
    AimbotEnabled = false,
    AimbotHitChance = 100,
    MaxDistance = 1000,
    FOV = 100,
    ShowFOV = false,
    RainbowFOV = false,
    FOVColor = Color3.fromRGB(255, 255, 255),
    FOVThickness = 2,
    
    HighlightESP = false,
    HighlightColor = Color3.fromRGB(255, 0, 0),
    OutlineColor = Color3.fromRGB(255, 255, 255),
    
    CFSpeed = false,
    SpeedValue = 1,
    InfJump = false
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
FOVCircle.Color = Settings.FOVColor

local Window = Library:CreateWindow({
    Title = 'Silent Hub - Rivals | ' .. identifyexecutor(),
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Main = Window:AddTab('Main'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local AimbotGroup = Tabs.Main:AddLeftGroupbox('Silent Aim')

AimbotGroup:AddToggle('AimbotEnabled', {
    Text = 'Silent Aim',
    Default = false,
    Callback = function(Value)
        Settings.AimbotEnabled = Value
    end
})

AimbotGroup:AddToggle('ShowFOV', {
    Text = 'Show FOV',
    Default = false,
    Callback = function(Value)
        Settings.ShowFOV = Value
        FOVCircle.Visible = Value
    end
})

AimbotGroup:AddToggle('RainbowFOV', {
    Text = 'Rainbow FOV',
    Default = false,
    Callback = function(Value)
        Settings.RainbowFOV = Value
    end
})

AimbotGroup:AddSlider('FOVSize', {
    Text = 'FOV Size',
    Default = 100,
    Min = 30,
    Max = 900,
    Rounding = 0,
    Callback = function(Value)
        Settings.FOV = Value
        FOVCircle.Radius = Value
    end
})

AimbotGroup:AddSlider('FOVThickness', {
    Text = 'FOV Thickness',
    Default = 2,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Callback = function(Value)
        Settings.FOVThickness = Value
        FOVCircle.Thickness = Value
    end
})

AimbotGroup:AddLabel('FOV Color'):AddColorPicker('FOVColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        Settings.FOVColor = Value
        FOVCircle.Color = Value
    end
})

AimbotGroup:AddSlider('AimbotHitChance', {
    Text = 'Hit Chance',
    Default = 100,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        Settings.AimbotHitChance = Value
    end
})

AimbotGroup:AddLabel('Toggle Key'):AddKeyPicker('SilentAimKeybind', {
    Default = 'V',
    NoUI = false,
    Text = 'Silent Aim Toggle',
    Callback = function(Value)
        Settings.AimbotEnabled = not Settings.AimbotEnabled
        Toggles.AimbotEnabled:SetValue(Settings.AimbotEnabled)
    end
})

local ESPGroup = Tabs.Main:AddRightGroupbox('ESP')

ESPGroup:AddToggle('HighlightESP', {
    Text = 'Highlight ESP',
    Default = false,
    Callback = function(Value)
        Settings.HighlightESP = Value
        if not Value then
            for _, highlight in pairs(Highlights) do
                highlight:Destroy()
            end
            Highlights = {}
        end
    end
})

ESPGroup:AddLabel('Fill Color'):AddColorPicker('HighlightColor', {
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        Settings.HighlightColor = Value
        for _, highlight in pairs(Highlights) do
            highlight.FillColor = Value
        end
    end
})

ESPGroup:AddLabel('Outline Color'):AddColorPicker('OutlineColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        Settings.OutlineColor = Value
        for _, highlight in pairs(Highlights) do
            highlight.OutlineColor = Value
        end
    end
})

local MovementGroup = Tabs.Main:AddLeftGroupbox('Movement')

MovementGroup:AddToggle('CFSpeed', {
    Text = 'CFrame Speed',
    Default = false,
    Tooltip = 'Enables CFrame speed modification',
    Callback = function(Value)
        Settings.CFSpeed = Value
    end
})

MovementGroup:AddSlider('SpeedValue', {
    Text = 'Speed Value',
    Default = 1,
    Min = 0,
    Max = 2,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        Settings.SpeedValue = Value
    end
})

MovementGroup:AddToggle('InfJump', {
    Text = 'Infinite Jump',
    Default = false,
    Tooltip = 'Enables infinite jumping',
    Callback = function(Value)
        Settings.InfJump = Value
    end
})

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function() 
    Library:Unload() 
end)

MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { 
    Default = 'End', 
    NoUI = true, 
    Text = 'Menu keybind' 
})

MenuGroup:AddToggle('KeybindFrame', {
    Text = 'Show Keybind Frame',
    Default = true,
    Callback = function(Value)
        Library.KeybindFrame.Visible = Value
    end
})

MenuGroup:AddToggle('QueueTeleport', {
    Text = 'Queue On Teleport',
    Default = true,
    Callback = function(Value)
        if Value then
            syn.queue_on_teleport([[
                loadstring(game:HttpGet("https://raw.githubusercontent.com/sxlent404/SilentHub/refs/heads/main/loader.lua"))()
            ]])
        end
    end
})

local function GetClosestPlayer()
    local MaxFOV = Settings.FOV
    local Target = nil
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("Head") then
            local Head = Player.Character.Head
            local Vector, OnScreen = Camera:WorldToViewportPoint(Head.Position)
            local Distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Vector.X, Vector.Y)).Magnitude
            
            if OnScreen and Distance <= MaxFOV then
                MaxFOV = Distance
                Target = Player
            end
        end
    end
    
    return Target
end

local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60

RunService.Heartbeat:Connect(function()
    if Settings.CFSpeed then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = character.HumanoidRootPart
            local moveDirection = LocalPlayer.Character.Humanoid.MoveDirection
            if moveDirection.Magnitude > 0 then
                humanoidRootPart.CFrame = humanoidRootPart.CFrame + moveDirection * Settings.SpeedValue
            end
        end
    end

    if Settings.ShowFOV then
        FOVCircle.Position = UserInputService:GetMouseLocation()
        if Settings.RainbowFOV then
            FOVCircle.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        else
            FOVCircle.Color = Settings.FOVColor
        end
    end

    if Settings.HighlightESP then
        for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer then
                if Player.Character then
                    if not Highlights[Player] then
                        local Highlight = Instance.new("Highlight")
                        Highlight.FillColor = Settings.HighlightColor
                        Highlight.OutlineColor = Settings.OutlineColor
                        Highlight.FillTransparency = 0.5
                        Highlight.OutlineTransparency = 0
                        Highlight.Parent = Player.Character
                        Highlights[Player] = Highlight
                    end
                end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    FrameCounter = FrameCounter + 1
    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameTimer = tick()
        FrameCounter = 0
    end
    Library:SetWatermark(('Silent Hub | %s fps'):format(math.floor(FPS)))
end)

Mouse.Button1Down:Connect(function()
    if Settings.AimbotEnabled then
        if math.random(0, 100) <= Settings.AimbotHitChance then
            local Target = GetClosestPlayer()
            if Target and Target.Character and Target.Character:FindFirstChild("Head") then
                Settings.OriginalCFrame = Camera.CFrame
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character.Head.Position)
            end
        end
    end
end)

Mouse.Button1Up:Connect(function()
    if Settings.AimbotEnabled and Settings.OriginalCFrame then
        Camera.CFrame = Settings.OriginalCFrame
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        if Settings.InfJump then
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if Highlights[player] then
        Highlights[player]:Destroy()
        Highlights[player] = nil
    end
end)

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({'MenuKeybind'})
ThemeManager:SetFolder('SilentHub')
SaveManager:SetFolder('SilentHub/Configs')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])

SaveManager:LoadAutoloadConfig()
