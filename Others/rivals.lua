if not game:IsLoaded() then
    game.Loaded:Wait()
end

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

getgenv().SilentAimEnabled = false
getgenv().ESPEnabled = false
getgenv().MaxDistance = 1000
getgenv().FOV = 100
getgenv().ShowFOV = false
getgenv().RainbowFOV = false
getgenv().FOVColor = Color3.fromRGB(255, 255, 255)
getgenv().FOVThickness = 2

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

local function ApplyESP(plr)
    if not plr.Character then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "SilentHighlight"
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Parent = plr.Character
end

local function RefreshESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character then
                local highlight = player.Character:FindFirstChild("SilentHighlight")
                if getgenv().ESPEnabled then
                    if not highlight then
                        ApplyESP(player)
                    end
                else
                    if highlight then
                        highlight:Destroy()
                    end
                end
            end
        end
    end
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

ESPTab:AddToggle({
    Name = "Player ESP",
    Default = false,
    Callback = function(Value)
        getgenv().ESPEnabled = Value
        RefreshESP()
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
    if getgenv().ESPEnabled then
        RefreshESP()
    end
    UpdateFOVCircle()
end)

Players.PlayerRemoving:Connect(function(player)
    if player.Character and player.Character:FindFirstChild("SilentHighlight") then
        player.Character.SilentHighlight:Destroy()
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        if getgenv().ESPEnabled then
            ApplyESP(player)
        end
        char:WaitForChild("Humanoid").Died:Connect(function()
            if char:FindFirstChild("SilentHighlight") then
                char.SilentHighlight:Destroy()
            end
        end)
    end)
end)

OrionLib:Init()
