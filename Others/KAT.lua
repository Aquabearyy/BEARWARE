if not game:IsLoaded() then
    game.Loaded:Wait()
end

local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/sxlent404/ModdedOrion/refs/heads/main/orion.lua'))()
local Window = OrionLib:MakeWindow({
    IntroText = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
    IntroIcon = "rbxassetid://15315284749",
    Name = "SilentHub - " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. " | " .. identifyexecutor(),
    IntroToggleIcon = "rbxassetid://7734091286",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "sxlent404"
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")

-- ESP Settings
getgenv().ESPEnabled = false
getgenv().BoxESPEnabled = false
getgenv().TracersEnabled = false
getgenv().RainbowBoxes = false
getgenv().RainbowTracers = false
getgenv().MouseTracer = false
getgenv().BoxColor = Color3.fromRGB(255, 0, 0)
getgenv().TracerColor = Color3.fromRGB(255, 0, 0)
getgenv().BoxThickness = 1
getgenv().TracerThickness = 1

-- Box ESP Objects
local ESPObjects = {}

local function CreateESPObjects()
    local Box = Drawing.new("Square")
    Box.Thickness = getgenv().BoxThickness
    Box.Filled = false
    Box.Transparency = 1
    
    local Tracer = Drawing.new("Line")
    Tracer.Thickness = getgenv().TracerThickness
    Tracer.Transparency = 1
    
    return {
        Box = Box,
        Tracer = Tracer
    }
end

local function UpdateBoxESP(player)
    if not ESPObjects[player] then
        ESPObjects[player] = CreateESPObjects()
    end
    
    local objects = ESPObjects[player]
    
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        objects.Box.Visible = false
        objects.Tracer.Visible = false
        return
    end

    local character = player.Character
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
    
    if not onScreen then
        objects.Box.Visible = false
        objects.Tracer.Visible = false
        return
    end

    if getgenv().BoxESPEnabled then
        local rootPos = hrp.Position
        local boxSize = Vector2.new(4000 / vector.Z, 5000 / vector.Z)
        objects.Box.Size = boxSize
        objects.Box.Position = Vector2.new(vector.X - boxSize.X / 2, vector.Y - boxSize.Y / 2)
        objects.Box.Visible = true
        objects.Box.Thickness = getgenv().BoxThickness
        if getgenv().RainbowBoxes then
            objects.Box.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        else
            objects.Box.Color = getgenv().BoxColor
        end
    else
        objects.Box.Visible = false
    end

    if getgenv().TracersEnabled then
        objects.Tracer.From = getgenv().MouseTracer and UserInputService:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        objects.Tracer.To = Vector2.new(vector.X, vector.Y)
        objects.Tracer.Visible = true
        objects.Tracer.Thickness = getgenv().TracerThickness
        if getgenv().RainbowTracers then
            objects.Tracer.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        else
            objects.Tracer.Color = getgenv().TracerColor
        end
    else
        objects.Tracer.Visible = false
    end
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

local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://9178976271",
    PremiumOnly = false
})

local AimbotTab = Window:MakeTab({
    Name = "Aimbot",
    Icon = "rbxassetid://4458889192",
    PremiumOnly = false
})

local ESPTab = Window:MakeTab({
    Name = "ESP",
    Icon = "rbxassetid://4483345998"
})

local CameraSection = MainTab:AddSection({
    Name = "Camera"
})

CameraSection:AddSlider({
    Name = "Camera FOV",
    Min = 30,
    Max = 120,
    Default = 70,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "fov",
    Callback = function(Value)
        Camera.FieldOfView = Value
    end    
})

local TriggerSection = MainTab:AddSection({
    Name = "Triggerbot"
})

TriggerSection:AddToggle({
    Name = "Triggerbot",
    Default = false,
    Callback = function(Value)
        _G.Triggerbot = Value
        while _G.Triggerbot and task.wait() do
            local Target = Mouse.Target
            if Target and Target.Parent and Target.Parent:FindFirstChild("Humanoid") then
                local Player = Players:GetPlayerFromCharacter(Target.Parent)
                if Player and Player ~= LocalPlayer then
                    mouse1press()
                    task.wait()
                    mouse1release()
                end
            end
        end
    end    
})

AimbotTab:AddLabel("Go in First Person or Shiftlock for Aimbot to work!")

local Enabled = false
local Smoothness = 0.5
local BodyPart = "HumanoidRootPart"
local WallCheck = false

