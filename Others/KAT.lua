local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

getgenv().Settings = {
    Enabled = false,
    FovCircle = false,
    Fov = 100,
    Smoothness = 0.25,
    VisibilityCheck = false,
    TargetPart = "Head",
    LockMode = false,
    LockKey = Enum.KeyCode.Q,
    CameraFOV = 70
}

local Window = OrionLib:MakeWindow({
    Name = "Universal Aim Assist",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "UniversalAim"
})

local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local VisualsTab = Window:MakeTab({
    Name = "Visuals",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MainTab:AddToggle({
    Name = "Enable Aim Assist",
    Default = false,
    Flag = "AimbotEnabled",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.Enabled = Value
    end
})

MainTab:AddToggle({
    Name = "Show FOV Circle",
    Default = false,
    Flag = "FovCircle",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.FovCircle = Value
    end
})

MainTab:AddToggle({
    Name = "Visibility Check",
    Default = false,
    Flag = "VisibilityCheck",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.VisibilityCheck = Value
    end
})

MainTab:AddSlider({
    Name = "FOV Size",
    Min = 30,
    Max = 500,
    Default = 100,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "pixels",
    Flag = "FovRadius",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.Fov = Value
    end
})

MainTab:AddSlider({
    Name = "Smoothness",
    Min = 0,
    Max = 1,
    Default = 0.25,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.01,
    ValueName = "multiplier",
    Flag = "Smoothness",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.Smoothness = Value
    end
})

MainTab:AddDropdown({
    Name = "Target Part",
    Default = "Head",
    Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    Flag = "SelectedPart",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.TargetPart = Value
    end
})

MainTab:AddBind({
    Name = "Lock Key",
    Default = Enum.KeyCode.Q,
    Hold = false,
    Flag = "LockKey",
    Save = true,
    Callback = function()
        getgenv().Settings.LockMode = not getgenv().Settings.LockMode
        OrionLib:MakeNotification({
            Name = "Lock Mode",
            Content = getgenv().Settings.LockMode and "Locked On" or "Lock Released",
            Image = "rbxassetid://4483345998",
            Time = 2
        })
    end    
})

VisualsTab:AddSlider({
    Name = "Camera FOV",
    Min = 30,
    Max = 120,
    Default = 70,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "FOV",
    Flag = "CameraFOV",
    Save = true,
    Callback = function(Value)
        getgenv().Settings.CameraFOV = Value
        game:GetService("Workspace").CurrentCamera.FieldOfView = Value
    end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local CircleInline = Drawing.new("Circle")
local CircleOutline = Drawing.new("Circle")

CircleInline.Transparency = 1
CircleInline.Thickness = 2
CircleInline.Color = Color3.fromRGB(255, 255, 255)
CircleInline.ZIndex = 2

CircleOutline.Transparency = 1
CircleOutline.Thickness = 4
CircleOutline.Color = Color3.new()
CircleOutline.ZIndex = 1

local LockedTarget = nil

local function IsVisible(Part)
    if not getgenv().Settings.VisibilityCheck then return true end
    local Origin = Camera.CFrame.Position
    local Direction = Part.Position - Origin
    local RaycastResult = Workspace:Raycast(Origin, Direction.Unit * Direction.Magnitude, 
        RaycastParams.new({
            FilterType = Enum.RaycastFilterType.Blacklist,
            FilterDescendantsInstances = {LocalPlayer.Character}
        })
    )
    return RaycastResult and RaycastResult.Instance:IsDescendantOf(Part.Parent)
end

local function GetClosestPlayer()
    local Closest = nil
    local MaxDistance = getgenv().Settings.Fov
    local ClosestDistance = MaxDistance

    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            local Character = Player.Character
            if Character and Character:FindFirstChild(getgenv().Settings.TargetPart) and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0 then
                local TargetPart = Character[getgenv().Settings.TargetPart]
                local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)
                
                if OnScreen and IsVisible(TargetPart) then
                    local Distance = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if Distance < ClosestDistance then
                        Closest = TargetPart
                        ClosestDistance = Distance
                    end
                end
            end
        end
    end
    
    return Closest
end

local function UpdateLockedTarget()
    if not LockedTarget or not LockedTarget.Parent or 
       not LockedTarget.Parent:FindFirstChild("Humanoid") or 
       LockedTarget.Parent.Humanoid.Health <= 0 then
        LockedTarget = nil
        return
    end
    
    local _, OnScreen = Camera:WorldToViewportPoint(LockedTarget.Position)
    if not OnScreen or (getgenv().Settings.VisibilityCheck and not IsVisible(LockedTarget)) then
        LockedTarget = nil
    end
end

RunService.RenderStepped:Connect(function()
    CircleInline.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    CircleInline.Radius = getgenv().Settings.Fov
    CircleInline.Visible = getgenv().Settings.FovCircle

    CircleOutline.Position = CircleInline.Position
    CircleOutline.Radius = getgenv().Settings.Fov
    CircleOutline.Visible = getgenv().Settings.FovCircle

    if getgenv().Settings.Enabled then
        if getgenv().Settings.LockMode then
            UpdateLockedTarget()
            if not LockedTarget then
                LockedTarget = GetClosestPlayer()
            end
        else
            LockedTarget = nil
        end

        local Target = LockedTarget or (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and GetClosestPlayer())
        
        if Target then
            local TargetPos = Camera:WorldToViewportPoint(Target.Position)
            local MousePos = Vector2.new(Mouse.X, Mouse.Y)
            local NewPos = Vector2.new(
                MousePos.X + (TargetPos.X - MousePos.X) * getgenv().Settings.Smoothness,
                MousePos.Y + (TargetPos.Y - MousePos.Y) * getgenv().Settings.Smoothness
            )
            mousemoveabs(NewPos.X, NewPos.Y)
        end
    end
end)

OrionLib:Init()
