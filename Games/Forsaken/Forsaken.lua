local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local tpwalking = false
local loopspeedEnabled = false
local wsConnection = nil
local wsCAConnection = nil
local autoGenEnabled = false
local genLoopRunning = false
local hakariActive = false
local quietActive = false

LocalPlayer.CharacterAdded:Connect(function(newChar)
    char = newChar
end)

local ESPFolder = Workspace:FindFirstChild("BEARWARE_ESP") or Instance.new("Folder", Workspace)
ESPFolder.Name = "BEARWARE_ESP"

local ESPData = {
    players = {},
    tools = {},
    gens = {},
    connections = {},
    trackedPlayers = {},
    trackedTools = {},
    trackedGens = {}
}

-- Auto Generator Functions
local function instantSolveGenerator()
    for _, v in pairs(Workspace.Map.Ingame.Map:GetChildren()) do
        if v.Name == "Generator" then
            local remotes = v:FindFirstChild("Remotes")
            if remotes then
                local re = remotes:FindFirstChild("RE")
                if re then
                    for i = 1, 4 do
                        re:FireServer()
                        task.wait(0.1)
                    end
                end
            end
        end
    end
end

local function solveOneGenerator()
    for _, v in pairs(Workspace.Map.Ingame.Map:GetChildren()) do
        if v.Name == "Generator" then
            local remotes = v:FindFirstChild("Remotes")
            if remotes then
                local re = remotes:FindFirstChild("RE")
                if re then
                    re:FireServer()
                    break
                end
            end
        end
    end
end

local function autoGeneratorLoop()
    genLoopRunning = true
    local debounce = {}
    local delayTime = Options.GenDelay and Options.GenDelay.Value or 2.5
    
    while autoGenEnabled and genLoopRunning do
        task.wait()
        for _, v in pairs(Workspace.Map.Ingame.Map:GetChildren()) do
            if v.Name == "Generator" and autoGenEnabled then
                if not debounce[v] then
                    debounce[v] = true
                    
                    local remotes = v:FindFirstChild("Remotes")
                    if remotes then
                        local re = remotes:FindFirstChild("RE")
                        if re then
                            re:FireServer()
                        end
                    end
                    
                    task.delay(delayTime, function() 
                        debounce[v] = nil 
                    end)
                end
            end
        end
    end
    genLoopRunning = false
end

-- Emote Functions
local function activateHakariDance(state)
    local currentChar = char
    local humanoid = currentChar:WaitForChild("Humanoid")
    local rootPart = currentChar:WaitForChild("HumanoidRootPart")

    hakariActive = state

    if hakariActive then
        humanoid.PlatformStand = true
        humanoid.JumpPower = 0

        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
        bodyVelocity.Velocity = Vector3.zero
        bodyVelocity.Parent = rootPart

        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://138019937280193"
        local animationTrack = humanoid:LoadAnimation(animation)
        animationTrack:Play()

        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://87166578676888"
        sound.Parent = rootPart
        sound.Volume = 0.5
        sound.Looped = true
        sound:Play()

        local effect = game.ReplicatedStorage.Assets.Emotes.HakariDance.HakariBeamEffect:Clone()
        effect.Name = "PlayerEmoteVFX"
        effect.CFrame = currentChar.PrimaryPart.CFrame * CFrame.new(0, -1, -0.3)
        effect.WeldConstraint.Part0 = currentChar.PrimaryPart
        effect.WeldConstraint.Part1 = effect
        effect.Parent = currentChar
        effect.CanCollide = false

        local args = {
            [1] = "PlayEmote",
            [2] = "Animations",
            [3] = "HakariDance"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))

        animationTrack.Stopped:Connect(function()
            humanoid.PlatformStand = false
            if bodyVelocity and bodyVelocity.Parent then
                bodyVelocity:Destroy()
            end
        end)
    else
        humanoid.PlatformStand = false
        humanoid.JumpPower = 0

        local bodyVelocity = rootPart:FindFirstChildOfClass("BodyVelocity")
        if bodyVelocity then
            bodyVelocity:Destroy()
        end

        local sound = rootPart:FindFirstChildOfClass("Sound")
        if sound then
            sound:Stop()
            sound:Destroy()
        end

        local effect = currentChar:FindFirstChild("PlayerEmoteVFX")
        if effect then
            effect:Destroy()
        end

        for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
            if track.Animation.AnimationId == "rbxassetid://138019937280193" then
                track:Stop()
            end
        end
    end
