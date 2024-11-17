if not game:IsLoaded() then
    game.Loaded:Wait()
end

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

getgenv().SilentAimEnabled = false
getgenv().MaxDistance = 1000
getgenv().FOV = 100
getgenv().ShowFOV = false
getgenv().RainbowFOV = false
getgenv().FOVColor = Color3.fromRGB(255, 255, 255)
getgenv().FOVThickness = 2

local ESPSettings = {
    Enabled = false,
    BoxesEnabled = false,
    TracersEnabled = false,
    SkeletonEnabled = false,
    RainbowBoxes = false,
    RainbowTracers = false,
    RainbowSkeleton = false,
    MouseTracer = false,
    BoxColor = Color3.fromRGB(255, 0, 0),
    TracerColor = Color3.fromRGB(255, 0, 0),
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    BoxThickness = 1,
    TracerThickness = 1,
    SkeletonThickness = 1
}

local SkeletonPoints = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = getgenv().FOVThickness
FOVCircle.NumSides = 50
FOVCircle.Radius = getgenv().FOV
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.ZIndex = 999
FOVCircle.Transparency = 1
FOVCircle.Color = getgenv().FOVColor

local Window = OrionLib:MakeWindow({
    IntroText = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
    IntroIcon = "rbxassetid://15315284749",
    Name = "sxlent404 - " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. " | " .. identifyexecutor(),
    IntroToggleIcon = "rbxassetid://7734091286",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "sxlent404"
})

local ESPObjects = {}

local function CreateSkeletonLines()
    local Lines = {}
    for i = 1, #SkeletonPoints do
        local Line = Drawing.new("Line")
        Line.Thickness = ESPSettings.SkeletonThickness
        Line.Transparency = 1
        table.insert(Lines, Line)
    end
    return Lines
end

local function CreateESPObjects()
    local Box = Drawing.new("Square")
    Box.Thickness = ESPSettings.BoxThickness
    Box.Filled = false
    Box.Transparency = 1
    
    local Tracer = Drawing.new("Line")
    Tracer.Thickness = ESPSettings.TracerThickness
    Tracer.Transparency = 1
    
    local SkeletonLines = CreateSkeletonLines()
    
    return {
        Box = Box,
        Tracer = Tracer,
        Skeleton = SkeletonLines
    }
end

local function UpdateESP(player)
    if not ESPObjects[player] then
        ESPObjects[player] = CreateESPObjects()
    end
    
    local objects = ESPObjects[player]
    
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        objects.Box.Visible = false
        objects.Tracer.Visible = false
        for _, line in ipairs(objects.Skeleton) do
            line.Visible = false
        end
        return
    end

    local character = player.Character
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
    
    if not onScreen then
        objects.Box.Visible = false
        objects.Tracer.Visible = false
        for _, line in ipairs(objects.Skeleton) do
            line.Visible = false
        end
        return
    end

    if ESPSettings.BoxesEnabled then
        local rootPos = hrp.Position
        local boxSize = Vector2.new(4000 / vector.Z, 5000 / vector.Z)
        objects.Box.Size = boxSize
        objects.Box.Position = Vector2.new(vector.X - boxSize.X / 2, vector.Y - boxSize.Y / 2)
        objects.Box.Visible = true
        objects.Box.Thickness = ESPSettings.BoxThickness
        objects.Box.Color = ESPSettings.RainbowBoxes and Color3.fromHSV(tick() % 5 / 5, 1, 1) or ESPSettings.BoxColor
    else
        objects.Box.Visible = false
    end

    if ESPSettings.TracersEnabled then
        objects.Tracer.From = ESPSettings.MouseTracer and UserInputService:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        objects.Tracer.To = Vector2.new(vector.X, vector.Y)
        objects.Tracer.Visible = true
        objects.Tracer.Thickness = ESPSettings.TracerThickness
        objects.Tracer.Color = ESPSettings.RainbowTracers and Color3.fromHSV(tick() % 5 / 5, 1, 1) or ESPSettings.TracerColor
    else
        objects.Tracer.Visible = false
    end

    if ESPSettings.SkeletonEnabled then
        for i, point in ipairs(SkeletonPoints) do
            local p1 = character:FindFirstChild(point[1])
            local p2 = character:FindFirstChild(point[2])
            
            if p1 and p2 then
                local p1_pos, p1_visible = Camera:WorldToViewportPoint(p1.Position)
                local p2_pos, p2_visible = Camera:WorldToViewportPoint(p2.Position)
                
                if p1_visible and p2_visible then
                    objects.Skeleton[i].From = Vector2.new(p1_pos.X, p1_pos.Y)
                    objects.Skeleton[i].To = Vector2.new(p2_pos.X, p2_pos.Y)
                    objects.Skeleton[i].Thickness = ESPSettings.SkeletonThickness
                    objects.Skeleton[i].Visible = true
                    objects.Skeleton[i].Color = ESPSettings.RainbowSkeleton and Color3.fromHSV(tick() % 5 / 5, 1, 1) or ESPSettings.SkeletonColor
                else
                    objects.Skeleton[i].Visible = false
                end
            else
                objects.Skeleton[i].Visible = false
            end
        end
    else
        for _, line in ipairs(objects.Skeleton) do
            line.Visible = false
        end
    end
