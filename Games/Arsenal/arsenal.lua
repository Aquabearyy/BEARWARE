local flySettings = {fly = false, flyspeed = 50}
local c
local h
local bv
local bav
local cam
local flying
local p = game.Players.LocalPlayer
local buttons = {W = false, S = false, A = false, D = false, Moving = false}
local startFly = function()
    if not p.Character or not p.Character.Head or flying then
        return
    end
    c = p.Character
    h = c.Humanoid
    h.PlatformStand = true
    cam = workspace:WaitForChild("Camera")
    bv = Instance.new("BodyVelocity")
    bav = Instance.new("BodyAngularVelocity")
    bv.Velocity, bv.MaxForce, bv.P = Vector3.new(0, 0, 0), Vector3.new(10000, 10000, 10000), 1000
    bav.AngularVelocity, bav.MaxTorque, bav.P = Vector3.new(0, 0, 0), Vector3.new(10000, 10000, 10000), 1000
    bv.Parent = c.Head
    bav.Parent = c.Head
    flying = true
    h.Died:connect(
        function()
            flying = false
        end
    )
end
local endFly = function()
    if not p.Character or not flying then
        return
    end
    h.PlatformStand = false
    bv:Destroy()
    bav:Destroy()
    flying = false
end
game:GetService("UserInputService").InputBegan:connect(
    function(input, GPE)
        if GPE then
            return
        end
        for i, e in pairs(buttons) do
            if i ~= "Moving" and input.KeyCode == Enum.KeyCode[i] then
                buttons[i] = true
                buttons.Moving = true
            end
        end
    end
)
game:GetService("UserInputService").InputEnded:connect(
    function(input, GPE)
        if GPE then
            return
        end
        local a = false
        for i, e in pairs(buttons) do
            if i ~= "Moving" then
                if input.KeyCode == Enum.KeyCode[i] then
                    buttons[i] = false
                end
                if buttons[i] then
                    a = true
                end
            end
        end
        buttons.Moving = a
    end
)
local setVec = function(vec)
    return vec * (flySettings.flyspeed / vec.Magnitude)
end
game:GetService("RunService").Heartbeat:connect(
    function(step)
        if flying and c and c.PrimaryPart then
            local p = c.PrimaryPart.Position
            local cf = cam.CFrame
            local ax, ay, az = cf:toEulerAnglesXYZ()
            c:SetPrimaryPartCFrame(CFrame.new(p.x, p.y, p.z) * CFrame.Angles(ax, ay, az))
            if buttons.Moving then
                local t = Vector3.new()
                if buttons.W then
                    t = t + (setVec(cf.lookVector))
                end
                if buttons.S then
                    t = t - (setVec(cf.lookVector))
                end
                if buttons.A then
                    t = t - (setVec(cf.rightVector))
                end
                if buttons.D then
                    t = t + (setVec(cf.rightVector))
                end
                c:TranslateBy(t * step)
            end
        end
    end
)

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bitef4/Recode/main/UI/Kavo_1.lua"))()
local Window = Library.CreateLib("Bear Hub | " .. identifyexecutor())

local hitboxEnabled = false
local noCollisionEnabled = false
local hitbox_original_properties = {}
local hitboxSize = 21
local hitboxTransparency = 6
local teamCheck = "FFA" 

