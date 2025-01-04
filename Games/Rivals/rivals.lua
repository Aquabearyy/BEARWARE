local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/sxlent404/ModdedOrion/main/source.lua')))()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local assetFolder = LocalPlayer.PlayerScripts.Assets.ViewModels
local activeWeapons = {}

local settings = {
    esp_enabled = false,
    show_tracers = false,
    show_boxes = false,
    show_names = false,
    mouse_tracers = false,
    alive_check = false,
    distance_check = false,
    max_distance = 1000,
    triggerbot_enabled = false,
    triggerbot_delay = 0,
    triggerbot_wall_check = false,
    triggerbot_alive_check = false,
    triggerbot_target = "Head",
    triggerbot_require_rightclick = false,
    triggerbot_team_check = false,
    antiflash_enabled = false,
    antismoke_enabled = false,
}

local visual_elements = {}

local connections = {
    flash = {},
    smoke = {},
}

local function is_wall_between(origin, destination)
    local ray = Ray.new(origin, (destination - origin).Unit * 1000)
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    if hit then
        return (position - origin).Magnitude > (destination - origin).Magnitude
    end
    return false
end

local function is_player_alive(player)
    local character = player.Character
    if not character then return false end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return false end
    return humanoid.Health > 0
end

local function get_magnitude(player)
    local character = player.Character
    if not character then return math.huge end
    local humanoid_root_part = character:FindFirstChild("HumanoidRootPart")
    if not humanoid_root_part then return math.huge end
    return (humanoid_root_part.Position - Camera.CFrame.Position).Magnitude
end

local function create_esp(player)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 255, 255)
    box.Thickness = 1
    box.Transparency = 1
    box.Filled = false

    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = Color3.fromRGB(255, 255, 255)
    tracer.Thickness = 1
    tracer.Transparency = 1

    local name = Drawing.new("Text")
    name.Visible = false
    name.Center = true
    name.Outline = true
    name.Font = 2
    name.Size = 13
    name.Color = Color3.fromRGB(255, 255, 255)
    name.Transparency = 1

    return {
        box = box,
        tracer = tracer,
        name = name,
        connections = {}
    }
end

local function remove_esp(player)
    local elements = visual_elements[player]
    if not elements then return end
    
    for _, connection in pairs(elements.connections) do
        connection:Disconnect()
    end
    
    elements.box:Remove()
    elements.tracer:Remove()
    elements.name:Remove()
    
    visual_elements[player] = nil
end

