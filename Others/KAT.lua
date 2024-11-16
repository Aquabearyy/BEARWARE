if not game:IsLoaded() then
    game.Loaded:Wait()
end

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
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

MainTab:AddSlider({
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

MainTab:AddToggle({
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

AimbotTab:AddToggle({
    Name = "Lock Enabled",
    Default = false,
    Callback = function(Value)
        Enabled = Value
    end    
})

AimbotTab:AddToggle({
    Name = "Wall Check",
    Default = false,
    Callback = function(Value)
        WallCheck = Value
    end    
})

AimbotTab:AddDropdown({
    Name = "Target Part",
    Default = "HumanoidRootPart",
    Options = {"HumanoidRootPart", "Head"},
    Callback = function(Value)
        BodyPart = Value
    end    
})

AimbotTab:AddSlider({
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
end)

OrionLib:Init()