local defaultBodyParts = {
    "UpperTorso",
    "Head",
    "HumanoidRootPart"
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
local WarningText = Instance.new("TextLabel", ScreenGui)

WarningText.Size = UDim2.new(0, 200, 0, 50)
WarningText.TextSize = 16
WarningText.Position = UDim2.new(0.5, -150, 0, 0)
WarningText.Text = "Warning: There may be a bug that causes collisions."
WarningText.TextColor3 = Color3.new(1, 0, 0)
WarningText.BackgroundTransparency = 1
WarningText.Visible = false

local function savedPart(player, part)
    if not hitbox_original_properties[player] then
        hitbox_original_properties[player] = {}
    end
    if not hitbox_original_properties[player][part.Name] then
        hitbox_original_properties[player][part.Name] = {
            CanCollide = part.CanCollide,
            Transparency = part.Transparency,
            Size = part.Size
        }
    end
end

local function restoredPart(player)
    if hitbox_original_properties[player] then
        for partName, properties in pairs(hitbox_original_properties[player]) do
            local part = player.Character and player.Character:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                part.CanCollide = properties.CanCollide
                part.Transparency = properties.Transparency
                part.Size = properties.Size
            end
        end
    end
end

local function findClosestPart(player, partName)
    if not player.Character then return nil end
    local characterParts = player.Character:GetChildren()
    for _, part in ipairs(characterParts) do
        if part:IsA("BasePart") and part.Name:lower():match(partName:lower()) then
            return part
        end
    end
    return nil
end

local function isEnemy(player)
    if teamCheck == "FFA" or teamCheck == "Everyone" then
        return true
    end
    local localPlayerTeam = LocalPlayer.Team
    return player.Team ~= localPlayerTeam
end

local function onCharacterAdded(character)
    task.wait(0.1)
    if hitboxEnabled then
        updateHitboxes()
    end
end

local function onPlayerAdded(player)
    player.CharacterAdded:Connect(onCharacterAdded)
    player.CharacterRemoving:Connect(function()
        restoredPart(player)
        hitbox_original_properties[player] = nil
    end)
end

local function checkForDeadPlayers()
    for player, properties in pairs(hitbox_original_properties) do
        if not player.Parent or not player.Character or not player.Character:IsDescendantOf(game) then
            restoredPart(player)
            hitbox_original_properties[player] = nil
        end
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)

for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

local Gun = Window:NewTab("Gun Modded")

local AutoSection = Gun:NewSection("Auto farms.")

AutoSection:NewToggle("AutoFarm", "Spam teleports to players.", function(bool)
    getgenv().AutoFarm = bool

    local runServiceConnection
    local mouseDown = false
    local player = game.Players.LocalPlayer
    local camera = game.Workspace.CurrentCamera

    game:GetService("ReplicatedStorage").wkspc.CurrentCurse.Value = bool and "Infinite Ammo" or ""

    function getClosestEnemyPlayer()
        local closestDistance = math.huge
        local closestPlayer = nil

        for _, enemyPlayer in pairs(game.Players:GetPlayers()) do
            if enemyPlayer ~= player and enemyPlayer.TeamColor ~= player.TeamColor and enemyPlayer.Character then
                local character = enemyPlayer.Character
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoidRootPart and humanoid and humanoid.Health > 0 then
                    local distance = (player.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                    if distance < closestDistance and humanoidRootPart.Position.Y >= 0 then
                        closestDistance = distance
                        closestPlayer = enemyPlayer
                    end
                end
            end
        end

        return closestPlayer
    end

    local function startAutoFarm()
        game:GetService("ReplicatedStorage").wkspc.TimeScale.Value = 12

        runServiceConnection = game:GetService("RunService").Stepped:Connect(function()
            if getgenv().AutoFarm then
                local closestPlayer = getClosestEnemyPlayer()
                if closestPlayer then
                    local targetPosition = closestPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 0, -4)
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
                        camera.CFrame = CFrame.new(camera.CFrame.Position, closestPlayer.Character.Head.Position)

                        if not mouseDown then
                            mouse1press()
                            mouseDown = true
                        end
                    end
                else
                    if mouseDown then
                        mouse1release()
                        mouseDown = false
                    end
                end
            else
                if runServiceConnection then
                    runServiceConnection:Disconnect()
                    runServiceConnection = nil
                end
                if mouseDown then
                    mouse1release()
                    mouseDown = false
                end
            end
        end)
    end

    local function onCharacterAdded(character)
        wait(0.5)
        startAutoFarm()
    end

    player.CharacterAdded:Connect(onCharacterAdded)

    if bool then
        wait(0.5)
        startAutoFarm()
    else
        game:GetService("ReplicatedStorage").wkspc.CurrentCurse.Value = ""
        getgenv().AutoFarm = false
        game:GetService("ReplicatedStorage").wkspc.TimeScale.Value = 1
        if runServiceConnection then
            runServiceConnection:Disconnect()
            runServiceConnection = nil
        end
        if mouseDown then
            mouse1release()
            mouseDown = false
        end
    end
end)

local GunmodsSection = Gun:NewSection("Overpower Gun")

GunmodsSection:NewToggle("Infinite Ammo v1", "?", function(v)
    game:GetService("ReplicatedStorage").wkspc.CurrentCurse.Value = v and "Infinite Ammo" or ""
end)