local function getClosestPlayer()
    local shortestDistance = math.huge
    local closestPlayer = nil
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(BodyPart) then
            local magnitude = (LocalPlayer.Character[BodyPart].Position - player.Character[BodyPart].Position).Magnitude
            
            if WallCheck then
                local ray = Ray.new(Camera.CFrame.Position, (player.Character[BodyPart].Position - Camera.CFrame.Position).Unit * magnitude)
                local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, player.Character})
                if hit then continue end
            end
            
            if magnitude < shortestDistance then
                shortestDistance = magnitude
                closestPlayer = player
            end
        end
    end
    return closestPlayer
end

local AimbotSection = AimbotTab:AddSection({
    Name = "Aimbot Settings"
})

AimbotSection:AddToggle({
    Name = "Lock Enabled",
    Default = false,
    Callback = function(Value)
        Enabled = Value
    end    
})

AimbotSection:AddToggle({
    Name = "Wall Check",
    Default = false,
    Callback = function(Value)
        WallCheck = Value
    end    
})

AimbotSection:AddDropdown({
    Name = "Target Part",
    Default = "HumanoidRootPart",
    Options = {"HumanoidRootPart", "Head"},
    Callback = function(Value)
        BodyPart = Value
    end    
})

AimbotSection:AddSlider({
    Name = "Smoothness",
    Min = 0,
    Max = 100,
    Default = 50,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "smooth",
    Callback = function(Value)
        Smoothness = Value/100
    end    
})

local HighlightSection = ESPTab:AddSection({
    Name = "Highlight ESP"
})

HighlightSection:AddToggle({
    Name = "Highlight ESP",
    Default = false,
    Callback = function(Value)
        getgenv().ESPEnabled = Value
        RefreshESP()
    end
})

local BoxSection = ESPTab:AddSection({
    Name = "Box ESP"
})

BoxSection:AddToggle({
    Name = "Box ESP",
    Default = false,
    Callback = function(Value)
        getgenv().BoxESPEnabled = Value
    end
})

BoxSection:AddToggle({
    Name = "Rainbow Boxes",
    Default = false,
    Callback = function(Value)
        getgenv().RainbowBoxes = Value
    end
})

BoxSection:AddColorpicker({
    Name = "Box Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        getgenv().BoxColor = Value
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
        getgenv().BoxThickness = Value
    end    
})

local TracerSection = ESPTab:AddSection({
    Name = "Tracer ESP"
})

TracerSection:AddToggle({
    Name = "Tracer ESP",
    Default = false,
    Callback = function(Value)
        getgenv().TracersEnabled = Value
    end
})

TracerSection:AddToggle({
    Name = "Mouse Tracers",
    Default = false,
    Callback = function(Value)
        getgenv().MouseTracer = Value
    end
})

TracerSection:AddToggle({
    Name = "Rainbow Tracers",
    Default = false,
    Callback = function(Value)
        getgenv().RainbowTracers = Value
    end
})

TracerSection:AddColorpicker({
    Name = "Tracer Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        getgenv().TracerColor = Value
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
        getgenv().TracerThickness = Value
    end    
})

RunService.RenderStepped:Connect(function()
    if Enabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(BodyPart) then
            local targetPos = target.Character[BodyPart].Position
            local currentPos = Camera.CFrame
            local newCFrame = currentPos:Lerp(CFrame.new(currentPos.Position, targetPos), Smoothness)
            Camera.CFrame = newCFrame
        end
    end
    
    if getgenv().ESPEnabled then
        RefreshESP()
    end
    
    if getgenv().BoxESPEnabled or getgenv().TracersEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                UpdateBoxESP(player)
            end
        end
    else
        for _, objects in pairs(ESPObjects) do
            objects.Box.Visible = false
            objects.Tracer.Visible = false
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if player.Character and player.Character:FindFirstChild("SilentHighlight") then
        player.Character.SilentHighlight:Destroy()
    end
    
    if ESPObjects[player] then
        for _, object in pairs(ESPObjects[player]) do
            object:Remove()
        end
        ESPObjects[player] = nil
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        if getgenv().ESPEnabled then
            ApplyESP(player)
        end
        if getgenv().BoxESPEnabled or getgenv().TracersEnabled then
            if ESPObjects[player] then
                for _, object in pairs(ESPObjects[player]) do
                    object:Remove()
                end
            end
            ESPObjects[player] = CreateESPObjects()
        end
        char:WaitForChild("Humanoid").Died:Connect(function()
            if char:FindFirstChild("SilentHighlight") then
                char.SilentHighlight:Destroy()
            end
            if ESPObjects[player] then
                for _, object in pairs(ESPObjects[player]) do
                    object.Visible = false
                end
            end
        end)
    end)
end)

OrionLib:Init()