end

local function activateMissTheQuiet(state)
    local currentChar = char
    local humanoid = currentChar:WaitForChild("Humanoid")
    local rootPart = currentChar:WaitForChild("HumanoidRootPart")
    
    quietActive = state

    if quietActive then
        humanoid.PlatformStand = true
        humanoid.JumpPower = 0

        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
        bodyVelocity.Velocity = Vector3.zero
        bodyVelocity.Parent = rootPart

        local emoteScript = require(game:GetService("ReplicatedStorage").Assets.Emotes.MissTheQuiet)
        emoteScript.Created({Character = currentChar})

        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://100986631322204"
        local animationTrack = humanoid:LoadAnimation(animation)
        animationTrack:Play()

        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://131936418953291"
        sound.Parent = rootPart
        sound.Volume = 0.5
        sound.Looped = false
        sound:Play()

        local args = {
            [1] = "PlayEmote",
            [2] = "Animations",
            [3] = "MissTheQuiet"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent"):FireServer(unpack(args))

        animationTrack.Stopped:Connect(function()
            humanoid.PlatformStand = false
            if bodyVelocity and bodyVelocity.Parent then
                bodyVelocity:Destroy()
            end

            local assetsToDestroy = {"EmoteHatAsset", "EmoteLighting", "PlayerEmoteHand"}
            for _, assetName in ipairs(assetsToDestroy) do
                local asset = currentChar:FindFirstChild(assetName)
                if asset then asset:Destroy() end
            end
        end)
    else
        humanoid.PlatformStand = false
        humanoid.JumpPower = 0

        local assetsToDestroy = {"EmoteHatAsset", "EmoteLighting", "PlayerEmoteHand"}
        for _, assetName in ipairs(assetsToDestroy) do
            local asset = currentChar:FindFirstChild(assetName)
            if asset then asset:Destroy() end
        end

        local bodyVelocity = rootPart:FindFirstChildOfClass("BodyVelocity")
        if bodyVelocity then
            bodyVelocity:Destroy()
        end

        local sound = rootPart:FindFirstChildOfClass("Sound")
        if sound then
            sound:Stop()
            sound:Destroy()
        end

        for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
            if track.Animation.AnimationId == "rbxassetid://100986631322204" then
                track:Stop()
            end
        end
    end
end

-- ESP Functions
local function ClearESP(tbl)
    for _, v in pairs(tbl) do
        if typeof(v) == "Instance" then 
            pcall(function() v:Destroy() end)
        end
        if typeof(v) == "RBXScriptConnection" then 
            pcall(function() v:Disconnect() end)
        end
    end
    table.clear(tbl)
end

local function CreatePlayerESP(player)
    if ESPData.trackedPlayers[player] then return end
    ESPData.trackedPlayers[player] = true

    local function SetupESP(character)
        task.wait(0.5)
        local HRP = character:FindFirstChild("HumanoidRootPart")
        local Hum = character:FindFirstChild("Humanoid")
        if not (HRP and Hum) then return end

        local Box = Instance.new("BoxHandleAdornment")
        Box.Parent = ESPFolder
        Box.Adornee = HRP
        Box.Size = HRP.Size + Vector3.new(0.5, 0.5, 0.5)
        Box.AlwaysOnTop = true
        Box.ZIndex = 10
        Box.Transparency = 0.7

        local BillboardGui = Instance.new("BillboardGui")
        BillboardGui.Parent = HRP
        BillboardGui.Size = UDim2.new(0, 100, 0, 50)
        BillboardGui.AlwaysOnTop = true
        BillboardGui.StudsOffset = Vector3.new(0, 3, 0)

        local TextLabel = Instance.new("TextLabel")
        TextLabel.Parent = BillboardGui
        TextLabel.Size = UDim2.new(1, 0, 1, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.TextScaled = true
        TextLabel.Font = Enum.Font.SourceSansBold
        TextLabel.TextStrokeTransparency = 0
        TextLabel.TextSize = 14

        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not character:IsDescendantOf(Workspace) or Hum.Health <= 0 or not HRP:IsDescendantOf(Workspace) then
                Box:Destroy()
                BillboardGui:Destroy()
                if connection then connection:Disconnect() end
                return
            end

            local isVisible = false
            local color = Color3.new(1, 1, 1)

            if Toggles.ESPKillers and Toggles.ESPKillers.Value then
                local killersFolder = Workspace:FindFirstChild("Players") and Workspace.Players:FindFirstChild("Killers")
                if killersFolder and character:IsDescendantOf(killersFolder) then
                    isVisible = true
                    color = Options.KillerColor.Value
                end
            end

            if Toggles.ESPSurvivors and Toggles.ESPSurvivors.Value then
                local survivorsFolder = Workspace:FindFirstChild("Players") and Workspace.Players:FindFirstChild("Survivors")
                if survivorsFolder and character:IsDescendantOf(survivorsFolder) then
                    isVisible = true
                    color = Options.SurvivorColor.Value
                end
            end

            Box.Visible = isVisible
            TextLabel.Visible = isVisible

            if isVisible then
                Box.Color3 = color
                TextLabel.TextColor3 = color
                TextLabel.Text = player.Name .. "\n" .. math.floor(Hum.Health) .. " HP"
            end
        end)

        table.insert(ESPData.players, Box)
        table.insert(ESPData.players, BillboardGui)
        table.insert(ESPData.connections, connection)
    end

    if player.Character then
        SetupESP(player.Character)
    end
    player.CharacterAdded:Connect(SetupESP)
end

local function CreateToolESP(tool)
    if ESPData.trackedTools[tool] then return end
    ESPData.trackedTools[tool] = true

    local ItemRoot = tool:FindFirstChild("ItemRoot")
    if not ItemRoot or not ItemRoot:IsA("BasePart") then return end

    local Box = Instance.new("BoxHandleAdornment")
    Box.Parent = ESPFolder
    Box.Adornee = ItemRoot
    Box.Size = ItemRoot.Size + Vector3.new(0.5, 0.5, 0.5)
    Box.AlwaysOnTop = true
    Box.ZIndex = 10
    Box.Transparency = 0.6

    local BillboardGui = Instance.new("BillboardGui")
    BillboardGui.Parent = ItemRoot
    BillboardGui.Size = UDim2.new(0, 100, 0, 30)
    BillboardGui.AlwaysOnTop = true
    BillboardGui.StudsOffset = Vector3.new(0, 2, 0)

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Parent = BillboardGui
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextScaled = true
    TextLabel.Font = Enum.Font.SourceSansBold
    TextLabel.TextStrokeTransparency = 0
    TextLabel.TextSize = 14
    TextLabel.Text = tool.Name

    local connection
    connection = RunService.RenderStepped:Connect(function()
        local visible = Toggles.ESPTools and Toggles.ESPTools.Value and tool:IsDescendantOf(Workspace) and ItemRoot:IsDescendantOf(Workspace)
        Box.Visible = visible
        TextLabel.Visible = visible

        if visible then
            Box.Color3 = Options.ToolColor.Value
            TextLabel.TextColor3 = Options.ToolColor.Value
        end

        if not tool:IsDescendantOf(Workspace) then
            Box:Destroy()
            BillboardGui:Destroy()
            if connection then connection:Disconnect() end
            ESPData.trackedTools[tool] = nil
        end
    end)

    table.insert(ESPData.tools, Box)
    table.insert(ESPData.tools, BillboardGui)
    table.insert(ESPData.connections, connection)
end

local function CreateGeneratorESP(generator)
    if ESPData.trackedGens[generator] then return end
    ESPData.trackedGens[generator] = true

    local cframe = generator:GetBoundingBox()
    local genPart = Instance.new("Part")
    genPart.Size = Vector3.new(8, 3.5, 3.5)
    genPart.CFrame = cframe * CFrame.new(0, 0, 1.5)
    genPart.Anchored = true
    genPart.Transparency = 1
    genPart.CanCollide = false
    genPart.Parent = ESPFolder

    local Box = Instance.new("BoxHandleAdornment")
    Box.Parent = ESPFolder
    Box.Adornee = genPart
    Box.Size = genPart.Size
    Box.AlwaysOnTop = true
    Box.Transparency = 0.5
    Box.ZIndex = 10

    local BillboardGui = Instance.new("BillboardGui")
    BillboardGui.Parent = genPart
    BillboardGui.Size = UDim2.new(0, 100, 0, 40)
    BillboardGui.AlwaysOnTop = true
    BillboardGui.StudsOffset = Vector3.new(0, 4.5, 0)

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Parent = BillboardGui
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextScaled = true
    TextLabel.Font = Enum.Font.SourceSansBold
    TextLabel.TextStrokeTransparency = 0
    TextLabel.TextSize = 14

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not Toggles.ESPGenerators or not Toggles.ESPGenerators.Value or not generator:IsDescendantOf(Workspace) then
            Box.Visible = false
            TextLabel.Visible = false
            
            if not generator:IsDescendantOf(Workspace) then
                Box:Destroy()
                BillboardGui:Destroy()
                genPart:Destroy()
                if connection then connection:Disconnect() end
                ESPData.trackedGens[generator] = nil
            end
            return
        end

        Box.Visible = true
        TextLabel.Visible = true

        local progress = generator:FindFirstChild("Progress") and generator.Progress.Value or 0
        local progressText = ""
        
        if progress == 0 then
            progressText = "0%"
        elseif progress > 20 and progress < 30 then
            progressText = "25%"
        elseif progress > 50 and progress < 60 then
            progressText = "50%"
        elseif progress > 70 and progress < 80 then
            progressText = "75%"
        elseif progress >= 100 then
            progressText = "100% (Done)"
        else
            progressText = math.floor(progress) .. "%"
        end

        TextLabel.Text = "Generator\n" .. progressText
        Box.Color3 = Options.GeneratorColor.Value
        TextLabel.TextColor3 = Options.GeneratorColor.Value
    end)

    table.insert(ESPData.gens, Box)
    table.insert(ESPData.gens, BillboardGui)
    table.insert(ESPData.gens, genPart)
    table.insert(ESPData.connections, connection)
