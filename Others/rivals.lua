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
    -- Aimbot Settings
    AimbotEnabled = false,
    AimbotHitChance = 100,
    MaxDistance = 1000,
    FOV = 100,
    ShowFOV = false,
    RainbowFOV = false,
    FOVColor = Color3.fromRGB(255, 255, 255),
    FOVThickness = 2,
    AimType = "Aimbot",
    Sensitivity = 0.2,
    
    -- ESP Settings
    HighlightESP = false,
    HealthESP = false,
    HighlightColor = Color3.fromRGB(255, 0, 0),
    OutlineColor = Color3.fromRGB(255, 255, 255),
    FillTransparency = 0.5,
    OutlineTransparency = 0,
    
    -- Movement Settings
    CFSpeed = false,
    SpeedValue = 1,
    InfJump = false,
    NoClip = false,
    CFrameWalkSpeed = 0.2
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

local function AddHealthESP(character)
    if not character or character == LocalPlayer.Character then return end
    local head = character:WaitForChild("Head")
    if head:FindFirstChild("HealthBar") then return end
    
    local healthBar = Instance.new("BillboardGui")
    healthBar.Name = "HealthBar"
    healthBar.Adornee = head
    healthBar.Size = UDim2.new(2, 0, 0.8, 0)
    healthBar.StudsOffset = Vector3.new(0, 2, 0)
    healthBar.AlwaysOnTop = true
    healthBar.Parent = head
    
    local mainFrame = Instance.new("Frame")
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.Parent = healthBar
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0.2, 0)
    mainCorner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(50, 50, 50)
    stroke.Thickness = 1
    stroke.Parent = mainFrame
    
    local paddingFrame = Instance.new("Frame")
    paddingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    paddingFrame.BorderSizePixel = 0
    paddingFrame.Size = UDim2.new(0.95, 0, 0.8, 0)
    paddingFrame.Position = UDim2.new(0.025, 0, 0.1, 0)
    paddingFrame.Parent = mainFrame
    
    local healthFill = Instance.new("Frame")
    healthFill.Name = "HealthFill"
    healthFill.BorderSizePixel = 0
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.Parent = paddingFrame
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0.2, 0)
    fillCorner.Parent = paddingFrame
    
    local innerCorner = Instance.new("UICorner")
    innerCorner.CornerRadius = UDim.new(0.2, 0)
    innerCorner.Parent = healthFill
    
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 90
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 0.2)
    })
    gradient.Parent = healthFill

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        task.spawn(function()
            while healthBar.Parent do
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                local r, g = math.min(2 - 2 * healthPercent, 1), math.min(2 * healthPercent, 1)
                healthFill.BackgroundColor3 = Color3.fromRGB(r * 255, g * 255, 0)
                healthFill.Size = UDim2.new(healthPercent, 0, 1, 0)
                task.wait()
            end
        end)
    end
end

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
local ESPGroup = Tabs.Main:AddRightGroupbox('ESP')
local MovementGroup = Tabs.Main:AddLeftGroupbox('Movement')

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

AimbotGroup:AddDropdown('AimType', {
    Values = {'Silent Aim', 'Aimbot'},
    Default = 'Silent Aim',
    Multi = false,
    Text = 'Aim Type',
    Tooltip = 'Choose between Silent Aim and regular Aimbot',
    Callback = function(Value)
        Settings.AimType = Value
    end
 })

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

ESPGroup:AddToggle('HealthESP', {
    Text = 'Health ESP',
    Default = false,
    Callback = function(Value)
        Settings.HealthESP = Value
        if not Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("Head") and 
                   player.Character.Head:FindFirstChild("HealthBar") then
                    player.Character.Head.HealthBar:Destroy()
                end
            end
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

ESPGroup:AddSlider('HighlightTransparency', {
    Text = 'Fill Transparency',
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        Settings.FillTransparency = Value
        for _, highlight in pairs(Highlights) do
            highlight.FillTransparency = Value
        end
    end
})

ESPGroup:AddSlider('OutlineTransparency', {
    Text = 'Outline Transparency',
    Default = 0,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        Settings.OutlineTransparency = Value
        for _, highlight in pairs(Highlights) do
            highlight.OutlineTransparency = Value
        end
    end
})

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

MovementGroup:AddToggle('NoClip', {
    Text = 'NoClip',
    Default = false,
    Tooltip = 'Walk through walls',
    Callback = function(Value)
        Settings.NoClip = Value
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
    Default = false,
    Callback = function(Value)
        Library.KeybindFrame.Visible = Value
    end
})

MenuGroup:AddToggle('QueueTeleport', {
    Text = 'Queue On Teleport',
    Default = false,
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
    if Settings.NoClip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
 
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
 end)
 
 RunService.RenderStepped:Connect(function()
    FrameCounter = FrameCounter + 1
    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameTimer = tick()
        FrameCounter = 0
    end
    Library:SetWatermark(('Silent Hub | %s fps'):format(math.floor(FPS)))
    
    if Settings.HighlightESP then
        for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer then
                if Player.Character and not Player.Character:FindFirstChild("Totally_NOT_Esp") then
                    local Highlight = Instance.new("Highlight") 
                    Highlight.Name = "Totally_NOT_Esp"
                    Highlight.FillColor = Settings.HighlightColor
                    Highlight.OutlineColor = Settings.OutlineColor
                    Highlight.FillTransparency = Settings.FillTransparency
                    Highlight.OutlineTransparency = Settings.OutlineTransparency
                    Highlight.Parent = Player.Character
                    Highlights[Player] = Highlight
 
                    if Settings.HealthESP then
                        AddHealthESP(Player.Character)
                    end
                end
            end
        end
    else
        for _, highlight in pairs(Highlights) do
            highlight:Destroy()
        end
        table.clear(Highlights)
    end
 end)

-- Add this slider to your AimbotGroup
AimbotGroup:AddSlider('Sensitivity', {
    Text = 'Aimbot Sensitivity',
    Default = 0.2,
    Min = 0.1,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        Settings.Sensitivity = Value
    end
 })

 
 local IsHolding = false

 Mouse.Button1Down:Connect(function()
     if not Settings.AimbotEnabled then return end
     
     if Settings.AimType == "Silent Aim" then
         -- Silent aim - instant snap and return
         if math.random(0, 100) <= Settings.AimbotHitChance then
             local Target = GetClosestPlayer()
             if Target and Target.Character and Target.Character:FindFirstChild("Head") then
                 local oldCFrame = Camera.CFrame
                 Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character.Head.Position)
                 task.wait()
                 Camera.CFrame = oldCFrame
             end
         end
     elseif Settings.AimType == "Aimbot" then
         -- Regular aimbot - smooth tracking while holding
         IsHolding = true
         task.spawn(function()
             while IsHolding and Settings.AimbotEnabled do
                 local Target = GetClosestPlayer()
                 if Target and Target.Character and Target.Character:FindFirstChild("Head") then
                     Camera.CFrame = Camera.CFrame:Lerp(
                         CFrame.new(Camera.CFrame.Position, Target.Character.Head.Position), 
                         Settings.Sensitivity
                     )
                 end
                 task.wait()
             end
         end)
     end
 end)
 
 Mouse.Button1Up:Connect(function()
     IsHolding = false
 end)

AimbotGroup:AddLabel('Aimbot stuff is in work!', true)

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

ESPGroup:AddLabel('Check UI Settings tab for themes and configs!', true)

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