local function add_esp(player)
    if player == LocalPlayer then return end
    if visual_elements[player] then remove_esp(player) end
    
    visual_elements[player] = create_esp(player)
    
    local function esp_update()
        local elements = visual_elements[player]
        if not elements then return end
        
        local character = player.Character
        local humanoid_root_part = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChild("Humanoid")
        
        if not settings.esp_enabled or not character or not humanoid_root_part or not humanoid then
            elements.box.Visible = false
            elements.tracer.Visible = false
            elements.name.Visible = false
            return
        end
        
        if settings.alive_check and humanoid.Health <= 0 then
            elements.box.Visible = false
            elements.tracer.Visible = false
            elements.name.Visible = false
            return
        end
        
        if settings.distance_check then
            local magnitude = get_magnitude(player)
            if magnitude > settings.max_distance then
                elements.box.Visible = false
                elements.tracer.Visible = false
                elements.name.Visible = false
                return
            end
        end
        
        local vector, on_screen = Camera:WorldToViewportPoint(humanoid_root_part.Position)
        
        if not on_screen then
            elements.box.Visible = false
            elements.tracer.Visible = false
            elements.name.Visible = false
            return
        end
        
        local size = Vector2.new(2000 / vector.Z, 2000 / vector.Z)
        elements.box.Size = size
        elements.box.Position = Vector2.new(vector.X - size.X / 2, vector.Y - size.Y / 2)
        elements.box.Visible = settings.show_boxes
        
        elements.tracer.From = settings.mouse_tracers and UserInputService:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        elements.tracer.To = Vector2.new(vector.X, vector.Y)
        elements.tracer.Visible = settings.show_tracers
        
        elements.name.Position = Vector2.new(vector.X, vector.Y - size.Y / 2 - 16)
        elements.name.Text = player.Name
        elements.name.Visible = settings.show_names
    end
    
    local connection = RunService.RenderStepped:Connect(esp_update)
    visual_elements[player].connections[#visual_elements[player].connections + 1] = connection
    
    esp_update()
end

local function toggle_esp(state)
    settings.esp_enabled = state
    if not state then
        for player, _ in pairs(visual_elements) do
            remove_esp(player)
        end
        return
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            add_esp(player)
        end
    end
end

local function swapWeaponSkins(normalWeaponName, skinName)
    if not normalWeaponName then return end
    local success, result = pcall(function()
        local normalWeapon = assetFolder:FindFirstChild(normalWeaponName)
        if not normalWeapon then return end
        if skinName then
            local skin = assetFolder:FindFirstChild(skinName)
            if not skin then return end
            normalWeapon:ClearAllChildren()
            for _, child in pairs(skin:GetChildren()) do
                local newChild = child:Clone()
                newChild.Parent = normalWeapon
            end
            activeWeapons[normalWeaponName] = true
        end
    end)
    if not success then
        warn("Failed to swap weapon skin:", result)
    end
end

local weaponSkins = {
    ["Assault Rifle"] = {"Default", "AUG", "Gingerbread AUG", "AK-47", "AKEY-47", "Boneclaw Rifle"},
    ["Bow"] = {"Default", "Raven Bow", "Bat Bow", "Compound Bow", "Frostbite Bow"},
    ["Burst Rifle"] = {"Default", "Pixel Burst", "Aqua Burst", "Electro Rifle", "Spectral Burst", "Pine Burst"},
    ["Crossbow"] = {"Default", "Pixel Crossbow", "Frostbite Crossbow"},
    ["Energy Rifle"] = {"Default", "Apex Rifle", "Hacker Rifle", "2025 Energy Rifle"},
    ["Flamethrower"] = {"Default", "Pixel Flamethrower", "Jack O'Thrower", "Lamethrower", "Snowblower"},
    ["Grenade Launcher"] = {"Default", "Uranium Launcher", "Skull Launcher", "Swashbuckler", "Snowball Launcher"},
    ["Minigun"] = {"Default", "Pixel Minigun", "Lasergun 3000", "Pumpkin Minigun", "Pumpkin Minigun"},
    ["Paintball Gun"] = {"Default", "Boba Gun", "Brain Gun", "Slime Gun", "Snowball Gun"},
    ["RPG"] = {"Default", "Spaceship Launcher", "Nuke Launcher", "Pumpkin Launcher", "RPKEY", "Firework Launcher"},
    ["Shotgun"] = {"Default", "Hyper Shotgun", "Balloon Shotgun", "Broomstick", "Wrapped Shotgun"},
    ["Sniper"] = {"Default", "Hyper Sniper", "Keyper", "Pixel Sniper", "Eyething Sniper", "Gingerbread Sniper"},
    ["Daggers"] = {"Default", "Aces", "Crystal Daggers", "Cookies"},
    ["Energy Pistols"] = {"Default", "Apex Pistols", "Hacker Pistols", "2025 Energy Pistols"},
    ["Exogun"] = {"Default", "Ray Gun", "Wondergun", "Singularity", "Exogourd", "Midnight Festive Exogun"},
    ["Flare Gun"] = {"Default", "Dynamite Gun", "Firework Gun", "Hexxed Flare Gun", "Wrapped Flaregun"},
    ["Handgun"] = {"Default", "Hand Gun", "Pixel Handgun", "Blaster", "Pumpkin Handgun", "Gingerbread Handgun"},
    ["Revolver"] = {"Default", "Sheriff", "Peppermint Sheriff", "Boneclaw Revolver", "Desert Eagle"},
    ["Shorty"] = {"Default", "Lovely Shorty", "Too Shorty", "Demon Shorty", "Not So Shorty", "Wrapped Shorty"},
    ["Slingshot"] = {"Default", "Goalpost", "Boneshot", "Stick", "Reindeer Slingshot",},
    ["Uzi"] = {"Default", "Electro Uzi", "Demon Uzi", "Water Uzi", "Pine Uzi"},
    ["Battle Axe"] = {"Default", "The Shred", "Nordic Axe"},
    ["Chainsaw"] = {"Default", "Handsaws", "Buzzsaw", "Blobsaw", "Festive Buzzsaw"},
    ["Fists"] = {"Default", "Boxing Gloves", "Brass Knuckles", "Pumpkin Claws", "Festive Fists"},
    ["Katana"] = {"Default", "Pixel Katana", "Saber", "Devil's Trident", "Lightning Bolt", "2025 Katana"},
    ["Knife"] = {"Default", "Karambit", "Chancla", "Machete", "Candy Cane"},
    ["Scythe"] = {"Default", "Anchor", "Keythe", "Bat Scythe", "Scythe of Death", "Cryo Scythe"},
    ["Trowel"] = {"Default", "Garden Shovel", "Plastic Shovel", "Pumpkin Carver"},
    ["Flashbang"] = {"Default", "Camera", "Pixel Flashbang", "Disco Ball", "Skullbang", "Snow Shovel"},
    ["Freeze Ray"] = {"Default", "Spider Ray", "Temporal Ray", "Bubble Ray", "Wrapped Freeze Ray"},
    ["Grenade"] = {"Default", "Soul Grenade", "Whoopee Cushion", "Water Balloon", "Jingle Grenade"},
    ["Medkit"] = {"Default", "Laptop", "Breifcase", "Bucket of Candy", "Sandwich", "Milk & Cookies"},
    ["Molotov"] = {"Default", "Hexxed Candle", "Coffee", "Torch", "Hot Coals"},
    ["Smoke Grenade"] = {"Default", "Balance", "Emoji Cloud", "Eyeball", "Snowglobe"},
    ["Warhorn"] = {"Trumpet", "Mammoth Horn", "Dev-in-the-Box"},
    ["Satchel"] = {"Suspicous Gift", "Advanced Satchel"},
    ["Subspace Tripmine"] = {"Default", "Don't Press", "Spring", "Trick or Treat"}
}

local primaryWeapons = {
    "Assault Rifle", "Bow", "Burst Rifle", "Crossbow", "Energy Rifle",
    "Flamethrower", "Grenade Launcher", "Minigun", "Paintball Gun",
    "RPG", "Shotgun", "Sniper"
}

local secondaryWeapons = {
    "Daggers", "Energy Pistols", "Exogun", "Flare Gun", "Handgun",
    "Revolver", "Shorty", "Slingshot", "Uzi"
}

local meleeWeapons = {
    "Battle Axe", "Chainsaw", "Fists", "Katana", "Knife", "Scythe", "Trowel"
}

local utilityWeapons = {
    "Flashbang", "Freeze Ray", "Grenade", "Medkit", "Molotov",
    "Smoke Grenade", "Subspace Tripmine", "Satchel", "Warhorn"
}

Players.PlayerAdded:Connect(function(player)
    if settings.esp_enabled then
        add_esp(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    remove_esp(player)
end)

local Window = OrionLib:MakeWindow({
    Name = "Bear Hub - Rivals | ".. identifyexecutor(),
    HidePremium = true,
    SaveConfig = true,
    IntroEnabled = false,
    ConfigFolder = "BearHub"
})

local VisualsTab = Window:MakeTab({
    Name = "Visuals",
    PremiumOnly = false
})

local TriggerbotTab = Window:MakeTab({
    Name = "Triggerbot",
    PremiumOnly = false
})

local SkinTab = Window:MakeTab({
    Name = "Skins",
    PremiumOnly = false
})

local MiscTab = Window:MakeTab({
    Name = "Misc",
    PremiumOnly = false
})

local Camera = workspace.CurrentCamera
local stretchConnection = nil
local stretchEnabled = nil
local stretchAmount = 0.2

local StretchSection = MiscTab:AddSection({
    Name = "Stretch Resolution"
})

StretchSection:AddToggle({
    Name = "Stretch Resolution",
    Default = false,
    Flag = "stretchToggle",
    Save = true,
    Callback = function(Value)
        if Value then
            if not stretchEnabled then
                stretchConnection = game:GetService("RunService").RenderStepped:Connect(function()
                    Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, stretchAmount, 0, 0, 0, 1)
                end)
            end
            stretchEnabled = true
        else
            if stretchConnection then
                stretchConnection:Disconnect()
                stretchConnection = nil
                stretchEnabled = nil
            end
        end
    end
})

StretchSection:AddSlider({
    Name = "Stretch Amount",
    Min = 0.1,
    Max = 1,
    Default = 0.2,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.1,
    ValueName = "x",
    Flag = "stretchAmount",
    Save = true,
    Callback = function(Value)
        stretchAmount = Value
    end
})

TriggerbotTab:AddToggle({
    Name = "Enable Triggerbot",
    Default = false,
    Flag = "TriggerbotEnabled",
    Save = true,
    Callback = function(Value)
        settings.triggerbot_enabled = Value
    end
})

TriggerbotTab:AddToggle({
    Name = "Wall Check",
    Default = false,
    Flag = "TriggerbotWallCheck",
    Save = true,
    Callback = function(Value)
        settings.triggerbot_wall_check = Value
    end
})

TriggerbotTab:AddToggle({
    Name = "Alive Check",
    Default = false,
    Flag = "TriggerbotAliveCheck",
    Save = true,
    Callback = function(Value)
        settings.triggerbot_alive_check = Value
    end
})

TriggerbotTab:AddToggle({
    Name = "Team Check",
    Default = false,
    Flag = "TriggerbotTeamCheck",
    Save = true,
    Callback = function(Value)
        settings.triggerbot_team_check = Value
    end
})

TriggerbotTab:AddToggle({
    Name = "Require Right Click",
    Default = false,
    Flag = "TriggerbotRightClick",
    Save = true,
    Callback = function(Value)
        settings.triggerbot_require_rightclick = Value
    end
})

TriggerbotTab:AddParagraph("⚠️ WARNING ⚠️", "Use Spray/Automatic weapons while right clicking might not work some times.")

TriggerbotTab:AddSlider({
    Name = "Delay (ms)",
    Min = 0,
    Max = 500,
    Default = 0,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 10,
    Flag = "TriggerbotDelay",
    Save = true,
    Callback = function(Value)
        settings.triggerbot_delay = Value / 1000
    end
})

TriggerbotTab:AddDropdown({
    Name = "Target Part",
    Default = "Head",
    Options = {"Head", "HumanoidRootPart", "Both"},
    Flag = "TriggerbotTargetPart",
    Save = true,
    Callback = function(Value)
        settings.triggerbot_target = Value
    end
})

VisualsTab:AddToggle({
    Name = "ESP Enabled",
    Default = false,
    Flag = "ESPEnabled",
    Save = true,
    Callback = function(Value)
        toggle_esp(Value)
    end
})

VisualsTab:AddToggle({
    Name = "Show Boxes",
    Default = false,
    Flag = "ShowBoxes",
    Save = true,
    Callback = function(Value)
        settings.show_boxes = Value
    end
})

VisualsTab:AddToggle({
    Name = "Show Tracers",
    Default = false,
    Flag = "ShowTracers",
    Save = true,
    Callback = function(Value)
        settings.show_tracers = Value
    end
})

VisualsTab:AddToggle({
    Name = "Show Names",
    Default = false,
    Flag = "ShowNames",
    Save = true,
    Callback = function(Value)
        settings.show_names = Value
    end
})

VisualsTab:AddToggle({
    Name = "Mouse Tracers",
    Default = false,
    Flag = "MouseTracers",
    Save = true,
    Callback = function(Value)
        settings.mouse_tracers = Value
    end
})

VisualsTab:AddToggle({
    Name = "Alive Check",
    Default = false,
    Flag = "AliveCheck",
    Save = true,
    Callback = function(Value)
        settings.alive_check = Value
    end
})

VisualsTab:AddToggle({
    Name = "Distance Check",
    Default = false,
    Flag = "DistanceCheck",
    Save = true,
    Callback = function(Value)
        settings.distance_check = Value
    end
})

VisualsTab:AddSlider({
    Name = "Max Distance",
    Min = 0,
    Max = 2000,
    Default = 1000,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 10,
    Flag = "MaxDistance",
    Save = true,
    Callback = function(Value)
        settings.max_distance = Value
    end
})

local AntiSection = MiscTab:AddSection({
    Name = "Anti's"
})

AntiSection:AddToggle({
    Name = "Anti Flashbang",
    Default = false,
    Flag = "AntiFlash",
    Save = true,
    Callback = function(Value)
        settings.antiflash_enabled = Value
        if Value then
            for _, connection in pairs(connections.flash) do
                connection:Disconnect()
            end
            table.clear(connections.flash)
            
            table.insert(connections.flash, Lighting.ChildAdded:Connect(function(child)
                if child.Name == "Flashbang" then
                    child:Destroy()
                end
            end))
            
            table.insert(connections.flash, workspace.ChildAdded:Connect(function(child)
                if child.Name == "FlashbangEffect" then
                    child:Destroy()
                end
            end))
            
            table.insert(connections.flash, LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
                if child.Name == "FlashbangGui" then
                    child:Destroy()
                end
            end))

            local flash = Lighting:FindFirstChild("Flashbang")
            if flash then flash:Destroy() end
            
            local effect = workspace:FindFirstChild("FlashbangEffect")
            if effect then effect:Destroy() end
            
            local gui = LocalPlayer.PlayerGui:FindFirstChild("FlashbangGui")
            if gui then gui:Destroy() end
        else
            for _, connection in pairs(connections.flash) do
                connection:Disconnect()
            end
            table.clear(connections.flash)
        end
    end
})