end

local function ScanAndUpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not ESPData.trackedPlayers[player] then
            CreatePlayerESP(player)
        end
    end

    local mapIngame = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Ingame")
    if mapIngame then
        for _, item in ipairs(mapIngame:GetDescendants()) do
            if item:IsA("Tool") and not ESPData.trackedTools[item] and Toggles.ESPTools and Toggles.ESPTools.Value then
                CreateToolESP(item)
            end
        end

        local mapFolder = mapIngame:FindFirstChild("Map")
        if mapFolder then
            for _, gen in ipairs(mapFolder:GetChildren()) do
                if gen.Name == "Generator" and not ESPData.trackedGens[gen] and Toggles.ESPGenerators and Toggles.ESPGenerators.Value then
                    CreateGeneratorESP(gen)
                end
            end
        end
    end
end

local function PerformFrontflip()
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not (hum and hrp) then return end

    if char:FindFirstChild("Animate") then
        char.Animate.Disabled = true
    end

    local animator = hum:FindFirstChildOfClass("Animator")
    if animator then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            track:Stop()
        end
    end

    for _, state in ipairs({
        Enum.HumanoidStateType.FallingDown,
        Enum.HumanoidStateType.Freefall,
        Enum.HumanoidStateType.Running,
        Enum.HumanoidStateType.Seated,
        Enum.HumanoidStateType.Climbing
    }) do
        hum:SetStateEnabled(state, false)
    end
    hum:ChangeState(Enum.HumanoidStateType.Physics)

    local duration = 0.45
    local steps = 120
    local cf = hrp.CFrame
    local direction = cf.LookVector
    local up = Vector3.yAxis
    local distance = Options.FlipDistance and Options.FlipDistance.Value or 35
    local height = Options.FlipHeight and Options.FlipHeight.Value or 10

    task.spawn(function()
        local startTime = tick()
        for i = 1, steps do
            local t = i / steps
            local y = 4 * (t - t ^ 2) * height
            local pos = cf.Position + direction * (distance * t) + up * y
            local rotation = CFrame.Angles(-math.rad(360 * t), 0, 0)
            hrp.CFrame = CFrame.new(pos) * cf.Rotation * rotation

            local waitTime = (duration / steps) * i - (tick() - startTime)
            if waitTime > 0 then task.wait(waitTime) end
        end

        hrp.CFrame = CFrame.new(cf.Position + direction * distance) * cf.Rotation

        for _, state in ipairs({
            Enum.HumanoidStateType.FallingDown,
            Enum.HumanoidStateType.Freefall,
            Enum.HumanoidStateType.Running,
            Enum.HumanoidStateType.Seated,
            Enum.HumanoidStateType.Climbing
        }) do
            hum:SetStateEnabled(state, true)
        end
        hum:ChangeState(Enum.HumanoidStateType.Running)
        
        if char:FindFirstChild("Animate") then
            char.Animate.Disabled = false
        end
    end)