local SettingsInfinite = false
GunmodsSection:NewToggle("Infinite Ammo v2", "?", function(K)
    SettingsInfinite = K
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
end)

local originalValues = {
    FireRate = {},
    ReloadTime = {},
    EReloadTime = {},
    Auto = {},
    Spread = {},
    Recoil = {}
}

GunmodsSection:NewToggle("Fast Reload", "?", function(x)
    for _, v in pairs(game.ReplicatedStorage.Weapons:GetChildren()) do
        if v:FindFirstChild("ReloadTime") then
            if x then
                if not originalValues.ReloadTime[v] then
                    originalValues.ReloadTime[v] = v.ReloadTime.Value
                end
                v.ReloadTime.Value = 0.01
            else
                if originalValues.ReloadTime[v] then
                    v.ReloadTime.Value = originalValues.ReloadTime[v]
                else
                    v.ReloadTime.Value = 0.8 
                end
            end
        end
        if v:FindFirstChild("EReloadTime") then
            if x then
                if not originalValues.EReloadTime[v] then
                    originalValues.EReloadTime[v] = v.EReloadTime.Value
                end
                v.EReloadTime.Value = 0.01
            else
                if originalValues.EReloadTime[v] then
                    v.EReloadTime.Value = originalValues.EReloadTime[v]
                else
                    v.EReloadTime.Value = 0.8 
                end
            end
        end
    end
end)

GunmodsSection:NewToggle("Fast Fire Rate", "?", function(state)
    for _, v in pairs(game.ReplicatedStorage.Weapons:GetDescendants()) do
        if v.Name == "FireRate" or v.Name == "BFireRate" then
            if state then
                if not originalValues.FireRate[v] then
                    originalValues.FireRate[v] = v.Value
                end
                v.Value = 0.02
            else
                if originalValues.FireRate[v] then
                    v.Value = originalValues.FireRate[v]
                else
                    v.Value = 0.8 
                end
            end
        end
    end
end)

GunmodsSection:NewToggle("Always Auto", "?", function(state)
    for _, v in pairs(game.ReplicatedStorage.Weapons:GetDescendants()) do
        if v.Name == "Auto" or v.Name == "AutoFire" or v.Name == "Automatic" or v.Name == "AutoShoot" or v.Name == "AutoGun" then
            if state then
                if not originalValues.Auto[v] then
                    originalValues.Auto[v] = v.Value
                end
                v.Value = true
            else
                if originalValues.Auto[v] then
                    v.Value = originalValues.Auto[v]
                else
                    v.Value = false 
                end
            end
        end
    end
end)

GunmodsSection:NewToggle("No Spread", "?", function(state)
    for _, v in pairs(game:GetService("ReplicatedStorage").Weapons:GetDescendants()) do
        if v.Name == "MaxSpread" or v.Name == "Spread" or v.Name == "SpreadControl" then
            if state then
                if not originalValues.Spread[v] then
                    originalValues.Spread[v] = v.Value
                end
                v.Value = 0
            else
                if originalValues.Spread[v] then
                    v.Value = originalValues.Spread[v]
                else
                    v.Value = 1 
                end
            end
        end
    end
end)

GunmodsSection:NewToggle("No Recoil", "?", function(state)
    for _, v in pairs(game:GetService("ReplicatedStorage").Weapons:GetDescendants()) do
        if v.Name == "RecoilControl" or v.Name == "Recoil" then
            if state then
                if not originalValues.Recoil[v] then
                    originalValues.Recoil[v] = v.Value
                end
                v.Value = 0
            else
                if originalValues.Recoil[v] then
                    v.Value = originalValues.Recoil[v]
                else
                    v.Value = 1 
                end
            end
        end
    end
end)


local Player = Window:NewTab("Player")
local PlayerSection = Player:NewSection("Fly Hacks")
PlayerSection:NewToggle("Fly", "Allows the player to fly", function(state)
  if state then
    startFly()
  else
    endFly()
  end
end)
PlayerSection:NewSlider("Fly Speed", "Allows for faster/slower flight", 500, 1, function(s)
  flySettings.flyspeed = s
end)

PlayerSection:NewLabel("> Speed Power <")

local settings = {WalkSpeed = 16}
local isWalkSpeedEnabled = false

