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
getgenv().AimbotEnabled = false
getgenv().ESPEnabled = false
getgenv().AutoStabEnabled = false
getgenv().AutoStabKeybind = Enum.KeyCode.X
getgenv().AutoStabHolding = false
getgenv().Smoothness = 0.6
getgenv().MaxDistance = 1000
getgenv().AimbotActivation = "Right Click"

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
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("Head") 
            and Player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local Head = Player.Character.Head
            local Distance = (Head.Position - Camera.CFrame.Position).Magnitude
            if Distance < MaxDistance and IsVisible(Player.Character) then
                Target = Player
                MaxDistance = Distance
            end
        end
    end
    return Target
end

local function TeleportBehindPlayer(player, isReturning)
    if not player or not player.Character or not LocalPlayer.Character then return end
    local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not myRoot then return end
    if not isReturning then
        getgenv().OriginalStabPosition = myRoot.CFrame
        local targetCFrame = targetRoot.CFrame
        local behindPosition = targetCFrame * CFrame.new(0, 0, 3)
        myRoot.CFrame = behindPosition
    else
        if getgenv().OriginalStabPosition then
            myRoot.CFrame = getgenv().OriginalStabPosition
            getgenv().OriginalStabPosition = nil
        end
    end
end

local function ApplyESP(plr)
    if not plr.Character then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "Totally_NOT_Esp"
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
                local highlight = player.Character:FindFirstChild("Totally_NOT_Esp")
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

local mainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local AimbotTab = Window:MakeTab({
    Name = "Aimbot",
    Icon = "rbxassetid://4483345998"
})

local ESPTab = Window:MakeTab({
    Name = "ESP",
    Icon = "rbxassetid://4483345998"
})

AimbotTab:AddLabel("Aimbots Possibly Detected!")

AimbotTab:AddToggle({
    Name = "Silent Aim",
    Default = false,
    Callback = function(Value)
        getgenv().SilentAimEnabled = Value
    end
})

AimbotTab:AddToggle({
    Name = "Aimbot",
    Default = false,
    Callback = function(Value)
        getgenv().AimbotEnabled = Value
    end
})

mainTab:AddToggle({
    Name = "Auto-Stab",
    Default = false,
    Callback = function(Value)
        getgenv().AutoStabEnabled = Value
    end
})

mainTab:AddBind({
    Name = "Auto-Stab Keybind",
    Default = Enum.KeyCode.X,
    Hold = true,
    Callback = function(Started)
        if getgenv().AutoStabEnabled then
            getgenv().AutoStabHolding = Started
            if Started then
                while getgenv().AutoStabHolding do
                    local Target = GetClosestPlayer()
                    if Target then
                        TeleportBehindPlayer(Target, false)
                    end
                    task.wait()
                end
            else
                TeleportBehindPlayer(nil, true)
            end
        end
    end
})

AimbotTab:AddDropdown({
    Name = "Aimbot Activation",
    Default = "Right Click",
    Options = {"Right Click", "Left Click", "Both"},
    Callback = function(Value)
        getgenv().AimbotActivation = Value
    end
})

AimbotTab:AddSlider({
    Name = "Aimbot Smoothness",
    Min = 0.1,
    Max = 1,
    Default = 0.6,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.1,
    Callback = function(Value)
        getgenv().Smoothness = Value
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

local AimbotActive = false

Mouse.Button1Down:Connect(function()
    if getgenv().SilentAimEnabled then
        local Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild("Head") then
            getgenv().OriginalCFrame = Camera.CFrame
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character.Head.Position)
        end
    end
    if getgenv().AimbotEnabled and (getgenv().AimbotActivation == "Left Click" or getgenv().AimbotActivation == "Both") then
        AimbotActive = true
    end
end)

Mouse.Button1Up:Connect(function()
    if getgenv().SilentAimEnabled and getgenv().OriginalCFrame then
        Camera.CFrame = getgenv().OriginalCFrame
    end
    if getgenv().AimbotActivation == "Left Click" or getgenv().AimbotActivation == "Both" then
        AimbotActive = false
    end
end)

Mouse.Button2Down:Connect(function()
    if getgenv().AimbotEnabled and (getgenv().AimbotActivation == "Right Click" or getgenv().AimbotActivation == "Both") then
        AimbotActive = true
    end
end)

Mouse.Button2Up:Connect(function()
    if getgenv().AimbotActivation == "Right Click" or getgenv().AimbotActivation == "Both" then
        AimbotActive = false
    end
end)

RunService.RenderStepped:Connect(function()
    if AimbotActive and getgenv().AimbotEnabled then
        local Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild("Head") then
            local TargetPos = Target.Character.Head.Position
            local TargetCFrame = CFrame.new(Camera.CFrame.Position, TargetPos)
            Camera.CFrame = Camera.CFrame:Lerp(TargetCFrame, getgenv().Smoothness)
        end
    end
    if getgenv().AutoStabHolding and getgenv().AutoStabEnabled then
        local Target = GetClosestPlayer()
        if Target then
            TeleportBehindPlayer(Target, false)
        else
            TeleportBehindPlayer(nil, true)
        end
    end
    if getgenv().ESPEnabled then
        RefreshESP()
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if player.Character and player.Character:FindFirstChild("Totally_NOT_Esp") then
        player.Character.Totally_NOT_Esp:Destroy()
    end
    if getgenv().AutoStabHolding and getgenv().OriginalStabPosition then
        TeleportBehindPlayer(nil, true)
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        if getgenv().ESPEnabled then
            ApplyESP(player)
        end
        char:WaitForChild("Humanoid").Died:Connect(function()
            if getgenv().AutoStabHolding and getgenv().OriginalStabPosition then
                local currentTarget = GetClosestPlayer()
                if not currentTarget then
                    TeleportBehindPlayer(nil, true)
                end
            end
            if char:FindFirstChild("Totally_NOT_Esp") then
                char.Totally_NOT_Esp:Destroy()
            end
        end)
    end)
end)

OrionLib:Init()