end

local invisAnim = nil
RunService.Stepped:Connect(function()
    if Toggles.Invisibility and Toggles.Invisibility.Value then
        local playersFolder = Workspace:FindFirstChild("Players")
        if playersFolder and (char.Parent == playersFolder:FindFirstChild("Killers") or 
           char.Parent == playersFolder:FindFirstChild("Survivors")) then
            
            if not invisAnim or not invisAnim.IsPlaying then
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://75804462760596"
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    invisAnim = hum:LoadAnimation(anim)
                    invisAnim:Play(0, 1, 1)
                    invisAnim:AdjustSpeed(0)
                end
            end
        end
    else
        if invisAnim and invisAnim.IsPlaying then
            invisAnim:Stop()
            invisAnim = nil
        end
    end
end)

local originalLightingSettings = {}
local function SaveLightingSettings()
    originalLightingSettings.Brightness = Lighting.Brightness
    originalLightingSettings.ClockTime = Lighting.ClockTime
    originalLightingSettings.FogEnd = Lighting.FogEnd
    originalLightingSettings.GlobalShadows = Lighting.GlobalShadows
    originalLightingSettings.Ambient = Lighting.Ambient
    originalLightingSettings.OutdoorAmbient = Lighting.OutdoorAmbient
end

SaveLightingSettings()