PlayerSection:NewToggle("Custom WalkSpeed", "Toggle custom walkspeed", function(enabled)
    isWalkSpeedEnabled = enabled
end)

local walkMethods = {"Velocity", "Vector", "CFrame"}
local selectedWalkMethod = walkMethods[1]

PlayerSection:NewDropdown("Walk Method", "Choose walk method", walkMethods, function(selected)
    selectedWalkMethod = selected
end)

PlayerSection:NewSlider("Walkspeed Power", "Adjust walkspeed power", 500, 16, function(value)
    settings.WalkSpeed = value
end)

local function wsm(player, deltaTime)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")

    if humanoid and rootPart then
        local VS = humanoid.MoveDirection * settings.WalkSpeed
        if selectedWalkMethod == "Velocity" then
            rootPart.Velocity = Vector3.new(VS.X, rootPart.Velocity.Y, VS.Z)
        elseif selectedWalkMethod == "Vector" then
            local scaleFactor = 0.0001
            rootPart.CFrame = rootPart.CFrame + (VS * deltaTime * scaleFactor)
        elseif selectedWalkMethod == "CFrame" then
            local scaleFactor = 0.0001
            rootPart.CFrame = rootPart.CFrame + (humanoid.MoveDirection * settings.WalkSpeed * deltaTime * scaleFactor)
        else
            humanoid.WalkSpeed = settings.WalkSpeed
        end
    end
end

game:GetService("RunService").Stepped:Connect(function(deltaTime)
    if isWalkSpeedEnabled then
        local player = game:GetService("Players").LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            wsm(player, deltaTime)
        end
    end
end)


PlayerSection:NewLabel("> JumpPower <")

local IJ = false
PlayerSection:NewToggle("Infinite Jump", "Toggle infinite jump", function(state)
    IJ = state
    game:GetService("UserInputService").JumpRequest:Connect(function()
        if IJ then
            game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping")
        end
    end)
end)


local isJumpPowerEnabled = false

PlayerSection:NewToggle("Custom JumpPower", "Toggle custom jumppower", function(enabled)
    isJumpPowerEnabled = enabled
end)

local jumpMethods = {"Velocity", "Vector", "CFrame"}
local selectedJumpMethod = jumpMethods[1]

PlayerSection:NewDropdown("Jump Method", "Choose jump method", jumpMethods, function(selected)
    selectedJumpMethod = selected
end)

PlayerSection:NewSlider("Change JumpPower", "Adjust jumppower", 500, 30, function(value)
    local player = game:GetService("Players").LocalPlayer
    local humanoid = player.Character:WaitForChild("Humanoid")
    humanoid.UseJumpPower = true
    humanoid.Jumping:Connect(function(isActive)
        if isJumpPowerEnabled and isActive then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                if selectedJumpMethod == "Velocity" then
                    rootPart.Velocity = rootPart.Velocity * Vector3.new(1, 0, 1) + Vector3.new(0, value, 0)
                elseif selectedJumpMethod == "Vector" then
                    rootPart.Velocity = Vector3.new(0, value, 0)
                elseif selectedJumpMethod == "CFrame" then
                    player.Character:SetPrimaryPartCFrame(player.Character:GetPrimaryPartCFrame() + Vector3.new(0, value, 0))
                end
            end
        end
    end)
end)

PlayerSection:NewLabel("> Anti Aim <")

local spinSpeed = 10
local gyro

PlayerSection:NewToggle("Anti-Aim v1", "Toggle anti-aim feature", function(value)
    local character = game.Players.LocalPlayer.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if value then
        game:GetService("Players").LocalPlayer.PlayerGui.GUI.Client.Variables.thirdperson.Value = true

        if humanoidRootPart then
            local spin = Instance.new("BodyAngularVelocity")
            spin.Name = "AntiAimSpin"
            spin.AngularVelocity = Vector3.new(0, spinSpeed, 0)
            spin.MaxTorque = Vector3.new(0, math.huge, 0)
            spin.P = 500000
            spin.Parent = humanoidRootPart

            gyro = Instance.new("BodyGyro")
            gyro.Name = "AntiAimGyro"
            gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            gyro.CFrame = humanoidRootPart.CFrame
            gyro.P = 3000
            gyro.Parent = humanoidRootPart
        end
    else
        game:GetService("Players").LocalPlayer.PlayerGui.GUI.Client.Variables.thirdperson.Value = false

        if humanoidRootPart then
            local spin = humanoidRootPart:FindFirstChild("AntiAimSpin")
            if spin then
                spin:Destroy()
            end

            if gyro then
                gyro:Destroy()
                gyro = nil
            end
        end
    end
end)

