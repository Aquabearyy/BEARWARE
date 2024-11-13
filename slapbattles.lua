if not game:IsLoaded() then
    game.Loaded:Wait()
end

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local Window = OrionLib:MakeWindow({
    IntroText = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
    IntroIcon = "rbxassetid://15315284749",
    Name = "sxlent404 - " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. " | " .. identifyexecutor(),
    IntroToggleIcon = "rbxassetid://7734091286",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "sxlent404"
})

local mainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local antiTab = Window:MakeTab({
    Name = "Anti",
    Icon = "rbxassetid://13793170713",
    PremiumOnly = false
})

local badgesTab = Window:MakeTab({
    Name = "Badges",
    Icon = "rbxassetid://16170504068",
    PremiumOnly = false
})

local teleportCFrame = CFrame.new(-6.7, -5.2, 1.9, -0.1, -0.0, -0.9, -0.0, 0.9, -0.0, 0.9, -0.0, -0.1)

antiTab:AddToggle({
    Name = "Anti-Void",
    Default = false,
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        local connection
        
        if Value then
            connection = game:GetService("RunService").Heartbeat:Connect(function()
                if player.Character and 
                   player.Character:FindFirstChild("HumanoidRootPart") and 
                   player.Character.HumanoidRootPart.Position.Y < -25 then
                    player.Character:SetPrimaryPartCFrame(teleportCFrame)
                end
            end)
        else
            if connection then
                connection:Disconnect()
            end
        end
    end    
})

badgesTab:AddButton({
    Name = "Get Lamp Glove",
    Default = false,
    Callback = function()
        local player = game.Players.LocalPlayer
        local leaderstats = player:FindFirstChild("leaderstats")
        local gloveValue = leaderstats and leaderstats.Glove
        local slapsValue = leaderstats and leaderstats.Slaps
        local teleport1 = workspace.Lobby.Teleport1
        local zzzGlove = workspace.Lobby.ZZZZZZZ
        local badgeId = 490455814138437
        
        local hasBadge = game:GetService("BadgeService"):UserHasBadgeAsync(player.UserId, badgeId)
        if hasBadge then
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "You already have the Lamp Glove badge.",
                Image = "rbxassetid://7733658504",
                Time = 5
            })
            return
        end

        if slapsValue.Value < 70 then
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "You need at least 70 slaps to proceed.",
                Image = "rbxassetid://7733658504",
                Time = 5
            })
            return
        end

        if gloveValue.Value ~= "ZZZZZZZ" then
            local clickDetector = zzzGlove:FindFirstChild("ClickDetector")
            if clickDetector then
                repeat
                    task.wait()
                    fireclickdetector(clickDetector)
                until gloveValue.Value == "ZZZZZZZ"
            else
                warn("ClickDetector not found on ZZZZZZZ glove.")
                return
            end
        end

        if not workspace:FindFirstChild(player.Name) or not workspace[player.Name]:FindFirstChild("regulararena") then
            teleport1.CanCollide = false
            player.Character:SetPrimaryPartCFrame(teleport1.CFrame)
            task.wait(0.5)
            teleport1.CanCollide = true
        end

        repeat
            task.wait()
            game:GetService("ReplicatedStorage").nightmare:FireServer("LightBroken")
        until game:GetService("BadgeService"):UserHasBadgeAsync(player.UserId, badgeId)
        
        OrionLib:MakeNotification({
            Name = "Success",
            Content = "You have obtained the Lamp Glove badge!",
            Image = "rbxassetid://7733658504",
            Time = 5
        })
    end
})

antiTab:AddToggle({
    Name = "Anti Ragdoll",
    Default = false,
    Callback = function(Value)
        _G.AntiRagdoll = Value
        while _G.AntiRagdoll and task.wait() do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if workspace[player.Name]:FindFirstChild("Ragdolled") and workspace[player.Name].Ragdolled.Value == true then
                    player.Character.HumanoidRootPart.Anchored = true
                else
                    player.Character.HumanoidRootPart.Anchored = false
                end
            end
        end
    end    
})