end

local function IsVisible(target)
    if not target or not target:FindFirstChild("Head") then return false end
    local Head = target.Head
    local CameraPosition = Camera.CFrame.Position
    local RayDirection = (Head.Position - CameraPosition).Unit * (Head.Position - CameraPosition).Magnitude
    local Ray = Ray.new(CameraPosition, RayDirection)
    local Hit, Position = workspace:FindPartOnRayWithIgnoreList(Ray, {LocalPlayer.Character}, false, true)
    return Hit and Hit:IsDescendantOf(target)
end

local function GetClosestPlayer()
    local Target = nil
    local MaxDistance = getgenv().MaxDistance
    local MaxFOV = getgenv().FOV
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("Head") 
            and Player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local Head = Player.Character.Head
            local Distance = (Head.Position - Camera.CFrame.Position).Magnitude
            local ScreenPoint = Camera:WorldToViewportPoint(Head.Position)
            local MousePosition = Vector2.new(Mouse.X, Mouse.Y)
            local Distance2D = (Vector2.new(ScreenPoint.X, ScreenPoint.Y) - MousePosition).Magnitude
            
            if Distance2D <= MaxFOV and Distance < MaxDistance and IsVisible(Player.Character) then
                Target = Player
                MaxDistance = Distance
                MaxFOV = Distance2D
            end
        end
    end
    return Target
end

local function UpdateFOVCircle()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = getgenv().FOV
    FOVCircle.Visible = getgenv().ShowFOV
    FOVCircle.Thickness = getgenv().FOVThickness
    
    if getgenv().RainbowFOV then
        local hue = tick() % 5 / 5
        FOVCircle.Color = Color3.fromHSV(hue, 1, 1)
    else
        FOVCircle.Color = getgenv().FOVColor
    end
end

local mainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local ESPTab = Window:MakeTab({
    Name = "ESP",
    Icon = "rbxassetid://4483345998"
})

mainTab:AddToggle({
    Name = "Silent Aim",
    Default = false,
    Callback = function(Value)
        getgenv().SilentAimEnabled = Value
    end
})

mainTab:AddToggle({
    Name = "Show FOV",
    Default = false,
    Callback = function(Value)
        getgenv().ShowFOV = Value
        FOVCircle.Visible = Value
    end
})

mainTab:AddToggle({
    Name = "Rainbow FOV",
    Default = false,
    Callback = function(Value)
        getgenv().RainbowFOV = Value
    end
})

mainTab:AddSlider({
    Name = "FOV",
    Min = 30,
    Max = 900,
    Default = 100,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    Callback = function(Value)
        getgenv().FOV = Value
        FOVCircle.Radius = Value
    end    
})

mainTab:AddSlider({
    Name = "FOV Thickness",
    Min = 1,
    Max = 10,
    Default = 2,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    Callback = function(Value)
        getgenv().FOVThickness = Value
        FOVCircle.Thickness = Value
    end    
})

mainTab:AddColorpicker({
    Name = "FOV Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        getgenv().FOVColor = Value
        FOVCircle.Color = Value
    end
})