AntiSection:AddToggle({
    Name = "Anti Smoke Grenade",
    Default = false,
    Flag = "AntiSmoke",
    Save = true,
    Callback = function(Value)
        settings.antismoke_enabled = Value
        if Value then
            for _, connection in pairs(connections.smoke) do
                connection:Disconnect()
            end
            table.clear(connections.smoke)
            
            table.insert(connections.smoke, workspace.ChildAdded:Connect(function(child)
                if child.Name == "Smoke Grenade" then
                    child:Destroy()
                end
            end))

            table.insert(connections.smoke, RunService.Heartbeat:Connect(function()
                for _, smoke in ipairs(workspace:GetChildren()) do
                    if smoke.Name == "Smoke Grenade" then
                        smoke:Destroy()
                    end
                end
            end))
        else
            for _, connection in pairs(connections.smoke) do
                connection:Disconnect()
            end
            table.clear(connections.smoke)
        end
    end
})

local PrimarySection = SkinTab:AddSection({
    Name = "Primary Weapons"
})

local SecondarySection = SkinTab:AddSection({
    Name = "Secondary Weapons"
})

local MeleeSection = SkinTab:AddSection({
    Name = "Melee Weapons"
})

local UtilitySection = SkinTab:AddSection({
    Name = "Utility Items"
})