mainTab:AddButton({
    Name = "Free All Animations",
    Callback = function()
        Floss = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(game.ReplicatedStorage.AnimationPack.Floss, game.Players.LocalPlayer.Character.Humanoid)
        Groove = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(game.ReplicatedStorage.AnimationPack.Groove, game.Players.LocalPlayer.Character.Humanoid)
        Headless = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(game.ReplicatedStorage.AnimationPack.Headless, game.Players.LocalPlayer.Character.Humanoid)
        Helicopter = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(game.ReplicatedStorage.AnimationPack.Helicopter, game.Players.LocalPlayer.Character.Humanoid)
        Kick = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(game.ReplicatedStorage.AnimationPack.Kick, game.Players.LocalPlayer.Character.Humanoid)
        L = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(game.ReplicatedStorage.AnimationPack.L, game.Players.LocalPlayer.Character.Humanoid)
        Laugh = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(game.ReplicatedStorage.AnimationPack.Laugh, game.Players.LocalPlayer.Character.Humanoid)
        Parker = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(game.ReplicatedStorage.AnimationPack.Parker, game.Players.LocalPlayer.Character.Humanoid)
        Spasm = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(game.ReplicatedStorage.AnimationPack.Spasm, game.Players.LocalPlayer.Character.Humanoid)
        Thriller = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(game.ReplicatedStorage.AnimationPack.Thriller, game.Players.LocalPlayer.Character.Humanoid)
        
        game.Players.LocalPlayer.Chatted:connect(function(msg)
            if game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if string.lower(msg) == "/e floss" then Floss:Play()
                elseif string.lower(msg) == "/e groove" then Groove:Play()
                elseif string.lower(msg) == "/e headless" then Headless:Play()
                elseif string.lower(msg) == "/e helicopter" then Helicopter:Play()
                elseif string.lower(msg) == "/e kick" then Kick:Play()
                elseif string.lower(msg) == "/e l" then L:Play()
                elseif string.lower(msg) == "/e laugh" then Laugh:Play()
                elseif string.lower(msg) == "/e parker" then Parker:Play()
                elseif string.lower(msg) == "/e spasm" then Spasm:Play()
                elseif string.lower(msg) == "/e thriller" then Thriller:Play()
                end
            end
        end)
        
        game:GetService("RunService").Heartbeat:Connect(function()
            local EP = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
            if EP and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
               (Floss.IsPlaying or Groove.IsPlaying or Headless.IsPlaying or Helicopter.IsPlaying or 
                Kick.IsPlaying or L.IsPlaying or Laugh.IsPlaying or Parker.IsPlaying or 
                Spasm.IsPlaying or Thriller.IsPlaying) then
                local Magnitude = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - EP).Magnitude
                if Magnitude > 1 then
                    Floss:Stop()
                    Groove:Stop()
                    Headless:Stop()
                    Helicopter:Stop()
                    Kick:Stop()
                    L:Stop()
                    Laugh:Stop()
                    Parker:Stop()
                    Spasm:Stop()
                    Thriller:Stop()
                end
            end
        end)
    end    
})

mainTab:AddButton({
    Name = "Get Free Titan Glove",
    Callback = function()
        for i, v in pairs(game:GetService("ReplicatedStorage")._NETWORK:GetChildren()) do
            if v.Name:find("{") then
                local args = {[1] = "Titan"}
                if v:IsA("RemoteEvent") then
                    v:FireServer(unpack(args))
                elseif v:IsA("RemoteFunction") then
                    local result = v:InvokeServer(unpack(args))
                end
            end
        end
    end    
})

mainTab:AddButton({
    Name = "No Cooldown",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local tool = character:FindFirstChildOfClass("Tool") or player.Backpack:FindFirstChildOfClass("Tool")
        
        while character.Humanoid.Health ~= 0 do
            local localscript = tool:FindFirstChildOfClass("LocalScript")
            local localscriptclone = localscript:Clone()
            localscriptclone = localscript:Clone()
            localscriptclone:Clone()
            localscript:Destroy()
            localscriptclone.Parent = tool
            wait(0.1)
        end
    end    
})

local localTab = Window:MakeTab({
    Name = "Local",
    Icon = "rbxassetid://9086582404",
    PremiumOnly = false
})

localTab:AddSlider({
    Name = "WalkSpeed",
    Min = 0,
    Max = 500,
    Default = 20,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(value)
        _G.WalkSpeedValue = value
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end    
})

localTab:AddToggle({
    Name = "Auto Set WalkSpeed",
    Default = false,
    Callback = function(Value)
        _G.WalkSpeedToggle = Value
        while _G.WalkSpeedToggle do
            if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = _G.WalkSpeedValue
            end
            task.wait()
        end
    end    
})

localTab:AddSlider({
    Name = "JumpPower",
    Min = 0,
    Max = 200,
    Default = 50,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Power",
    Callback = function(value)
        _G.JumpPowerValue = value
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
        end
    end    
})

localTab:AddToggle({
    Name = "Auto Set JumpPower",
    Default = false,
    Callback = function(Value)
        _G.JumpPowerToggle = Value
        while _G.JumpPowerToggle do
            if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                game.Players.LocalPlayer.Character.Humanoid.JumpPower = _G.JumpPowerValue
            end
            task.wait()
        end
    end    
})

localTab:AddButton({
    Name = "Teleport Tool",
    Callback = function()
        local mouse = game.Players.LocalPlayer:GetMouse()
        local tool = Instance.new("Tool")
        tool.Name = "Click Teleport"
        tool.RequiresHandle = false
        
        tool.Activated:Connect(function()
            if mouse.Target then
                if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
                end
            end
        end)
        
        tool.Parent = game.Players.LocalPlayer.Backpack
    end    
})

OrionLib:Init()