RunService.RenderStepped:Connect(function()
    if Toggles.Fullbright and Toggles.Fullbright.Value then
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or 
               effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") or 
               effect:IsA("DepthOfFieldEffect") or effect:IsA("Atmosphere") then
                effect.Enabled = false
            end
        end
    end
end)

local function SetupLoopSpeed()
    local speed = Options.LoopSpeed and Options.LoopSpeed.Value or 16
    local currentChar = char
    local currentHum = currentChar and currentChar:FindFirstChildOfClass("Humanoid")
    
    local function WalkSpeedChange()
        if currentChar and currentHum and loopspeedEnabled then
            currentHum.WalkSpeed = speed
        end
    end
    
    if currentHum then
        WalkSpeedChange()
        wsConnection = currentHum:GetPropertyChangedSignal("WalkSpeed"):Connect(WalkSpeedChange)
    end
    
    wsCAConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
        currentChar = newChar
        currentHum = newChar:WaitForChild("Humanoid")
        char = newChar
        
        if wsConnection then
            wsConnection:Disconnect()
        end
        
        WalkSpeedChange()
        wsConnection = currentHum:GetPropertyChangedSignal("WalkSpeed"):Connect(WalkSpeedChange)
    end)
end

local function StopLoopSpeed()
    if wsConnection then
        wsConnection:Disconnect()
        wsConnection = nil
    end
    if wsCAConnection then
        wsCAConnection:Disconnect()
        wsCAConnection = nil
    end
