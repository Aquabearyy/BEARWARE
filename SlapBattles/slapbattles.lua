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
    Name = "SilentHub - " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. " | " .. identifyexecutor(),
    IntroToggleIcon = "rbxassetid://7734091286",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "sxlent404"
})

--[[

███    ███  █████  ██ ███    ██     ████████  █████  ██████  
████  ████ ██   ██ ██ ████   ██        ██    ██   ██ ██   ██ 
██ ████ ██ ███████ ██ ██ ██  ██        ██    ███████ ██████  
██  ██  ██ ██   ██ ██ ██  ██ ██        ██    ██   ██ ██   ██ 
██      ██ ██   ██ ██ ██   ████        ██    ██   ██ ██████  
                                                                                  
]]

local mainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local ReplicaFarm = false

local function SpamReplica()
    while ReplicaFarm do
        game:GetService("ReplicatedStorage").Duplicate:FireServer(true)
        wait(20)
    end
end

FarmReplica = mainTab:AddToggle({
    Name = "Auto Slap Replica",
    Default = false,
    Callback = function(Value)
        ReplicaFarm = Value
        if Value and game.Players.LocalPlayer.leaderstats.Glove.Value == "Replica" and game.Players.LocalPlayer.Character.IsInDefaultArena.Value == true then
            coroutine.wrap(SpamReplica)()
            
            while ReplicaFarm do
                if not (game.Players.LocalPlayer.leaderstats.Glove.Value == "Replica" and game.Players.LocalPlayer.Character.IsInDefaultArena.Value == true) then
                    ReplicaFarm = false
                    FarmReplica:Set(false)
                    break
                end
                
                for i,v in pairs(workspace:GetChildren()) do
                    if v.Name:match(game.Players.LocalPlayer.Name) and v:FindFirstChild("HumanoidRootPart") then
                        game.ReplicatedStorage.b:FireServer(v:WaitForChild("HumanoidRootPart"), true)
                    end
                end
                task.wait()
            end
        elseif Value then
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "You don't have Replica equipped or you aren't in the island default",
                Image = "rbxassetid:7733658504",
                Time = 5
            })
            wait(0.05)
            FarmReplica:Set(false)
        end
    end
})

local Animations = {
    Floss = nil,
    Groove = nil,
    Headless = nil,
    Helicopter = nil,
    Kick = nil,
    L = nil,
    Laugh = nil,
    Parker = nil,
    Spasm = nil,
    Thriller = nil
}

local currentlyPlaying = nil
local lastPosition = nil
_G.AnimationsEnabled = false

local function LoadAnimations(humanoid)
    if not _G.AnimationsEnabled then return end
    
    Animations.Floss = humanoid:LoadAnimation(game.ReplicatedStorage.AnimationPack.Floss)
    Animations.Groove = humanoid:LoadAnimation(game.ReplicatedStorage.AnimationPack.Groove)
    Animations.Headless = humanoid:LoadAnimation(game.ReplicatedStorage.AnimationPack.Headless)
    Animations.Helicopter = humanoid:LoadAnimation(game.ReplicatedStorage.AnimationPack.Helicopter)
    Animations.Kick = humanoid:LoadAnimation(game.ReplicatedStorage.AnimationPack.Kick)
    Animations.L = humanoid:LoadAnimation(game.ReplicatedStorage.AnimationPack.L)
    Animations.Laugh = humanoid:LoadAnimation(game.ReplicatedStorage.AnimationPack.Laugh)
    Animations.Parker = humanoid:LoadAnimation(game.ReplicatedStorage.AnimationPack.Parker)
    Animations.Spasm = humanoid:LoadAnimation(game.ReplicatedStorage.AnimationPack.Spasm)
    Animations.Thriller = humanoid:LoadAnimation(game.ReplicatedStorage.AnimationPack.Thriller)
end