PlayerSection:NewSlider("Spin Speed", "Adjust the speed of the anti-aim spin", 100, 10, function(value)
    spinSpeed = value

    local character = game.Players.LocalPlayer.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local spin = humanoidRootPart:FindFirstChild("AntiAimSpin")
        if spin then
            spin.AngularVelocity = Vector3.new(0, spinSpeed, 0)
        end
    end
end)




PlayerSection:NewLabel("> Object Teleport <")
local autoHealEnabled = false
local autoAmmoEnabled = false

PlayerSection:NewToggle("DeadHP (AutoHeal)", "MMSVon made this", function(enabled)
    autoHealEnabled = enabled
    managePickups()
end)

PlayerSection:NewToggle("DeadAmmo (Inf-Ammo)", "MMSVon made this", function(enabled)
    autoAmmoEnabled = enabled
    managePickups()
end)

function managePickups()
    if autoHealEnabled or autoAmmoEnabled then
        spawn(function()
            while autoHealEnabled or autoAmmoEnabled do
                wait()
                pcall(function()
                    local player = game.Players.LocalPlayer
                    local character = player.Character
                    if character then
                        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                        if humanoidRootPart then
                            for _, v in pairs(game.Workspace.Debris:GetChildren()) do
                                if (autoHealEnabled and v.Name == "DeadHP") or (autoAmmoEnabled and v.Name == "DeadAmmo") then
                                    v.CFrame = humanoidRootPart.CFrame
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end
end

PlayerSection:NewLabel("> Useful Cheat <")

PlayerSection:NewTextBox('TimeScale', '?', function(TimeScaleFR)
  game:GetService("ReplicatedStorage").wkspc.TimeScale.Value = TimeScaleFR
end)
PlayerSection:NewLabel("> Misc <")

PlayerSection:NewSlider("FOV Arsenal", "?", 120, 0, function(num)
  game:GetService("Players").LocalPlayer.Settings.FOV.Value = num
end)
local isNoClipEnabled = false

PlayerSection:NewToggle("Toggle NoClip", "?", function(enabled)
    isNoClipEnabled = enabled
    local player = game.Players.LocalPlayer

    local function toggleNoClip()
        while isNoClipEnabled do
            local character = player.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
            game:GetService("RunService").Stepped:Wait()
        end

        local character = player.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end

    if isNoClipEnabled then
        spawn(toggleNoClip)
    end
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    if isNoClipEnabled then
        spawn(function()
            while isNoClipEnabled do
                if character then
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
                game:GetService("RunService").Stepped:Wait()
            end

            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end)
    end
end)

local xrayOn = false
PlayerSection:NewToggle("Toggle Xray", "WallXray lol", function(enabled) -- xray go brrrrrrrr
  xrayOn = enabled

  if xrayOn then
    for _, descendant in pairs(workspace:GetDescendants()) do
      if descendant:IsA("BasePart") then
        if not descendant:FindFirstChild("OriginalTransparency") then
          local originalTransparency = Instance.new("NumberValue")
          originalTransparency.Name = "OriginalTransparency"
          originalTransparency.Value = descendant.Transparency
          originalTransparency.Parent = descendant
        end
        descendant.Transparency = 0.5
      end
    end
  else
    for _, descendant in pairs(workspace:GetDescendants()) do
      if descendant:IsA("BasePart") then
        if descendant:FindFirstChild("OriginalTransparency") then
          descendant.Transparency = descendant.OriginalTransparency.Value
          descendant.OriginalTransparency:Destroy()
        end
      end
    end
  end
end)


local Skins = Window:NewTab("Color Skins")
local Random = Skins:NewSection("Arm Skins")

local function ak(al)
  return Vector3.new(al.R, al.G, al.B)
end

local am = "Plastic"
Random:NewDropdown("Arm Material", "?", { "Plastic", "ForceField", "Wood", "Grass" }, function(an)
  am = an
end)

local ao = Color3.new(50, 50, 50)
Random:NewColorPicker('Arm Color', "?", Color3.fromRGB(50, 50, 50), function(ap)
  ao = ap
end)

local aq = false
Random:NewToggle("Arm Charms", "?", function(L)
  aq = L
  if aq then
    spawn(function()
      while true do
        wait(.01)
        if not aq then
          break
        else
          local cameraArms = workspace.Camera:FindFirstChild("Arms")
          if cameraArms then
            for ar, O in pairs(cameraArms:GetDescendants()) do
              if O.Name == 'Right Arm' or O.Name == 'Left Arm' then
                if O:IsA("BasePart") then
                  O.Material = Enum.Material[am]
                  O.Color = ao
                end
              elseif O:IsA("SpecialMesh") then
                if O.TextureId == '' then
                  O.TextureId = 'rbxassetid://0'
                  O.VertexColor = ak(ao)
                end
              elseif O.Name == 'L' or O.Name == 'R' then
                O:Destroy()
              end
            end
          end
        end
      end
    end)
  end
end)


Random:NewLabel("> Gun Skin <")

local at = "Plastic"
Random:NewDropdown("Gun Material", "?", { "Plastic", "ForceField", "Wood", "Grass" }, function(an)
  at = an
end)
local au = Color3.new(50, 50, 50)
Random:NewColorPicker('Gun Color', "?", Color3.fromRGB(50, 50, 50), function(ap)
  au = ap
end)
local av = false;
Random:NewToggle("Gun Charms", "?", function(L)
  av = L;
  if av
  then
    spawn(function()
      while true do wait(.01)
        if not av then
          break
        else
          if not workspace.Camera:FindFirstChild("Arms")
          then
            wait()
          else
            for ar, O in pairs(workspace.Camera.Arms:GetDescendants()) do
              if O:IsA("MeshPart")
              then
                O.Material = Enum.Material[at]
                O.Color = au
              end
            end
          end
        end
      end
    end)
  end
end)

Random:NewLabel("> Rainbow Gun <")

local rainbowEnabled = false
local c = 1
function zigzag(X) 
  return math.acos(math.cos(X * math.pi)) / math.pi 
end

Random:NewToggle("Rainbow Gun v1", "?", function(state)
  rainbowEnabled = state
end)

game:GetService("RunService").RenderStepped:Connect(function() 
  if game.Workspace.Camera:FindFirstChild('Arms') and rainbowEnabled then 
    for i, v in pairs(game.Workspace.Camera.Arms:GetDescendants()) do 
      if v.ClassName == 'MeshPart' then 
        v.Color = Color3.fromHSV(zigzag(c), 1, 1)
        c = c + .0001
      end 
    end 
  end 
end)

local rainbowEnabled = false
local c = 0
local hueIncrement = 0.1 

function updateColors()
  for i, v in pairs(game.Workspace.Camera.Arms:GetDescendants()) do
    if v.ClassName == 'MeshPart' then
      v.Color = Color3.fromHSV(c, 1, 1)
    end
  end
end

Random:NewToggle("Rainbow Gun v2 [Crazy Fast Animation]", "?", function(state)
  rainbowEnabled = state
end)

game:GetService("RunService").RenderStepped:Connect(function()
  if game.Workspace.Camera:FindFirstChild('Arms') and rainbowEnabled then
    c = c + hueIncrement
    if c >= 1 then
      c = c % 1
    end
    updateColors()
  end
end)


local ExtraTab = Window:NewTab("Extra")

local function enableParticles()
    for i, v in pairs(game:GetDescendants()) do
      if v:IsA("ParticleEmitter") then
        v.Parent = game.Players.LocalPlayer.Character["Particle Area"]
      end
    end
  end
  
  local function disableParticles()
    for i, v in pairs(game:GetDescendants()) do
      if v:IsA("ParticleEmitter") then
        v.Parent = workspace 
      end
    end
  end

local ChatSection = ExtraTab:NewSection("Chat")
		
ChatSection:NewToggle("IsChad", "?",function(x)
  if game.Players.LocalPlayer:FindFirstChild('IsChad') then
      game.Players.LocalPlayer.IsChad:Destroy()
      return
  end
      if x then
  local IsMod = Instance.new('IntValue', game.Players.LocalPlayer)
  IsMod.Name = "IsChad"
  end

end)

ChatSection:NewToggle("VIP", "?",function(x)
  if game.Players.LocalPlayer:FindFirstChild('VIP') then
      game.Players.LocalPlayer.VIP:Destroy()
      return
  end
  
  if x then
  local IsMod = Instance.new('IntValue', game.Players.LocalPlayer)
  IsMod.Name = "VIP"
  end
end)

ChatSection:NewToggle("OldVIP", "?",function(x)
  if game.Players.LocalPlayer:FindFirstChild('OldVIP') then
      game.Players.LocalPlayer.OldVIP:Destroy()
      return
  end
      if x then
  local IsMod = Instance.new('IntValue', game.Players.LocalPlayer)
  IsMod.Name = "OldVIP"
  end
end)

ChatSection:NewToggle("Romin", "?",function(x)
  if game.Players.LocalPlayer:FindFirstChild('Romin') then
      game.Players.LocalPlayer.Romin:Destroy()
      return
  end
      if x then
  local IsAdmin = Instance.new('IntValue', game.Players.LocalPlayer)
  IsAdmin.Name = "Romin"
  end
end)

ChatSection:NewToggle("IsAdmin", "?",function(x)
  if game.Players.LocalPlayer:FindFirstChild('IsAdmin') then
      game.Players.LocalPlayer.IsAdmin:Destroy()
      return
  end
      if x then
  local IsAdmin = Instance.new('IntValue', game.Players.LocalPlayer)
  IsAdmin.Name = "IsAdmin"
  end
end)

local Setting = Window:NewTab("Setting")
local Section = Setting:NewSection("Performance")
local originalMaterials = {}
local originalDecalsTextures = {}
local originalLightingSettings = {
    GlobalShadows = game.Lighting.GlobalShadows,
    FogEnd = game.Lighting.FogEnd,
    Brightness = game.Lighting.Brightness
}
local originalTerrainSettings = {
    WaterWaveSize = game.Workspace.Terrain.WaterWaveSize,
    WaterWaveSpeed = game.Workspace.Terrain.WaterWaveSpeed,
    WaterReflectance = game.Workspace.Terrain.WaterReflectance,
    WaterTransparency = game.Workspace.Terrain.WaterTransparency
}
local originalEffects = {}

Section:NewToggle("Anti Lag", "Removes textures.", function(state)
    if state then
        for ai, O in pairs(game:GetService("Workspace"):GetDescendants()) do
            if O:IsA("BasePart") and not O.Parent:FindFirstChild("Humanoid") then
                originalMaterials[O] = O.Material
                O.Material = Enum.Material.SmoothPlastic
                if O:IsA("Texture") then
                    table.insert(originalDecalsTextures, O)
                    O:Destroy()
                end
            end
        end
    else
        for O, material in pairs(originalMaterials) do
            if O and O:IsA("BasePart") then
                O.Material = material
            end
        end
        originalMaterials = {}
    end
end)

Section:NewToggle("FPS Boost", "Remove useless things.", function(state)
    if state then
        local g = game
        local w = g.Workspace
        local l = g.Lighting
        local t = w.Terrain
        originalTerrainSettings.WaterWaveSize = t.WaterWaveSize
        originalTerrainSettings.WaterWaveSpeed = t.WaterWaveSpeed
        originalTerrainSettings.WaterReflectance = t.WaterReflectance
        originalTerrainSettings.WaterTransparency = t.WaterTransparency

        t.WaterWaveSize = 0
        t.WaterWaveSpeed = 0
        t.WaterReflectance = 0
        t.WaterTransparency = 0
        l.GlobalShadows = false
        l.FogEnd = 9e9
        l.Brightness = 0
        settings().Rendering.QualityLevel = "Level01"

        for i, v in pairs(g:GetDescendants()) do
            if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
                originalMaterials[v] = v.Material
                v.Material = "Plastic"
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                table.insert(originalDecalsTextures, v)
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Lifetime = NumberRange.new(0)
            elseif v:IsA("Explosion") then
                v.BlastPressure = 1
                v.BlastRadius = 1
            elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") then
                v.Enabled = false
            elseif v:IsA("MeshPart") then
                originalMaterials[v] = v.Material
                v.Material = "Plastic"
                v.Reflectance = 0
                v.TextureID = 10385902758728957
            end
        end

        for i, e in pairs(l:GetChildren()) do
            if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
                originalEffects[e] = e.Enabled
                e.Enabled = false
            end
        end
    else
        local t = game.Workspace.Terrain
        t.WaterWaveSize = originalTerrainSettings.WaterWaveSize
        t.WaterWaveSpeed = originalTerrainSettings.WaterWaveSpeed
        t.WaterReflectance = originalTerrainSettings.WaterReflectance
        t.WaterTransparency = originalTerrainSettings.WaterTransparency

        game.Lighting.GlobalShadows = originalLightingSettings.GlobalShadows
        game.Lighting.FogEnd = originalLightingSettings.FogEnd
        game.Lighting.Brightness = originalLightingSettings.Brightness

        settings().Rendering.QualityLevel = "Automatic"

        for v, material in pairs(originalMaterials) do
            if v and v:IsA("BasePart") then
                v.Material = material
                v.Reflectance = 0
            end
        end
        originalMaterials = {}

        for e, enabled in pairs(originalEffects) do
            if e then
                e.Enabled = enabled
            end
        end
        originalEffects = {}
        
        for _, v in pairs(originalDecalsTextures) do
            if v and v.Parent then
                v.Transparency = 0
            end
        end
        originalDecalsTextures = {}
    end
end)

local fullBrightEnabled = false
Section:NewToggle("Full Bright", "Makes it so you can see in the dark. No shadows!", function(enabled)
    fullBrightEnabled = enabled 

    local Light = game:GetService("Lighting")

    local function doFullBright()
        if fullBrightEnabled then
            Light.Ambient = Color3.new(1, 1, 1)
            Light.ColorShift_Bottom = Color3.new(1, 1, 1)
            Light.ColorShift_Top = Color3.new(1, 1, 1)
        else
            Light.Ambient = Color3.new(0.5, 0.5, 0.5)
            Light.ColorShift_Bottom = Color3.new(0, 0, 0)
            Light.ColorShift_Top = Color3.new(0, 0, 0)
        end
    end

    doFullBright()

    Light.LightingChanged:Connect(doFullBright)
end)

local Section = Setting:NewSection("Server")
Section:NewButton("Server Hop", "?", function()
  local placeID = game.PlaceId
  local allIDs = {}
  local foundAnything = ""
  local actualHour = os.date("!*t").hour
  local deleted = false
  local file = pcall(function()
    allIDs = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
  end)

  if not file then
    table.insert(allIDs, actualHour)
    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(allIDs))
  end

  function teleportReturner()
    local site
    if foundAnything == "" then
      site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' ..
        placeID .. '/servers/Public?sortOrder=Asc&limit=100'))
    else
      site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' ..
        placeID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
    end

    local serverID = ""

    if site.nextPageCursor and site.nextPageCursor ~= "null" and site.nextPageCursor ~= nil then
      foundAnything = site.nextPageCursor
    end

    local num = 0

    for i, v in pairs(site.data) do
      local possible = true
      serverID = tostring(v.id)

      if tonumber(v.maxPlayers) > tonumber(v.playing) then
        for _, existing in pairs(allIDs) do
          if num ~= 0 then
            if serverID == tostring(existing) then
              possible = false
            end
          else
            if tonumber(actualHour) ~= tonumber(existing) then
              local delFile = pcall(function()
                delfile("NotSameServers.json")
                allIDs = {}
                table.insert(allIDs, actualHour)
              end)
            end
          end
          num = num + 1
        end

        if possible == true then
          table.insert(allIDs, serverID)
          wait()
          pcall(function()
            writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(allIDs))
            wait()
            game:GetService("TeleportService"):TeleportToPlaceInstance(placeID, serverID, game.Players.LocalPlayer)
          end)
          wait(4)
        end
      end
    end
  end

  function teleport()
    while wait() do
      pcall(function()
        teleportReturner()
        if foundAnything ~= "" then
          teleportReturner()
        end
      end)
    end
  end

  teleport()
end)

Section:NewButton("Rejoin Server", "Rejoins.", function()
  game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
end)

local keybindSection = Setting:NewSection("Keybind")
keybindSection:NewKeybind("Close UI", "Toggle UI", Enum.KeyCode.LeftControl, function()
  Library:ToggleUI()
end)
