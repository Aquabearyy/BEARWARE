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
    aimbot_enabled = false,
    aimbot_fov_size = 100,
    aimbot_aim_part = "Head",
    aimbot_keybind = Enum.KeyCode.E,
    aimbot_wall_check = false,
    aimbot_distance_check = false,
    aimbot_max_distance = 1000,
    show_fov = false,
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
    antiflash_enabled = false,
    antismoke_enabled = false,
}

local visual_elements = {}

local connections = {
    flash = {},
    smoke = {},
}

local fov_circle = Drawing.new("Circle")
fov_circle.Visible = false
fov_circle.Color = Color3.fromRGB(255, 255, 255)
fov_circle.Thickness = 1
fov_circle.Transparency = 1
fov_circle.Filled = false

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

local function getClosestPlayer()
    local closest_player = nil
    local shortest_distance = settings.aimbot_fov_size
    local mouse_pos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(settings.aimbot_aim_part) then
            if settings.alive_check and not is_player_alive(player) then
                continue
            end

            if settings.aimbot_distance_check then
                local magnitude = get_magnitude(player)
                if magnitude > settings.aimbot_max_distance then
                    continue
                end
            end

            local part = player.Character[settings.aimbot_aim_part]
            local screen_pos, on_screen = Camera:WorldToViewportPoint(part.Position)
            
            if on_screen then
                if settings.aimbot_wall_check and is_wall_between(Camera.CFrame.Position, part.Position) then
                    continue
                end
                
                local distance = (Vector2.new(screen_pos.X, screen_pos.Y) - mouse_pos).magnitude
                if distance < shortest_distance then
                    shortest_distance = distance
                    closest_player = player
                end
            end
        end
    end
    return closest_player
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
    ["Assault Rifle"] = {"Default", "AUG", "AK-47", "Boneclaw Rifle"},
    ["Bow"] = {"Default", "Raven Bow", "Bat Bow", "Compound Bow"},
    ["Burst Rifle"] = {"Default", "Pixel Burst", "Aqua Burst", "Electro Rifle", "Spectral Burst"},
    ["Crossbow"] = {"Default", "Pixel Crossbow"},
    ["Energy Rifle"] = {"Default", "Apex Rifle", "Hacker Rifle"},
    ["Flamethrower"] = {"Default", "Pixel Flamethrower", "Jack O'Thrower", "Lamethrower"},
    ["Grenade Launcher"] = {"Default", "Uranium Launcher", "Skull Launcher", "Swashbuckler"},
    ["Minigun"] = {"Default", "Pixel Minigun", "Lasergun 3000", "Pumpkin Minigun"},
    ["Paintball Gun"] = {"Default", "Boba Gun", "Brain Gun", "Slime Gun"},
    ["RPG"] = {"Default", "Spaceship Launcher", "Nuke Launcher", "Pumpkin Launcher", "RPKEY"},
    ["Shotgun"] = {"Default", "Hyper Shotgun", "Balloon Shotgun", "Broomstick"},
    ["Sniper"] = {"Default", "Hyper Sniper", "Keyper", "Pixel Sniper", "Eyething Sniper"},
    ["Daggers"] = {"Default", "Aces"},
    ["Energy Pistols"] = {"Default", "Apex Pistols", "Hacker Pistols"},
    ["Exogun"] = {"Default", "Ray Gun", "Wondergun", "Singularity", "Exogourd"},
    ["Flare Gun"] = {"Default", "Dynamite Gun", "Firework Gun", "Hexxed Flare Gun"},
    ["Handgun"] = {"Default", "Hand Gun", "Pixel Handgun", "Blaster", "Pumpkin Handgun"},
    ["Revolver"] = {"Default", "Sheriff", "Boneclaw Revolver", "Desert Eagle"},
    ["Shorty"] = {"Default", "Lovely Shorty", "Too Shorty", "Demon Shorty", "Not So Shorty"},
    ["Slingshot"] = {"Default", "Goalpost", "Boneshot", "Stick"},
    ["Uzi"] = {"Default", "Electro Uzi", "Demon Uzi", "Water Uzi"},
    ["Battle Axe"] = {"Default", "The Shred"},
    ["Chainsaw"] = {"Default", "Handsaws", "Buzzsaw", "Blobsaw"},
    ["Fists"] = {"Default", "Boxing Gloves", "Brass Knuckles", "Pumpkin Claws"},
    ["Katana"] = {"Default", "Pixel Katana", "Saber", "Devil's Trident", "Lightning Bolt"},
    ["Knife"] = {"Default", "Karambit", "Chancla", "Machete"},
    ["Scythe"] = {"Default", "Anchor", "Keythe", "Bat Scythe", "Scythe of Death"},
    ["Trowel"] = {"Default", "Garden Shovel", "Plastic Shovel", "Pumpkin Carver"},
    ["Flashbang"] = {"Default", "Camera", "Pixel Flashbang", "Disco Ball", "Skullbang"},
    ["Freeze Ray"] = {"Default", "Spider Ray", "Temporal Ray", "Bubble Ray"},
    ["Grenade"] = {"Default", "Soul Grenade", "Whoopee Cushion", "Water Balloon"},
    ["Medkit"] = {"Default", "Laptop", "Breifcase", "Bucket of Candy", "Sandwich"},
    ["Molotov"] = {"Default", "Hexxed Candle", "Coffee", "Torch"},
    ["Smoke Grenade"] = {"Default", "Balance", "Emoji Cloud", "Eyeball"},
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
    "Smoke Grenade", "Subspace Tripmine"
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

