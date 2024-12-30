local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local Window = OrionLib:MakeWindow({Name = "Arsenal Script", HidePremium = false, SaveConfig = true, ConfigFolder = "ArsenalConfig"})

local MainTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local Section = MainTab:AddSection({Name = "Gun Mods"})

local SettingsInfinite = false
Section:AddToggle({
    Name = "Infinite Ammo",
    Default = false,
    Flag = "InfAmmo",
    Callback = function(Value)
        SettingsInfinite = Value
        if SettingsInfinite then
            game:GetService("RunService").Stepped:connect(function()
                pcall(function()
                    if SettingsInfinite then
                        local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
                        playerGui.GUI.Client.Variables.ammocount.Value = 99
                        playerGui.GUI.Client.Variables.ammocount2.Value = 99
                    end
                end)
            end)
        end
    end    
})

Section:AddToggle({
    Name = "Fast Reload",
    Default = false,
    Flag = "FastReload",
    Callback = function(Value)
        for _, v in pairs(game.ReplicatedStorage.Weapons:GetChildren()) do
            if v:FindFirstChild("ReloadTime") then
                v.ReloadTime.Value = Value and 0.01 or 0.8
            end
            if v:FindFirstChild("EReloadTime") then
                v.EReloadTime.Value = Value and 0.01 or 0.8
            end
        end
    end    
})

Section:AddToggle({
    Name = "Fast Fire Rate",
    Default = false,
    Flag = "FastFire",
    Callback = function(Value)
        for _, v in pairs(game.ReplicatedStorage.Weapons:GetDescendants()) do
            if v.Name == "FireRate" or v.Name == "BFireRate" then
                v.Value = Value and 0.02 or 0.8
            end
        end
    end    
})

Section:AddToggle({
    Name = "Always Auto",
    Default = false,
    Flag = "AlwaysAuto",
    Callback = function(Value)
        for _, v in pairs(game.ReplicatedStorage.Weapons:GetDescendants()) do
            if v.Name == "Auto" or v.Name == "AutoFire" or v.Name == "Automatic" or v.Name == "AutoShoot" or v.Name == "AutoGun" then
                v.Value = Value
            end
        end
    end    
})

Section:AddToggle({
    Name = "No Spread",
    Default = false,
    Flag = "NoSpread",
    Callback = function(Value)
        for _, v in pairs(game.ReplicatedStorage.Weapons:GetDescendants()) do
            if v.Name == "MaxSpread" or v.Name == "Spread" or v.Name == "SpreadControl" then
                v.Value = Value and 0 or 1
            end
        end
    end    
})

Section:AddToggle({
    Name = "No Recoil",
    Default = false,
    Flag = "NoRecoil",
    Callback = function(Value)
        for _, v in pairs(game.ReplicatedStorage.Weapons:GetDescendants()) do
            if v.Name == "RecoilControl" or v.Name == "Recoil" then
                v.Value = Value and 0 or 1
            end
        end
    end    
})

local rainbowEnabled = false
local c = 1
local function zigzag(X) return math.acos(math.cos(X * math.pi)) / math.pi end

Section:AddToggle({
    Name = "Rainbow Gun",
    Default = false,
    Flag = "RainbowGun",
    Callback = function(Value)
        rainbowEnabled = Value
    end    
})

game:GetService("RunService").RenderStepped:Connect(function() 
    if game.Workspace.Camera:FindFirstChild('Arms') and rainbowEnabled then 
        for _, v in pairs(game.Workspace.Camera.Arms:GetDescendants()) do 
            if v.ClassName == 'MeshPart' then 
                v.Color = Color3.fromHSV(zigzag(c), 1, 1)
                c = c + .0001
            end 
        end 
    end 
end)