MiscTab:AddToggle({
    Name = "Save Settings",
    Default = true,
    Flag = "SaveSettings",
    Save = true,
    Callback = function(Value)
        Window.SaveConfig = Value
        OrionLib.SaveCfg = Value
        
        if not Value then
            local configFile = "BearHub/" .. game.PlaceId .. ".txt"
            if isfile(configFile) then
                delfile(configFile)
            end
        end
    end    
})

for _, weapon in pairs(primaryWeapons) do
    if weaponSkins[weapon] then
        PrimarySection:AddDropdown({
            Name = weapon,
            Default = "Default",
            Options = weaponSkins[weapon],
            Flag = weapon .. "Skin",
            Save = true,
            Callback = function(Value)
                if Value ~= "Default" then
                    swapWeaponSkins(weapon, Value)
                end
            end
        })
    end
end

for _, weapon in pairs(secondaryWeapons) do
    if weaponSkins[weapon] then
        SecondarySection:AddDropdown({
            Name = weapon,
            Default = "Default",
            Options = weaponSkins[weapon],
            Flag = weapon .. "Skin",
            Save = true,
            Callback = function(Value)
                if Value ~= "Default" then
                    swapWeaponSkins(weapon, Value)
                end
            end
        })
    end
end

for _, weapon in pairs(meleeWeapons) do
    if weaponSkins[weapon] then
        MeleeSection:AddDropdown({
            Name = weapon,
            Default = "Default",
            Options = weaponSkins[weapon],
            Flag = weapon .. "Skin",
            Save = true,
            Callback = function(Value)
                if Value ~= "Default" then
                    swapWeaponSkins(weapon, Value)
                end
            end
        })
    end