end

RunService.Heartbeat:Connect(function(delta)
    if tpwalking and char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Parent and hum.MoveDirection.Magnitude > 0 then
            local speed = Options.TPWalkSpeed and Options.TPWalkSpeed.Value or 1
            char:TranslateBy(hum.MoveDirection * speed * delta * 10)
        end
    end
end)

local Window = Library:CreateWindow({
    Title = 'BEARWARE - Forsaken',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Main'),
    Movement = Window:AddTab('Movement'),
    Visual = Window:AddTab('Visual'),
    Settings = Window:AddTab('Settings'),
}

local MainBox = Tabs.Main:AddLeftGroupbox('Flip Controls')

MainBox:AddButton({
    Text = 'Perform Frontflip',
    Func = function()
        PerformFrontflip()
    end,
    Tooltip = 'does a frontflip where ur looking'
})

MainBox:AddLabel('Frontflip Keybind'):AddKeyPicker('FrontflipKey', {
    Default = 'None',
    SyncToggleState = false,
    Mode = 'Always',
    Text = 'Frontflip',
    NoUI = false,
    Callback = function(Value)
        PerformFrontflip()
    end,
})

MainBox:AddSlider('FlipDistance', {
    Text = 'Flip Distance',
    Default = 35,
    Min = 10,
    Max = 100,
    Rounding = 0,
    Compact = false,
    Tooltip = 'how far u go'
})

MainBox:AddSlider('FlipHeight', {
    Text = 'Flip Height',
    Default = 10,
    Min = 5,
    Max = 30,
    Rounding = 0,
    Compact = false,
    Tooltip = 'height of the jump'
})

local MainBox2 = Tabs.Main:AddRightGroupbox('Character')

MainBox2:AddToggle('Invisibility', {
    Text = 'Invisibility',
    Default = false,
    Tooltip = 'makes u invisible but esp can still see u'
})

MainBox2:AddDivider()

MainBox2:AddToggle('HakariDance', {
    Text = 'Hakari Dance',
    Default = false,
    Tooltip = 'activates hakari dance emote'
})

MainBox2:AddToggle('MissTheQuiet', {
    Text = 'Miss The Quiet',
    Default = false,
    Tooltip = 'activates miss the quiet emote'
})

Toggles.HakariDance:OnChanged(function(value)
    activateHakariDance(value)
end)

Toggles.MissTheQuiet:OnChanged(function(value)
    activateMissTheQuiet(value)
end)

local AutoBox = Tabs.Main:AddLeftGroupbox('Generator Automation')

AutoBox:AddButton({
    Text = 'Instant Solve All Generators',
    Func = function()
        instantSolveGenerator()
        Library:Notify('Solving all generators...', 2)
    end,
    Tooltip = 'instantly completes all generators (4 repairs each)'
})

AutoBox:AddButton({
    Text = 'Solve One Generator',
    Func = function()
        solveOneGenerator()
        Library:Notify('Solving one generator...', 2)
    end,
    Tooltip = 'repairs one generator once'
})

AutoBox:AddDivider()

AutoBox:AddToggle('AutoGenerator', {
    Text = 'Auto Generator Loop',
    Default = false,
    Tooltip = 'automatically repairs generators continuously'
})

AutoBox:AddSlider('GenDelay', {
    Text = 'Generator Delay',
    Default = 2.5,
    Min = 0.5,
    Max = 10,
    Rounding = 1,
    Compact = false,
    Tooltip = 'delay between generator repairs (seconds)'
})

Toggles.AutoGenerator:OnChanged(function(value)
    autoGenEnabled = value
    if value and not genLoopRunning then
        task.spawn(autoGeneratorLoop)
    end
end)

local MovementBox = Tabs.Movement:AddLeftGroupbox('Walk Speed')

MovementBox:AddToggle('LoopSpeed', {
    Text = 'Loop WalkSpeed',
    Default = false,
    Tooltip = 'keeps ur walkspeed set no matter what'
})

MovementBox:AddSlider('LoopSpeed', {
    Text = 'WalkSpeed',
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Compact = false,
})

Toggles.LoopSpeed:OnChanged(function(value)
    loopspeedEnabled = value
    if value then
        SetupLoopSpeed()
    else
        StopLoopSpeed()
    end
end)

Options.LoopSpeed:OnChanged(function()
    if loopspeedEnabled then
        StopLoopSpeed()
        SetupLoopSpeed()
    end
end)

local MovementBox2 = Tabs.Movement:AddRightGroupbox('TP Walk')

MovementBox2:AddToggle('TPWalk', {
    Text = 'TP Walk',
    Default = false,
    Tooltip = 'teleports u when u walk, faster movement'
})

MovementBox2:AddSlider('TPWalkSpeed', {
    Text = 'TP Walk Speed',
    Default = 1,
    Min = 0.5,
    Max = 10,
    Rounding = 1,
    Compact = false,
    Tooltip = 'speed multiplier for tp walking'
})

Toggles.TPWalk:OnChanged(function(value)
    tpwalking = value
end)

-- Visual Tab (merged ESP + Visual)
local ESPPlayersBox = Tabs.Visual:AddLeftGroupbox('Player ESP')

ESPPlayersBox:AddToggle('ESPKillers', {
    Text = 'ESP Killers',
    Default = false,
})

ESPPlayersBox:AddLabel('Killer Color'):AddColorPicker('KillerColor', {
    Default = Color3.fromRGB(255, 0, 0),
    Title = 'Killer ESP Color',
})

ESPPlayersBox:AddToggle('ESPSurvivors', {
    Text = 'ESP Survivors',
    Default = false,
})

ESPPlayersBox:AddLabel('Survivor Color'):AddColorPicker('SurvivorColor', {
    Default = Color3.fromRGB(0, 255, 0),
    Title = 'Survivor ESP Color',
})

ESPPlayersBox:AddDivider()

ESPPlayersBox:AddButton({
    Text = 'Refresh Player ESP',
    Func = function()
        ClearESP(ESPData.players)
        ESPData.trackedPlayers = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreatePlayerESP(player)
            end
        end
    end,
    Tooltip = 'click this if esp stops working'
})

local ESPObjectsBox = Tabs.Visual:AddRightGroupbox('Object ESP')

ESPObjectsBox:AddToggle('ESPTools', {
    Text = 'ESP Tools',
    Default = false,
    Tooltip = 'shows items on the ground'
})

ESPObjectsBox:AddLabel('Tool Color'):AddColorPicker('ToolColor', {
    Default = Color3.fromRGB(255, 255, 0),
    Title = 'Tool ESP Color',
})

ESPObjectsBox:AddToggle('ESPGenerators', {
    Text = 'ESP Generators',
    Default = false,
    Tooltip = 'shows generators with their progress'
})

ESPObjectsBox:AddLabel('Generator Color'):AddColorPicker('GeneratorColor', {
    Default = Color3.fromRGB(255, 165, 0),
    Title = 'Generator ESP Color',
})

ESPObjectsBox:AddDivider()

ESPObjectsBox:AddButton({
    Text = 'Refresh All ESP',
    Func = function()
        ScanAndUpdateESP()
    end,
    Tooltip = 'rescans everything if something doesnt show up'
})

local VisualBox = Tabs.Visual:AddLeftGroupbox('Lighting')

VisualBox:AddToggle('Fullbright', {
    Text = 'Fullbright',
    Default = false,
})

Toggles.ESPKillers:OnChanged(function()
    ScanAndUpdateESP()
end)

Toggles.ESPSurvivors:OnChanged(function()
    ScanAndUpdateESP()
end)

Toggles.ESPTools:OnChanged(function()
    if Toggles.ESPTools.Value then
        ScanAndUpdateESP()
    else
        ClearESP(ESPData.tools)
        ESPData.trackedTools = {}
    end
end)

Toggles.ESPGenerators:OnChanged(function()
    if Toggles.ESPGenerators.Value then
        ScanAndUpdateESP()
    else
        ClearESP(ESPData.gens)
        ESPData.trackedGens = {}
    end
end)

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        task.wait(0.5)
        CreatePlayerESP(player)
    end
end)