local AimbotTab
if identifyexecutor() == "Solara" or identifyexecutor() == "AWP" then
    AimbotTab = Window:MakeTab({
        Name = "Aimbot",
        Icon = "rbxassetid://10734898592",
        PremiumOnly = false
    })
    
    AimbotTab:AddToggle({
        Name = "Enable Aimbot",
        Default = false,
        Flag = "AimbotEnabled",
        Save = true,
        Callback = function(Value)
            settings.aimbot_enabled = Value
        end
    })
    
    AimbotTab:AddToggle({
        Name = "Wall Check",
        Default = false,
        Flag = "WallCheck",
        Save = true,
        Callback = function(Value)
            settings.aimbot_wall_check = Value
        end
    })
    
    AimbotTab:AddToggle({
        Name = "Distance Check",
        Default = false,
        Flag = "AimbotDistanceCheck",
        Save = true,
        Callback = function(Value)
            settings.aimbot_distance_check = Value
        end
    })
    
    AimbotTab:AddSlider({
        Name = "Max Distance",
        Min = 0,
        Max = 2000,
        Default = 1000,
        Color = Color3.fromRGB(255, 255, 255),
        Increment = 10,
        Flag = "AimbotMaxDistance",
        Save = true,
        Callback = function(Value)
            settings.aimbot_max_distance = Value
        end
    })
    
    AimbotTab:AddToggle({
        Name = "Show FOV",
        Default = false,
        Flag = "ShowFOV",
        Save = true,
        Callback = function(Value)
            settings.show_fov = Value
        end
    })
    
    AimbotTab:AddBind({
        Name = "Aimbot Key",
        Default = Enum.KeyCode.E,
        Hold = false,
        Flag = "AimbotBind",
        Save = true,
        Callback = function(Key)
            settings.aimbot_keybind = Key
        end
    })
    
    AimbotTab:AddDropdown({
        Name = "Aim Part",
        Default = "Head",
        Options = {"Head", "HumanoidRootPart"},
        Flag = "AimPart",
        Save = true,
        Callback = function(Value)
            settings.aimbot_aim_part = Value
        end
    })
    
    AimbotTab:AddSlider({
        Name = "FOV Size",
        Min = 0,
        Max = 800,
        Default = 100,
        Color = Color3.fromRGB(255, 255, 255),
        Increment = 10,
        Flag = "FOVSize",
        Save = true,
        Callback = function(Value)
            settings.aimbot_fov_size = Value
        end
    })
end

local VisualsTab = Window:MakeTab({
    Name = "Visuals",
    Icon = "rbxassetid://10723346959",
    PremiumOnly = false
})

local TriggerbotTab = Window:MakeTab({
    Name = "Triggerbot",
    Icon = "rbxassetid://10734898355",
    PremiumOnly = false
})

local SkinTab = Window:MakeTab({
    Name = "Skins",
    Icon = "rbxassetid://10734950020",
    PremiumOnly = false
})

local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://10734950309",
    PremiumOnly = false
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
        
        OrionLib:MakeNotification({
            Name = "Settings",
            Content = Value and "Your settings will now be saved" or "Your settings will not be saved",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
        
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

local function checkTriggerbot()
    if not settings.triggerbot_enabled then return end
    
    local target = Mouse.Target
    if target and target.Parent then
        local character = target.Parent
        local targetPart
        if settings.triggerbot_target == "Both" then
            targetPart = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
        else
            targetPart = character:FindFirstChild(settings.triggerbot_target)
        end
        if not targetPart then return end
        
        local player = Players:GetPlayerFromCharacter(character)
        if not player or player == LocalPlayer then return end
        
        if settings.triggerbot_alive_check and not is_player_alive(player) then return end
        if settings.triggerbot_wall_check and is_wall_between(Camera.CFrame.Position, targetPart.Position) then return end
        
        task.wait(settings.triggerbot_delay)
        mouse1press()
        task.wait()
        mouse1release()
    end
end

RunService.Heartbeat:Connect(function()
    checkTriggerbot()

    if settings.show_fov then
        local mouse_pos = UserInputService:GetMouseLocation()
        fov_circle.Radius = settings.aimbot_fov_size
        fov_circle.Position = mouse_pos
        fov_circle.Visible = true
    else
        fov_circle.Visible = false
    end

    if settings.aimbot_enabled and UserInputService:IsKeyDown(settings.aimbot_keybind) then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(settings.aimbot_aim_part) then
            local part = target.Character[settings.aimbot_aim_part]
            local screen_pos = Camera:WorldToViewportPoint(part.Position)
            local target_pos = Vector2.new(screen_pos.X, screen_pos.Y)
            local mouse_pos = UserInputService:GetMouseLocation()
            local move = target_pos - mouse_pos
            mousemoverel(move.X, move.Y)
        end
    end
end)

OrionLib:Init()