local function StopCurrentAnimation()
    if currentlyPlaying then
        currentlyPlaying:Stop()
        currentlyPlaying = nil
        lastPosition = nil
    end
end

mainTab:AddToggle({
    Name = "Free Animations",
    Default = false,
    Callback = function(Value)
        _G.AnimationsEnabled = Value
        if Value then
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                LoadAnimations(player.Character.Humanoid)
            end

            local chatConnection
            chatConnection = player.Chatted:connect(function(msg)
                if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
                
                local commands = {
                    ["/e floss"] = Animations.Floss,
                    ["/e groove"] = Animations.Groove,
                    ["/e headless"] = Animations.Headless,
                    ["/e helicopter"] = Animations.Helicopter,
                    ["/e kick"] = Animations.Kick,
                    ["/e l"] = Animations.L,
                    ["/e laugh"] = Animations.Laugh,
                    ["/e parker"] = Animations.Parker,
                    ["/e spasm"] = Animations.Spasm,
                    ["/e thriller"] = Animations.Thriller
                }
                
                local animation = commands[string.lower(msg)]
                if animation then
                    StopCurrentAnimation()
                    animation:Play()
                    currentlyPlaying = animation
                    lastPosition = player.Character.HumanoidRootPart.Position
                end
            end)

            local function onHeartbeat()
                if currentlyPlaying and lastPosition then
                    local character = player.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local currentPosition = character.HumanoidRootPart.Position
                        local distance = (currentPosition - lastPosition).Magnitude
                        if distance > 1 then
                            StopCurrentAnimation()
                        end
                    else
                        StopCurrentAnimation()
                    end
                end
            end
            
            RunService.Heartbeat:Connect(onHeartbeat)
        else
            StopCurrentAnimation()
            for _, animation in pairs(Animations) do
                if animation then
                    animation:Stop()
                end
            end
            table.clear(Animations)
        end
    end    
})

player.CharacterAdded:Connect(function(char)
    if _G.AnimationsEnabled then
        local humanoid = char:WaitForChild("Humanoid")
        LoadAnimations(humanoid)
    end
end)

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

--[[

 █████  ███    ██ ████████ ██     ████████  █████  ██████  
██   ██ ████   ██    ██    ██        ██    ██   ██ ██   ██ 
███████ ██ ██  ██    ██    ██        ██    ███████ ██████  
██   ██ ██  ██ ██    ██    ██        ██    ██   ██ ██   ██ 
██   ██ ██   ████    ██    ██        ██    ██   ██ ██████  
                                                                 
]]

local antiTab = Window:MakeTab({
    Name = "Anti",
    Icon = "rbxassetid://13793170713",
    PremiumOnly = false
})

local teleportCFrame = CFrame.new(-6.7, -5.2, 1.9, -0.1, -0.0, -0.9, -0.0, 0.9, -0.0, 0.9, -0.0, -0.1)

