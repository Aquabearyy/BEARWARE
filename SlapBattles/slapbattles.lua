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
    Icon = "rbxassetid://9178976271",
    PremiumOnly = false
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

mainTab:AddParagraph("Notice.","Free Titan Glove Only Works In The Lobby, And Will Ragdoll You.")

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

mainTab:AddParagraph("Notice.","No Cooldown Has To Be Used Manually And In The Arena.")

mainTab:AddToggle({
    Name = "Auto Enter Arena",
    Default = false,
    Flag = "AutoArena",
    Save = true,
    Callback = function(Value)
        _G.AutoArena = Value
        while _G.AutoArena do
            local character = game.Players.LocalPlayer.Character
            if character and not character:FindFirstChild("entered") then
                local portal = game.workspace.Lobby.Portals.NormalArena.PortalTrigger
                portal.CanCollide = false
                if character:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = portal.CFrame
                end
            end
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

-- Anti-Void Section

local antiVoidSection = antiTab:AddSection({
	Name = "Anti-Void"
})

-- Anti-Void Toggle

local teleportCFrame = CFrame.new(-6.7, -5.2, 1.9, -0.1, -0.0, -0.9, -0.0, 0.9, -0.0, 0.9, -0.0, -0.1)

antiVoidSection:AddToggle({
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

-- Anti-Ragdoll Section

local antiRagdollSection = antiTab:AddSection({
	Name = "Anti-Ragdoll"
})

-- Anti-Ragdoll Toggle

antiRagdollSection:AddToggle({
    Name = "Anti-Ragdoll",
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

-- Anti-Ice Section

local antiIceSection = antiTab:AddSection({
	Name = "Anti-Ice"
})

-- Anti-Ice Toggle

antiIceSection:AddToggle({
    Name = "Anti-Ice",
    Default = false,
    Flag = "AntiIce",
    Save = true,
    Callback = function(Value)
        _G.AntiIce = Value
        while _G.AntiIce do
            if game.Players.LocalPlayer.Character then
                for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                    if v.Name == "Icecube" then
                        v:Destroy()
                        game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false
                        game.Players.LocalPlayer.Character.Humanoid.AutoRotate = true
                    end
                end
            end
            task.wait()
        end
    end    
})

-- Anti-Reaper Section

local antiReaperSection = antiTab:AddSection({
	Name = "Anti-Reaper"
})

-- Anti-Reaper Toggle

antiReaperSection:AddToggle({
    Name = "Anti-Reaper",
    Default = false,
    Flag = "AntiReaper",
    Save = true,
    Callback = function(Value)
        _G.AntiReaper = Value
        while _G.AntiReaper do
            for i,v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if v.Name == "DeathMark" then
                    game:GetService("ReplicatedStorage").ReaperGone:FireServer(game:GetService("Players").LocalPlayer.Character.DeathMark)
                    if game:GetService("Lighting"):FindFirstChild("DeathMarkColorCorrection") then
                        game:GetService("Lighting").DeathMarkColorCorrection:Destroy()
                    end
                end
            end
            task.wait()
        end
    end    
})

-- Anti-Pusher Section

local antiPusherSection = antiTab:AddSection({
	Name = "Anti-Pusher"
})

-- Anti-Pusher Toggle

antiPusherSection:AddToggle({
    Name = "Anti-Pusher",
    Default = false,
    Flag = "AntiPusher", 
    Save = true,
    Callback = function(Value)
        _G.AntiPusher = Value
        while _G.AntiPusher do
            for i,v in pairs(game.Workspace:GetChildren()) do
                if v.Name == "wall" then
                    v.CanCollide = false
                end
            end
            task.wait()
        end
    end    
})

-- Anti-Defend Section

local antiDefendSection = antiTab:AddSection({
	Name = "Anti-Defend"
})

-- Anti-Defend Toggle

antiDefendSection:AddToggle({
    Name = "Anti-Defend",
    Default = false,
    Flag = "AntiDefend",
    Save = true,
    Callback = function(Value)
        _G.AntiDefend = Value
        while _G.AntiDefend do
            for i,v in pairs(game.Workspace:GetChildren()) do
                if v.Name == "wall" then
                    v.CanCollide = false
                end
            end
            task.wait()
        end
    end    
})

-- Anti-Megarock/Custom Section

local antiMegarockCustomSection = antiTab:AddSection({
	Name = "Anti-Megarock/Custom"
})

-- Anti-Megarock/Custom Toggle

antiMegarockCustomSection:AddToggle({
    Name = "Anti-Megarock/Custom",
    Default = false,
    Flag = "AntiRock",
    Save = true,
    Callback = function(Value)
        _G.AntiRock = Value
        while _G.AntiRock do
            for _,v in pairs(game.Players:GetChildren()) do
                if v.Character and v.Character:FindFirstChild("rock") then
                    v.Character.rock.CanTouch = false
                    v.Character.rock.CanQuery = false
                end
            end
            task.wait()
        end
    end    
})

-- Anti-Sbeve Section

local antiSbeveSection = antiTab:AddSection({
	Name = "Anti-Sbeve"
})

-- Anti-Sbeve Toggle

antiSbeveSection:AddToggle({
    Name = "Anti-Sbeve",
    Default = false,
    Flag = "AntiSbeve",
    Save = true,
    Callback = function(Value)
        _G.AntiSbeve = Value
        while _G.AntiSbeve do
            for _,v in pairs(game.Players:GetChildren()) do
                if v.Character and v.Character:FindFirstChild("rock") then
                    v.Character.rock.CanTouch = false
                    v.Character.rock.CanQuery = false
                end
            end
            task.wait()
        end
    end    
})

-- Anti-Death Barriers Section

local antiDeathBarriersSection = antiTab:AddSection({
	Name = "Anti-Death Barriers"
})

-- Anti-Death Barriers Toggle

antiDeathBarriersSection:AddToggle({
    Name = "Anti-Death Barriers",
    Default = false,
    Flag = "AntiDeath",
    Save = true,
    Callback = function(Value)
        if Value then
            for i,v in pairs(game.Workspace.DEATHBARRIER:GetChildren()) do
                if v.ClassName == "Part" and v.Name == "BLOCK" then
                    v.CanTouch = false
                end
            end
            workspace.DEATHBARRIER.CanTouch = false
            workspace.DEATHBARRIER2.CanTouch = false
            workspace.dedBarrier.CanTouch = false
            workspace.ArenaBarrier.CanTouch = false
            workspace.AntiDefaultArena.CanTouch = false
        else
            for i,v in pairs(game.Workspace.DEATHBARRIER:GetChildren()) do
                if v.ClassName == "Part" and v.Name == "BLOCK" then
                    v.CanTouch = true
                end
            end
            workspace.DEATHBARRIER.CanTouch = true
            workspace.DEATHBARRIER2.CanTouch = true
            workspace.dedBarrier.CanTouch = true
            workspace.ArenaBarrier.CanTouch = true
            workspace.AntiDefaultArena.CanTouch = true
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

-- Combat Tab

local combatTab = Window:MakeTab({
    Name = "Combat",
    Icon = "rbxassetid://124159074947754",
    PremiumOnly = false
})

-- Slap Aura Toggle

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
                    ["Frostbite"] = "GeneralHit", ["Avatar"] = "GeneralHit", ["Untitled Tag Glove"] = "UTGHit",
                    ["Killstreak"] = "KSHit", ["Custom"] = "CustomHit", ["Reaper"] = "ReaperHit", ["Poltergiest"] = "GeneralHit",
                    ["Rhythm"] = "rhythmhit", ["Boogie"] = "HtStun", ["Replica"] = "ReplicaHit", ["Detonator"] = "DetonatorHit",
                    ["Spy"] = "SpyHit", ["Charge"] = "GeneralHit", ["Hallow Jack"] - "HallowHIT", ["Blocked"] = "BlockedHit",
                    ["Chain"] = "Soon This Isnt Finished",
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

badgesTab:AddParagraph("Notice.","Some features in the Badges Tab are still in development.")

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
           game:GetService("TeleportService"):Teleport(6403373529)
       ]]
       queueonteleport(brazilScript)
       game:GetService("TeleportService"):Teleport(7234087065, game.Players.LocalPlayer)
   end
})

badgesTab:AddButton({
    Name = "Get Bind Glove",
    Callback = function()
        local bindBadge = game:GetService("BadgeService"):UserHasBadgeAsync(player.UserId, 3199562682373814)
        
        if bindBadge then
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "You already have Bind Glove badge!",
                Image = "rbxassetid://7733658504",
                Time = 5
            })
            return
        end

        local bindScript = [[
            if not game:IsLoaded() then 
                game.Loaded:Wait() 
            end
            
            repeat 
                task.wait()
                if workspace:FindFirstChild("Orb") and workspace.Orb:FindFirstChild("ClickDetector") then
                    fireclickdetector(workspace.Orb.ClickDetector)
                end
            until game:GetService("BadgeService"):UserHasBadgeAsync(game.Players.LocalPlayer.UserId, 3199562682373814)
            
            game:GetService("TeleportService"):Teleport(6403373529)
        ]]
        
        queueonteleport(bindScript)
        game:GetService("TeleportService"):Teleport(74169485398268)
    end
})

--[[

███████  █████  ██████  ███    ███     ████████  █████  ██████  
██      ██   ██ ██   ██ ████  ████        ██    ██   ██ ██   ██ 
█████   ███████ ██████  ██ ████ ██        ██    ███████ ██████  
██      ██   ██ ██   ██ ██  ██  ██        ██    ██   ██ ██   ██ 
██      ██   ██ ██   ██ ██      ██        ██    ██   ██ ██████  

]]

local farmTab = Window:MakeTab({
    Name = "Farm",
    Icon = "rbxassetid://4458889192",
    PremiumOnly = false
})

farmTab:AddParagraph("Notice.","Some features in the Farm Tab are still in development.")

local ReplicaFarm = false

local function SpamReplica()
    while ReplicaFarm do
        game:GetService("ReplicatedStorage").Duplicate:FireServer(true)
        wait(20)
    end
end

FarmReplica = farmTab:AddToggle({
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

local boxerFarmSection = farmTab:AddSection({
	Name = "Boxer Farm"
})

local function boxerFarm()
    if not game:GetService("BadgeService"):UserHasBadgeAsync(game.Players.LocalPlayer.UserId, 1223765330375569) then
        OrionLib:MakeNotification({
            Name = "Error",
            Content = "You need the Boxer badge to use this feature!",
            Image = "rbxassetid://7733658504",
            Time = 5
        })
        return
    end

    for _, v in pairs(game:GetService("ReplicatedStorage")._NETWORK:GetChildren()) do
        if v.Name:find("{") and v:IsA("RemoteEvent") then
            v:FireServer("Boxer")
        end
    end
    
    wait(0.5)

    local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    local portal = game.workspace.Lobby.Portals.NormalArena.PortalTrigger
    portal.CanCollide = false
    
    spawn(function()
        while not character:FindFirstChild("entered") do
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.CFrame = portal.CFrame
            end
            wait(0.1)
        end
    end)
    
    wait(0.5)

    local function getRandomPlayer()
        local players = game:GetService("Players"):GetPlayers()
        for i = 1, 50 do
            local randomPlayer = players[math.random(1, #players)]
            if randomPlayer ~= game.Players.LocalPlayer 
               and randomPlayer.Character
               and randomPlayer.Character:FindFirstChild("Ragdolled")
               and randomPlayer.Character.Ragdolled.Value == false
               and not randomPlayer.Character:FindFirstChild("rock") then
                return randomPlayer
            end
            wait(0.05)
        end
        return nil
    end

    local target = getRandomPlayer()
    if target then
        spawn(function()
            for i = 1, 1000 do
                if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and
                   target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
                    game.ReplicatedStorage.Events.Boxing:FireServer(target, true)
                    game.ReplicatedStorage.Events.Boxing:FireServer(target, false)
                else
                    break
                end
                wait(0.05)
            end
            if _G.AutoRejoin then
                rejoinServer()
            end
        end)
    end
end

local function rejoinServer()
    local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if not httprequest then return end
    
    local servers = {}
    local req = httprequest({
        Url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true", game.PlaceId)
    })
    
    local body = game:GetService("HttpService"):JSONDecode(req.Body)
    if body and body.data then
        for _, v in next, body.data do
            if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) 
               and v.playing < v.maxPlayers and v.id ~= game.JobId then
                table.insert(servers, 1, v.id)
            end
        end
    end
    
    if #servers > 0 then
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], game.Players.LocalPlayer)
    else
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end
end

local function collectSlapples()
    local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    if character:FindFirstChild("entered") then
        for _, v in pairs(workspace.Arena.island5.Slapples:GetChildren()) do
            if character:FindFirstChild("HumanoidRootPart") and 
               (v.Name == "Slapple" or v.Name == "GoldenSlapple") and 
               v:FindFirstChild("Glove") and 
               v.Glove:FindFirstChildWhichIsA("TouchTransmitter") then
                firetouchinterest(character.HumanoidRootPart, v.Glove, 0)
                firetouchinterest(character.HumanoidRootPart, v.Glove, 1)
            end
        end
    end
end

boxerFarmSection:AddButton({
    Name = "Boxer Farm",
    Callback = function()
        if not game:GetService("BadgeService"):UserHasBadgeAsync(game.Players.LocalPlayer.UserId, 1223765330375569) then
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "You need the Boxer badge to use this feature!",
                Image = "rbxassetid://7733658504",
                Time = 5
            })
            return
        end
        _G.BoxerFarm = true
        boxerFarm()
    end    
})

boxerFarmSection:AddToggle({
    Name = "Auto Rejoin",
    Default = false,
    Flag = "AutoRejoin",
    Save = true,
    Callback = function(Value)
        _G.AutoRejoin = Value
    end    
})

boxerFarmSection:AddParagraph("Disclaimer:","Boxer Farm Will Kick You But Will Get Around 10-50 Slaps.")

farmTab:AddToggle({
    Name = "Auto Collect Slapples",
    Default = false,
    Flag = "AutoSlapples",
    Save = true,
    Callback = function(Value)
        _G.AutoSlapples = Value
        while _G.AutoSlapples do
            collectSlapples()
            wait(0.1)
        end
    end    
})

--[[

 ██████  ██       ██████  ██    ██ ███████     ███    ███  ██████  ██████  ███████     ████████  █████  ██████  
██       ██      ██    ██ ██    ██ ██          ████  ████ ██    ██ ██   ██ ██             ██    ██   ██ ██   ██ 
██   ███ ██      ██    ██ ██    ██ █████       ██ ████ ██ ██    ██ ██   ██ ███████        ██    ███████ ██████  
██    ██ ██      ██    ██  ██  ██  ██          ██  ██  ██ ██    ██ ██   ██      ██        ██    ██   ██ ██   ██ 
 ██████  ███████  ██████    ████   ███████     ██      ██  ██████  ██████  ███████        ██    ██   ██ ██████  

]]

local gloveModsTab = Window:MakeTab({
    Name = "Glove Mods",
    Icon = "rbxassetid://7733955740",
    PremiumOnly = false
})

gloveModsTab:AddParagraph("Notice.","Lots of features in the Glove Mods Tab are still in development.")

local slapsLabel = gloveModsTab:AddLabel("Slaps: 0")
local gloveLabel = gloveModsTab:AddLabel("Glove: None")

player.leaderstats.Slaps:GetPropertyChangedSignal("Value"):Connect(function()
    slapsLabel:Set("Slaps: " .. player.leaderstats.Slaps.Value)
end)

player.leaderstats.Glove:GetPropertyChangedSignal("Value"):Connect(function()
    gloveLabel:Set("Glove: " .. player.leaderstats.Glove.Value)
end)

slapsLabel:Set("Slaps: " .. player.leaderstats.Slaps.Value)
gloveLabel:Set("Glove: " .. player.leaderstats.Glove.Value)

local rhythmToggle = nil
local rhythmSection = nil

local function updateRhythmToggle()
    if not rhythmSection then
        rhythmSection = gloveModsTab:AddSection({
            Name = "Rhythm Glove Mods"
        })

        rhythmToggle = rhythmSection:AddToggle({
            Name = "Auto Play Rhythm",
            Default = false,
            Flag = "RhythmAutoPlay",
            Save = true,
            Callback = function(Value)
                if Value and player.leaderstats.Glove.Value ~= "Rhythm" then
                    wait(0.05)
                    rhythmToggle:Set(false)
                    OrionLib:MakeNotification({
                        Name = "Error",
                        Content = "You need the Rhythm Glove equipped to use this feature!",
                        Image = "rbxassetid://7733658504",
                        Time = 5
                    })
                    return
                end
                
                if Value then
                    if not (workspace:FindFirstChild(game.Players.LocalPlayer.Name) and
                           workspace[game.Players.LocalPlayer.Name]:FindFirstChild("entered")) then
                        wait(0.05)
                        rhythmToggle:Set(false)
                        OrionLib:MakeNotification({
                            Name = "Error",
                            Content = "You need to enter the arena first!",
                            Image = "rbxassetid://7733658504",
                            Time = 5
                        })
                        return
                    end
                    
                    _G.RhythmConnection = game.Players.LocalPlayer.PlayerGui.Rhythm.MainFrame.Bars.ChildAdded:Connect(function()
                        task.delay(1.7, function()
                            if game.Players.LocalPlayer.Character and 
                               game.Players.LocalPlayer.Character:FindFirstChild("Rhythm") and
                               workspace:FindFirstChild(game.Players.LocalPlayer.Name) and
                               workspace[game.Players.LocalPlayer.Name]:FindFirstChild("entered") then
                                game.Players.LocalPlayer.Character.Rhythm:Activate()
                            else
                                rhythmToggle:Set(false)
                            end
                        end)
                    end)
                else
                    if _G.RhythmConnection then
                        _G.RhythmConnection:Disconnect()
                        _G.RhythmConnection = nil
                    end
                end
            end    
        })
    end
end

player.leaderstats.Glove:GetPropertyChangedSignal("Value"):Connect(function()
    if rhythmToggle then
        rhythmToggle:Set(false)
    end
end)

updateRhythmToggle()

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