local ChatTab = Window:MakeTab({Name = "Chat", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local ChatSection = ChatTab:AddSection({Name = "Chat Features"})

ChatSection:AddToggle({Name = "IsChad", Default = false, Flag = "IsChad", Callback = function(Value)
    if game.Players.LocalPlayer:FindFirstChild('IsChad') then game.Players.LocalPlayer.IsChad:Destroy() end
    if Value then Instance.new('IntValue', game.Players.LocalPlayer).Name = "IsChad" end
end})

ChatSection:AddToggle({Name = "VIP", Default = false, Flag = "VIP", Callback = function(Value)
    if game.Players.LocalPlayer:FindFirstChild('VIP') then game.Players.LocalPlayer.VIP:Destroy() end
    if Value then Instance.new('IntValue', game.Players.LocalPlayer).Name = "VIP" end
end})

ChatSection:AddToggle({Name = "OldVIP", Default = false, Flag = "OldVIP", Callback = function(Value)
    if game.Players.LocalPlayer:FindFirstChild('OldVIP') then game.Players.LocalPlayer.OldVIP:Destroy() end
    if Value then Instance.new('IntValue', game.Players.LocalPlayer).Name = "OldVIP" end
end})

ChatSection:AddToggle({Name = "Romin", Default = false, Flag = "Romin", Callback = function(Value)
    if game.Players.LocalPlayer:FindFirstChild('Romin') then game.Players.LocalPlayer.Romin:Destroy() end
    if Value then Instance.new('IntValue', game.Players.LocalPlayer).Name = "Romin" end
end})

ChatSection:AddToggle({Name = "IsAdmin", Default = false, Flag = "IsAdmin", Callback = function(Value)
    if game.Players.LocalPlayer:FindFirstChild('IsAdmin') then game.Players.LocalPlayer.IsAdmin:Destroy() end
    if Value then Instance.new('IntValue', game.Players.LocalPlayer).Name = "IsAdmin" end
end})

local MiscTab = Window:MakeTab({Name = "Misc", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local MiscSection = MiscTab:AddSection({Name = "Silent Aim"})

local Settings = {
    SilentAimEnabled = false,
    WallCheck = true,
    AliveCheck = true,
    TeamCheck = true
}

local CurrentCameraState = nil

local function IsVisible(player)
    if not Settings.WallCheck then return true end
    if not player or not player.Character or not player.Character:FindFirstChild("Head") then return false end
    
    local Character = player.Character
    local Head = Character.Head
    local RaycastParams = RaycastParams.new()
    RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    RaycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Character}
    RaycastParams.IgnoreWater = true
    
    local StartPosition = Camera.CFrame.Position
    local Direction = (Head.Position - StartPosition).Unit * (Head.Position - StartPosition).Magnitude
    local Result = workspace:Raycast(StartPosition, Direction, RaycastParams)
    
    return not Result or Result.Instance:IsDescendantOf(Character)
end

local function IsTeammate(player)
    if not Settings.TeamCheck then return false end
    if not player:FindFirstChild("Status") or not player.Status:FindFirstChild("Team") then return false end
    if player.Status.Team.Value == "Spectator" then return true end
    return player.Status.Team.Value == LocalPlayer.Status.Team.Value
end

local function IsAlive(player)
    if not Settings.AliveCheck then return true end
    return player.Character 
        and player.Character:FindFirstChild("Humanoid") 
        and player.Character:FindFirstChild("Head")
        and player.Character.Humanoid.Health > 0
end

local function GetClosestPlayer()
    local ClosestPlayer = nil
    local ShortestDistance = math.huge
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player:FindFirstChild("Status") and Player.Status:FindFirstChild("Team") and Player.Status.Team.Value ~= "Spectator" and not IsTeammate(Player) and IsAlive(Player) and IsVisible(Player) then
            local Head = Player.Character.Head
            local Direction = (Head.Position - Camera.CFrame.Position).Unit
            local Magnitude = (Head.Position - Camera.CFrame.Position).Magnitude
            
            if Magnitude <= 250 then
                local Dot = Camera.CFrame.LookVector:Dot(Direction)
                
                if Dot > 0.9 then
                    if Magnitude < ShortestDistance then
                        ClosestPlayer = Player
                        ShortestDistance = Magnitude
                    end
                end
            end
        end
    end
    return ClosestPlayer
end

MiscSection:AddToggle({
    Name = "Silent Aim",
    Default = false,
    Flag = "SilentAim",
    Callback = function(Value)
        Settings.SilentAimEnabled = Value
    end    
})

MiscSection:AddToggle({
    Name = "Wall Check",
    Default = true,
    Flag = "WallCheck",
    Callback = function(Value)
        Settings.WallCheck = Value
    end    
})

MiscSection:AddToggle({
    Name = "Team Check",
    Default = true,
    Flag = "TeamCheck",
    Callback = function(Value)
        Settings.TeamCheck = Value
    end    
})

MiscSection:AddToggle({
    Name = "Alive Check",
    Default = true,
    Flag = "AliveCheck",
    Callback = function(Value)
        Settings.AliveCheck = Value
    end    
})

Mouse.Button1Down:Connect(function()
    if Settings.SilentAimEnabled then
        local Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild("Head") then
            local TargetHead = Target.Character.Head
            CurrentCameraState = Camera.CFrame
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, TargetHead.Position)
        end
    end
end)

Mouse.Button1Up:Connect(function()
    if Settings.SilentAimEnabled and CurrentCameraState then
        Camera.CFrame = CurrentCameraState
    end
end)

local MovementSection = MiscTab:AddSection({Name = "Movement"})

local BHopSettings = {
    Enabled = false,
    Speed = 1.8,
    Height = 0.15,
    AutoJump = true
}

local function GetMoveVector()
    local character = LocalPlayer.Character
    if not character then return Vector3.new() end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return Vector3.new() end
    
    local moveDirection = humanoid.MoveDirection
    if moveDirection.Magnitude == 0 then return Vector3.new() end
    
    local cameraLook = Camera.CFrame.LookVector
    local flatLook = Vector3.new(cameraLook.X, 0, cameraLook.Z).Unit
    
    return moveDirection * BHopSettings.Speed
end

local lastJump = 0

local function BunnyHop()
    while BHopSettings.Enabled do
        local character = LocalPlayer.Character
        if not character then 
            task.wait()
            continue 
        end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart then
            local moveVector = GetMoveVector()
            local currentTime = tick()
            
            if moveVector.Magnitude > 0 then
                if humanoid.FloorMaterial == Enum.Material.Air then
                    rootPart.CFrame = rootPart.CFrame + moveVector * 0.08
                    rootPart.Velocity = Vector3.new(
                        rootPart.Velocity.X,
                        math.min(rootPart.Velocity.Y + BHopSettings.Height, 2),
                        rootPart.Velocity.Z
                    )
                else
                    if BHopSettings.AutoJump and currentTime - lastJump > 0.1 then
                        humanoid.Jump = true
                        lastJump = currentTime
                    end
                end
                
                local lookVector = Camera.CFrame.LookVector
                local moveDir = moveVector.Unit
                local dot = lookVector.X * moveDir.X + lookVector.Z * moveDir.Z
                
                if dot > 0 then
                    rootPart.CFrame = rootPart.CFrame + moveVector * (0.05 * dot)
                end
            end
        end
        RunService.RenderStepped:Wait()
    end
end

MovementSection:AddToggle({
    Name = "Enhanced Bunny Hop",
    Default = false,
    Flag = "BHop",
    Callback = function(Value)
        BHopSettings.Enabled = Value
        if Value then
            coroutine.wrap(BunnyHop)()
        end
    end
})

MovementSection:AddSlider({
    Name = "BHop Speed",
    Min = 1,
    Max = 3,
    Default = 1.8,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.1,
    ValueName = "x",
    Callback = function(Value)
        BHopSettings.Speed = Value
    end    
})

MovementSection:AddSlider({
    Name = "Jump Height",
    Min = 0.1,
    Max = 0.3,
    Default = 0.15,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.01,
    ValueName = "studs",
    Callback = function(Value)
        BHopSettings.Height = Value
    end    
})

OrionLib:Init()