antiTab:AddToggle({
    Name = "Anti-Void",
    Default = false,
    Callback = function(Value)
        local connection
        
        if Value then
            connection = RunService.Heartbeat:Connect(function()
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

--[[

 ██████  ██████  ███    ███ ██████   █████  ████████     ████████  █████  ██████  
██      ██    ██ ████  ████ ██   ██ ██   ██    ██           ██    ██   ██ ██   ██ 
██      ██    ██ ██ ████ ██ ██████  ███████    ██           ██    ███████ ██████  
██      ██    ██ ██  ██  ██ ██   ██ ██   ██    ██           ██    ██   ██ ██   ██ 
 ██████  ██████  ██      ██ ██████  ██   ██    ██           ██    ██   ██ ██████  
                                                                                  
]]

local combatTab = Window:MakeTab({
    Name = "Combat",
    Icon = "rbxassetid://124159074947754",
    PremiumOnly = false
})

local slapEnabled = false
local slapDistance = 30
local slapCooldown = 0.6
local lastSlapTime = 0

combatTab:AddToggle({
    Name = "Slap Aura",
    Default = false,
    Callback = function(Value)
        slapEnabled = Value
        while slapEnabled and task.wait() do
            if tick() - lastSlapTime < slapCooldown then continue end
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then continue end
            
            local playerPosition = player.Character.HumanoidRootPart.Position
            local closestPlayer = nil
            local closestDistance = slapDistance
            
            for _, otherPlayer in pairs(Players:GetPlayers()) do
                if otherPlayer ~= player and 
                   otherPlayer.Character and 
                   otherPlayer.Character:FindFirstChild("HumanoidRootPart") and
                   otherPlayer.Character:FindFirstChild("Head") then
                    local distance = (playerPosition - otherPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if distance <= closestDistance then
                        closestDistance = distance
                        closestPlayer = otherPlayer
                    end
                end
            end
            
            if closestPlayer then
                local currentGlove = player.leaderstats.Glove.Value
                local remotes = {
                    ["Default"] = "b", ["Extended"] = "b", ["Dual"] = "GeneralHit", ["Diamond"] = "DiamondHit",
                    ["ZZZZZZZ"] = "ZZZZZZZHit", ["Brick"] = "BrickHit", ["Snow"] = "SnowHit", ["Pull"] = "PullHit",
                    ["Flash"] = "FlashHit", ["Spring"] = "springhit", ["Swapper"] = "HitSwapper", ["Bull"] = "BullHit",
                    ["Dice"] = "DiceHit", ["Ghost"] = "GhostHit", ["Thanos"] = "ThanosHit", ["Stun"] = "HtStun",
                    ["Za Hando"] = "zhrmat", ["Fort"] = "Fort", ["Magnet"] = "MagnetHIT", ["Pusher"] = "PusherHit",
                    ["Anchor"] = "hitAnchor", ["Space"] = "HtSpace", ["Boomerang"] = "BoomerangH",
                    ["Speedrun"] = "Speedrunhit", ["Mail"] = "MailHit", ["Golden"] = "GoldenHit",
                    ["THICK"] = "GeneralHit", ["Squid"] = "GeneralHit", ["Tycoon"] = "GeneralHit",
                    ["Flex"] = "FlexHit", ["CULT"] = "CULTHit", ["Orbit"] = "Orbihit",
                    ["Frostbite"] = "GeneralHit", ["Avatar"] = "GeneralHit"
                }
                local remote = remotes[currentGlove] or "GeneralHit"
                local remoteEvent = ReplicatedStorage:FindFirstChild(remote)
                if remoteEvent then
                    lastSlapTime = tick()
                    remoteEvent:FireServer(closestPlayer.Character.Head)
                end
            end
        end
    end    
})

combatTab:AddSlider({
    Name = "Slap Aura Range",
    Min = 10,
    Max = 50,
    Default = 30,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "studs",
    Callback = function(Value)
        slapDistance = Value
    end    
})

combatTab:AddSlider({
    Name = "Slap Aura Cooldown",
    Min = 0.1,
    Max = 2,
    Default = 0.7,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.1,
    ValueName = "seconds",
    Callback = function(Value)
        slapCooldown = Value
    end    
})

--[[

██████   █████  ██████   ██████  ███████ ███████     ████████  █████  ██████  
██   ██ ██   ██ ██   ██ ██       ██      ██             ██    ██   ██ ██   ██ 
██████  ███████ ██   ██ ██   ███ █████   ███████        ██    ███████ ██████  
██   ██ ██   ██ ██   ██ ██    ██ ██           ██        ██    ██   ██ ██   ██ 
██████  ██   ██ ██████   ██████  ███████ ███████        ██    ██   ██ ██████  

]]

local badgesTab = Window:MakeTab({
    Name = "Badges",
    Icon = "rbxassetid://16170504068",
    PremiumOnly = false
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

local brazilId = 7234087065
local mainId = 6403373529

badgesTab:AddButton({
   Name = "Get Fan and Boxer",
   Callback = function()
       local hasFanBadge = game:GetService("BadgeService"):UserHasBadgeAsync(player.UserId, 2657379023348335)
       local hasBoxerBadge = game:GetService("BadgeService"):UserHasBadgeAsync(player.UserId, 1223765330375569)
       
       if hasFanBadge and hasBoxerBadge then
           OrionLib:MakeNotification({
               Name = "Error",
               Content = "You already have Fan and Boxer Glove badges!",
               Image = "rbxassetid://7733658504",
               Time = 5
           })
           return
       end

       local brazilScript = [[
           if game.PlaceId == ]]..brazilId..[[ then
               wait(1)
               local player = game.Players.LocalPlayer
               repeat wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
               player.Character.HumanoidRootPart.CFrame = CFrame.new(247.564193725586, -265.000030517578, -370.037526855469)
               wait(0.5)
               local remoteEvents = game:GetService("ReplicatedStorage").RemoteEvents
               remoteEvents.SuitUpClown:FireServer()
               wait(0.1)
               remoteEvents.KeyQuest:FireServer()
               wait(0.1)
               remoteEvents.KeyAcquired:FireServer()
               wait(0.1)
               remoteEvents.KeyBadgeReward:FireServer()
               wait(0.1)
               player.Character.HumanoidRootPart.CFrame = CFrame.new(4231.26123046875, 3505.86376953125, 270.451995849609)
               wait(0.5)
               if workspace:FindFirstChild("BoxingGloves") and workspace.BoxingGloves:FindFirstChild("ClickDetector") then
                   fireclickdetector(workspace.BoxingGloves.ClickDetector)
               end
               wait(1)
               game:GetService("TeleportService"):Teleport(]]..mainId..[[)
           else
               loadstring(game:HttpGet("https://raw.githubusercontent.com/sxlent404/SilentHub/refs/heads/main/loader.lua"))()
           end
       ]]
       queueonteleport(brazilScript)
       game:GetService("TeleportService"):Teleport(brazilId, game.Players.LocalPlayer)
   end
})

badgesTab:AddButton({
    Name = "Get Bind Glove",
    Callback = function()
        local hasBadge = game:GetService("BadgeService"):UserHasBadgeAsync(player.UserId, 3199562682373814)
        
        if hasBadge then
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "You already have the Bind Glove badge!",
                Image = "rbxassetid://7733658504",
                Time = 5
            })
            return
        end

        local teleportFunc = queueonteleport or queue_on_teleport
        if teleportFunc then
            local bindScript = [[
                if not game:IsLoaded() then 
                    game.Loaded:Wait() 
                end
                
                repeat wait() until game.Players.LocalPlayer
                
                repeat 
                    fireclickdetector(workspace.Orb.ClickDetector)
                    wait(1)
                until game:GetService("BadgeService"):UserHasBadgeAsync(game.Players.LocalPlayer.UserId, 3199562682373814)
                
                local mainScript = [[
                    if not game:IsLoaded() then 
                        game.Loaded:Wait() 
                    end
                    
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/sxlent404/SilentHub/refs/heads/main/loader.lua"))()
                ]]
                
                queueonteleport(mainScript)
                wait(1)
                game:GetService("TeleportService"):Teleport(6403373529)
            ]]
            
            teleportFunc(bindScript)
        end
        
        game:GetService("TeleportService"):Teleport(74169485398268)
    end
})

--[[

██       ██████   ██████  █████  ██          ████████  █████  ██████  
██      ██    ██ ██      ██   ██ ██             ██    ██   ██ ██   ██ 
██      ██    ██ ██      ███████ ██             ██    ███████ ██████  
██      ██    ██ ██      ██   ██ ██             ██    ██   ██ ██   ██ 
███████  ██████   ██████ ██   ██ ███████        ██    ██   ██ ██████  

]]

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