local ESPSection = ESPTab:AddSection({Name = "ESP Settings"})
local BoxSection = ESPTab:AddSection({Name = "Box ESP"})
local TracerSection = ESPTab:AddSection({Name = "Tracer ESP"})
local SkeletonSection = ESPTab:AddSection({Name = "Skeleton ESP"})

ESPSection:AddToggle({
    Name = "ESP Enabled",
    Default = false,
    Callback = function(Value)
        ESPSettings.Enabled = Value
    end
})

BoxSection:AddToggle({
    Name = "Box ESP",
    Default = false,
    Callback = function(Value)
        ESPSettings.BoxesEnabled = Value
    end
})

BoxSection:AddToggle({
    Name = "Rainbow Boxes",
    Default = false,
    Callback = function(Value)
        ESPSettings.RainbowBoxes = Value
    end
})

BoxSection:AddColorpicker({
    Name = "Box Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        ESPSettings.BoxColor = Value
    end
})

BoxSection:AddSlider({
    Name = "Box Thickness",
    Min = 1,
    Max = 5,
    Default = 1,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    Callback = function(Value)
        ESPSettings.BoxThickness = Value
    end
})

TracerSection:AddToggle({
    Name = "Tracer ESP",
    Default = false,
    Callback = function(Value)
        ESPSettings.TracersEnabled = Value
    end
})

TracerSection:AddToggle({
    Name = "Mouse Tracers",
    Default = false,
    Callback = function(Value)
        ESPSettings.MouseTracer = Value
    end
})

TracerSection:AddToggle({
    Name = "Rainbow Tracers",
    Default = false,
    Callback = function(Value)
        ESPSettings.RainbowTracers = Value
    end
})

TracerSection:AddColorpicker({
    Name = "Tracer Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        ESPSettings.TracerColor = Value
    end
})

TracerSection:AddSlider({
    Name = "Tracer Thickness",
    Min = 1,
    Max = 5,
    Default = 1,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    Callback = function(Value)
        ESPSettings.TracerThickness = Value
    end
})

SkeletonSection:AddToggle({
    Name = "Skeleton ESP",
    Default = false,
    Callback = function(Value)
        ESPSettings.SkeletonEnabled = Value
    end
})

SkeletonSection:AddToggle({
    Name = "Rainbow Skeleton",
    Default = false,
    Callback = function(Value)
        ESPSettings.RainbowSkeleton = Value
    end
})

SkeletonSection:AddColorpicker({
    Name = "Skeleton Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        ESPSettings.SkeletonColor = Value
    end
})

SkeletonSection:AddSlider({
    Name = "Skeleton Thickness",
    Min = 1,
    Max = 5,
    Default = 1,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    Callback = function(Value)
        ESPSettings.SkeletonThickness = Value
    end
})

Mouse.Button1Down:Connect(function()
    if getgenv().SilentAimEnabled then
        local Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild("Head") then
            getgenv().OriginalCFrame = Camera.CFrame
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character.Head.Position)
        end
    end
end)

Mouse.Button1Up:Connect(function()
    if getgenv().SilentAimEnabled and getgenv().OriginalCFrame then
        Camera.CFrame = getgenv().OriginalCFrame
    end
end)

RunService.RenderStepped:Connect(function()
    if ESPSettings.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                UpdateESP(player)
            end
        end
    else
        for _, objects in pairs(ESPObjects) do
            objects.Box.Visible = false
            objects.Tracer.Visible = false
            for _, line in ipairs(objects.Skeleton) do
                line.Visible = false
            end
        end
    end
    UpdateFOVCircle()
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, object in pairs(ESPObjects[player]) do
            if typeof(object) == "table" then
                for _, line in ipairs(object) do
                    line:Remove()
                end
            else
                object:Remove()
            end
        end
        ESPObjects[player] = nil
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        if ESPSettings.Enabled then
            local esp = CreateESPObjects()
            ESPObjects[player] = esp
        end
        char:WaitForChild("Humanoid").Died:Connect(function()
            if ESPObjects[player] then
                for _, object in pairs(ESPObjects[player]) do
                    if typeof(object) == "table" then
                        for _, line in ipairs(object) do
                            line.Visible = false
                        end
                    else
                        object.Visible = false
                    end
                end
            end
        end)
    end)
end)

OrionLib:Init()