task.spawn(function()
    while task.wait(2) do
        if not Library.Unloaded then
            ScanAndUpdateESP()
        end
    end
end)

task.spawn(function()
    local function setupMapMonitoring()
        local mapIngame = Workspace:WaitForChild("Map", 10)
        if not mapIngame then return end
        mapIngame = mapIngame:WaitForChild("Ingame", 10)
        if not mapIngame then return end
        
        mapIngame.DescendantAdded:Connect(function(desc)
            task.wait(0.1)
            if desc:IsA("Tool") and Toggles.ESPTools and Toggles.ESPTools.Value then
                CreateToolESP(desc)
            elseif desc.Name == "Generator" and Toggles.ESPGenerators and Toggles.ESPGenerators.Value then
                CreateGeneratorESP(desc)
            end
        end)
        
        mapIngame.DescendantRemoving:Connect(function(desc)
            if desc:IsA("Tool") then
                ESPData.trackedTools[desc] = nil
            elseif desc.Name == "Generator" then
                ESPData.trackedGens[desc] = nil
            end
        end)
    end
    
    setupMapMonitoring()
end)

local MenuGroup = Tabs.Settings:AddLeftGroupbox('Menu')
MenuGroup:AddButton({Text = 'Unload Script', Func = function() Library:Unload() end})
MenuGroup:AddLabel('Menu Keybind'):AddKeyPicker('MenuKeybind', {
    Default = 'End',
    NoUI = true,
    Text = 'Menu keybind'
})

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({'MenuKeybind'})

ThemeManager:SetFolder('BEARWARE')
SaveManager:SetFolder('BEARWARE/Forsaken')

SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

Library:SetWatermarkVisibility(true)

local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60

local WatermarkConnection = RunService.RenderStepped:Connect(function()
    FrameCounter = FrameCounter + 1
    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameTimer = tick()
        FrameCounter = 0
    end

    Library:SetWatermark(('BEARWARE - Forsaken | %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ))
end)

Library:OnUnload(function()
    WatermarkConnection:Disconnect()
    ClearESP(ESPData.players)
    ClearESP(ESPData.tools)
    ClearESP(ESPData.gens)
    ClearESP(ESPData.connections)
    if invisAnim then invisAnim:Stop() end
    StopLoopSpeed()
    tpwalking = false
    autoGenEnabled = false
    genLoopRunning = false
    hakariActive = false
    quietActive = false
    
    if originalLightingSettings then
        for setting, value in pairs(originalLightingSettings) do
            Lighting[setting] = value
        end
    end
    
    Library.Unloaded = true
end)

ScanAndUpdateESP()

Library:Notify('BEARWARE loaded successfully!', 3)