end

for _, weapon in pairs(utilityWeapons) do
    if weaponSkins[weapon] then
        UtilitySection:AddDropdown({
            Name = weapon,
            Default = "Default",
            Options = weaponSkins[weapon],
            Flag = weapon .. "Skin",
            Save = true,
            Callback = function(Value)
                if Value ~= "Default" then
                    swapWeaponSkins(weapon, Value)
                end
            end
        })
    end
end

local function isTeammate(player)
    local character = workspace:FindFirstChild(player.Name)
    if character then
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            local label = root:FindFirstChild("TeammateLabel")
            if label then
                local playerLabel = label:FindFirstChild("Player")
                if playerLabel then
                    return playerLabel.Visible
                end
            end
        end
    end
    return false
end

local isFiring = false
local isTargetValid = false

local function checkTriggerbot()
    if not settings.triggerbot_enabled then
        if isFiring then
            mouse1release()
            isFiring = false
        end
        isTargetValid = false
        return
    end
    
    if settings.triggerbot_require_rightclick and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        if isFiring then
            mouse1release()
            isFiring = false
        end
        isTargetValid = false
        return
    end
    
    local target = Mouse.Target
    if not target then
        if isFiring then
            mouse1release()
            isFiring = false
        end
        isTargetValid = false
        return
    end
    
    local character = target.Parent
    if not character then
        if isFiring then
            mouse1release()
            isFiring = false
        end
        isTargetValid = false
        return
    end
    
    local targetPart
    if settings.triggerbot_target == "Both" then
        targetPart = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    else
        targetPart = character:FindFirstChild(settings.triggerbot_target)
    end
    if not targetPart then
        if isFiring then
            mouse1release()
            isFiring = false
        end
        isTargetValid = false
        return
    end
    
    local player = Players:GetPlayerFromCharacter(character)
    if not player or player == LocalPlayer then
        if isFiring then
            mouse1release()
            isFiring = false
        end
        isTargetValid = false
        return
    end
    
    if settings.triggerbot_team_check and isTeammate(player) then
        if isFiring then
            mouse1release()
            isFiring = false
        end
        isTargetValid = false
        return
    end
    
    if settings.triggerbot_alive_check and not is_player_alive(player) then
        if isFiring then
            mouse1release()
            isFiring = false
        end
        isTargetValid = false
        return
    end
    
    if settings.triggerbot_wall_check and is_wall_between(Camera.CFrame.Position, targetPart.Position) then
        if isFiring then
            mouse1release()
            isFiring = false
        end
        isTargetValid = false
        return
    end
    
    isTargetValid = true
    
    if isTargetValid and not isFiring then
        task.wait(settings.triggerbot_delay)
        mouse1press()
        isFiring = true
    end
end

local lastCheck = 0
RunService.Heartbeat:Connect(function()
    local currentTime = time()
    if currentTime - lastCheck >= 0.01 then
        checkTriggerbot()
        lastCheck = currentTime
    end
end)

OrionLib:Init()
