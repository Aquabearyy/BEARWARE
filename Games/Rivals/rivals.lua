--[[
    ____                    _    _       _     
   |  _ \                  | |  | |     | |    
   | |_) | ___  __ _ _ __  | |__| |_   _| |__  
   |  _ < / _ \/ _` | '__| |  __  | | | | '_ \ 
   | |_) |  __/ (_| | |    | |  | | |_| | |_) |
   |____/ \___|\__,_|_|    |_|  |_|\__,_|_.__/ 
]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/sxlent404/temp/main/orionSource.lua')))()
local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/sxlent404/temp/main/MS-ESP.lua"))()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local assetFolder = game:GetService("Players").LocalPlayer.PlayerScripts.Assets.ViewModels
local activeWeapons = {}

local settings = {
    esp_enabled = false,
    esp_fill_color = Color3.new(1, 1, 1),
    esp_outline_color = Color3.new(1, 1, 1),
    esp_text_color = Color3.new(1, 1, 1),
    esp_tracer_color = Color3.new(1, 1, 1),
    esp_fill_transparency = 0.75,
    esp_outline_transparency = 0,
    esp_text_size = 22,
    esp_tracers = true,
    esp_names = true,
    show_distance = true,
    show_health = true,
    rainbow_esp = false,
    tracer_origin = "Bottom",

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

local ESPTable = {}
local MAX_DISTANCE = 500

local connections = {
    flash = {},
    smoke = {},
}

local function GetHealthColor(health, maxHealth)
    local healthPercent = health/maxHealth

    if healthPercent > 0.75 then
        return Color3.fromRGB(0, 255, 0) 
    elseif healthPercent > 0.50 then
        return Color3.fromRGB(255, 255, 0)
    elseif healthPercent > 0.25 then
        return Color3.fromRGB(255, 125, 0)
    else
        return Color3.fromRGB(255, 0, 0)
    end
end

local function GetDisplayText(player)
    if not player or not player.Character then return "" end
    
    local text = {}
    local humanoid = player.Character:FindFirstChild("Humanoid")

    if settings.esp_names then
        table.insert(text, player.Name)
    end
    
    if settings.show_health and humanoid then
        local healthColor = GetHealthColor(humanoid.Health, humanoid.MaxHealth)
        local colorHex = string.format("#%.2x%.2x%.2x", 
            math.floor(healthColor.R * 255),
            math.floor(healthColor.G * 255),
            math.floor(healthColor.B * 255)
        )
        local healthText = string.format("<font color='%s'>[%.0f]</font>", colorHex, humanoid.Health)
        table.insert(text, healthText)
    end
    
    return table.concat(text, " ")
end

local function RemoveESP(player)
    if ESPTable[player] then
        if ESPTable[player].ESP then
            ESPTable[player].ESP.Destroy()
        end
        
        for _, connection in pairs(ESPTable[player].Connections) do
            connection:Disconnect()
        end
        
        ESPTable[player] = nil
    end
end

local function CreateESP(player)
    if not player then return end
    
    RemoveESP(player)
    
    ESPTable[player] = {
        ESP = nil,
        Connections = {}
    }
    
    local function setupESP()
        local character = player.Character
        if not character then return end
        
        local humanoid = character:WaitForChild("Humanoid", 2)
        local rootPart = character:WaitForChild("HumanoidRootPart", 2)
        if not humanoid or not rootPart then return end
        
        local playerEsp = ESPLibrary.ESP.Highlight({
            Name = GetDisplayText(player),
            Model = character,
            FillColor = settings.esp_fill_color,
            OutlineColor = settings.esp_outline_color,
            TextColor = settings.esp_text_color,
            TextSize = settings.esp_text_size,
            FillTransparency = settings.esp_fill_transparency,
            OutlineTransparency = settings.esp_outline_transparency,
            RichText = true,
            Tracer = {
                Enabled = settings.esp_tracers,
                From = settings.tracer_origin,
                Color = settings.esp_tracer_color
            }
        })
        
        ESPTable[player].ESP = playerEsp
        
        ESPTable[player].Connections.HealthChanged = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if playerEsp then
                playerEsp.SetText(GetDisplayText(player))
            end
        end)
        
        ESPTable[player].Connections.DisplayNameChanged = player:GetPropertyChangedSignal("DisplayName"):Connect(function()
            if playerEsp then
                playerEsp.SetText(GetDisplayText(player))
            end
        end)
    end
    
    setupESP()
    ESPTable[player].Connections.CharacterAdded = player.CharacterAdded:Connect(setupESP)
end

local function HandleCharacter(player)
    if not settings.esp_enabled then return end
    if not player or player == game:GetService("Players").LocalPlayer then return end
    
    task.spawn(function()
        pcall(function()
            RemoveESP(player)
            task.wait(0.1)
            if player and player.Character then
                CreateESP(player)
            end
        end)
    end)
end

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

local function swapWeaponSkins(normalWeaponName, skinName)
    if not normalWeaponName then return end
    
    local normalWeapon = assetFolder:FindFirstChild(normalWeaponName)
    if not normalWeapon then return end
    
    if skinName and skinName ~= "Default" then
        local skin = assetFolder:FindFirstChild(skinName)
        if not skin then return end
        
        normalWeapon:ClearAllChildren()
        for _, child in pairs(skin:GetChildren()) do
            local newChild = child:Clone()
            newChild.Parent = normalWeapon
        end
        activeWeapons[normalWeaponName] = true
    else
        activeWeapons[normalWeaponName] = nil
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
    ["Warhorn"] = {"Default", "Trumpet", "Mammoth Horn", "Dev-in-the-Box"},
    ["Satchel"] = {"Default", "Suspicous Gift", "Advanced Satchel"},
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

local playerConnections = {}

local function SetupPlayerConnections(player)
    if playerConnections[player] then
        playerConnections[player]:Disconnect()
    end
    
    playerConnections[player] = player.CharacterAdded:Connect(function(char)
        task.wait(0.1)
        if settings.esp_enabled then
            RemoveESP(player)
            CreateESP(player)
        end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        SetupPlayerConnections(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    SetupPlayerConnections(player)
end)

Players.PlayerRemoving:Connect(function(player)
    if playerConnections[player] then
        playerConnections[player]:Disconnect()
        playerConnections[player] = nil
    end
    RemoveESP(player)
end)

local isLocked = false
local targetPlayer = nil
local highlight = nil

local function createHighlight(target)
    if highlight then highlight:Destroy() end
    highlight = Instance.new("Highlight")
    highlight.Parent = target.Character
    highlight.Adornee = target.Character
    highlight.FillColor = Color3.new(1, 0, 0)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
end

local function removeHighlight()
    if highlight then
        highlight:Destroy()
        highlight = nil
    end
end

local function isOnSameTeam(otherPlayer)
    if Players.LocalPlayer.Team and otherPlayer.Team then
        return Players.LocalPlayer.Team == otherPlayer.Team
    end
    return false
end

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= LocalPlayer and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if not isOnSameTeam(otherPlayer) then
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - otherPlayer.Character.HumanoidRootPart.Position).magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = otherPlayer
                end
            end
        end
    end
    return closestPlayer
end

local function lockOntoClosestPlayer()
    targetPlayer = getClosestPlayer()
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
        isLocked = true
        createHighlight(targetPlayer)
        RunService:BindToRenderStep("LockOnPlayer", Enum.RenderPriority.Camera.Value + 1, function()
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPlayer.Character.Head.Position)
            else
                isLocked = false
                removeHighlight()
                RunService:UnbindFromRenderStep("LockOnPlayer")
            end
        end)
    end
end

local function unlockCamera()
    isLocked = false
    RunService:UnbindFromRenderStep("LockOnPlayer")
    removeHighlight()
    targetPlayer = nil
end 

local Window = OrionLib:MakeWindow({
    Name = "Bear Hub - Rivals | ".. identifyexecutor(),
    HidePremium = true,
    SaveConfig = true,
    IntroEnabled = false,
    ConfigFolder = "BearHub"
})

local LockOnTab = Window:MakeTab({
    Name = "Aim",
    PremiumOnly = false
})

LockOnTab:AddToggle({
    Name = "Lock On",
    Default = false,
    Flag = "LockOnEnabled",
    Save = true,
    Callback = function(Value)
        if not Value then
            unlockCamera()
        end
    end
})

LockOnTab:AddBind({
    Name = "Lock On Keybind",
    Default = Enum.KeyCode.Q,
    Flag = "LockOnKey", 
    Save = true,
    Callback = function()
        if OrionLib.Flags["LockOnEnabled"].Value then
            if isLocked then
                unlockCamera()
            else
                lockOntoClosestPlayer()
            end
        end
    end
})

local VisualsTab = Window:MakeTab({
    Name = "Visuals",
    PremiumOnly = false
})

VisualsTab:AddToggle({
    Name = "ESP Enabled",
    Default = false,
    Flag = "ESPEnabled",
    Save = true,
    Callback = function(Value)
        settings.esp_enabled = Value
        if Value then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= LocalPlayer then
                    HandleCharacter(player)
                end
            end
        else
            for player in pairs(ESPTable) do
                RemoveESP(player)
            end
            table.clear(ESPTable)
        end
    end
})

VisualsTab:AddToggle({
    Name = "Show Names",
    Default = true,
    Flag = "ESPNames",
    Save = true,
    Callback = function(Value)
        settings.esp_names = Value
        if settings.esp_enabled then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= LocalPlayer then
                    HandleCharacter(player)
                end
            end
        end
    end
})

VisualsTab:AddToggle({
    Name = "Show Health",
    Default = true,
    Flag = "ShowHealth",
    Save = true,
    Callback = function(Value)
        settings.show_health = Value
        if settings.esp_enabled then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= LocalPlayer then
                    HandleCharacter(player)
                end
            end
        end
    end    
})

VisualsTab:AddToggle({
    Name = "Show Distance",
    Default = true,
    Flag = "ShowDistance", 
    Save = true,
    Callback = function(Value)
        settings.show_distance = Value
        ESPLibrary.Distance.Set(Value)
    end    
})

VisualsTab:AddToggle({
    Name = "Show Tracers",
    Default = true,
    Flag = "ESPTracers",
    Save = true,
    Callback = function(Value)
        settings.esp_tracers = Value
        if settings.esp_enabled then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= LocalPlayer then
                    HandleCharacter(player)
                end
            end
        end
    end
})

VisualsTab:AddDropdown({
    Name = "Tracer Origin",
    Default = "Bottom",
    Options = {"Top", "Center", "Bottom", "Mouse"},
    Flag = "TracerOrigin",
    Save = true,
    Callback = function(Value)
        settings.tracer_origin = Value
        if settings.esp_enabled then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= LocalPlayer then
                    HandleCharacter(player)
                end
            end
        end
    end
})

VisualsTab:AddToggle({
    Name = "Rainbow ESP",
    Default = false,
    Flag = "RainbowESP",
    Save = true,
    Callback = function(Value)
        settings.rainbow_esp = Value
        ESPLibrary.Rainbow.Set(Value)
    end
})

local ColorSection = VisualsTab:AddSection({
    Name = "ESP Colors"
})

ColorSection:AddColorpicker({
    Name = "Fill Color",
    Default = Color3.new(1, 1, 1),
    Flag = "ESPFillColor",
    Save = true,
    Callback = function(Value)
        settings.esp_fill_color = Value
        if settings.esp_enabled then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= LocalPlayer then
                    HandleCharacter(player)
                end
            end
        end
    end
})

ColorSection:AddColorpicker({
    Name = "Outline Color",
    Default = Color3.new(1, 1, 1),
    Flag = "ESPOutlineColor",
    Save = true,
    Callback = function(Value)
        settings.esp_outline_color = Value
        if settings.esp_enabled then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= LocalPlayer then
                    HandleCharacter(player)
                end
            end
        end
    end
})

ColorSection:AddColorpicker({
    Name = "Text Color",
    Default = Color3.new(1, 1, 1),
    Flag = "ESPTextColor",
    Save = true,
    Callback = function(Value)
        settings.esp_text_color = Value
        if settings.esp_enabled then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= LocalPlayer then
                    HandleCharacter(player)
                end
            end
        end
    end
})

ColorSection:AddColorpicker({
    Name = "Tracer Color",
    Default = Color3.new(1, 1, 1),
    Flag = "ESPTracerColor",
    Save = true,
    Callback = function(Value)
        settings.esp_tracer_color = Value
        if settings.esp_enabled then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= LocalPlayer then
                    HandleCharacter(player)
                end
            end
        end
    end
})

local ConfigSection = VisualsTab:AddSection({
    Name = "ESP Config"
})

ConfigSection:AddSlider({
    Name = "Text Size",
    Min = 12,
    Max = 32,
    Default = 22,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    Flag = "ESPTextSize",
    Save = true,
    Callback = function(Value)
        settings.esp_text_size = Value
        if settings.esp_enabled then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= LocalPlayer then
                    HandleCharacter(player)
                end
            end
        end
    end
})

ConfigSection:AddSlider({
    Name = "Fill Transparency",
    Min = 0,
    Max = 1,
    Default = 0.75,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.05,
    Flag = "ESPFillTransparency",
    Save = true,
    Callback = function(Value)
        settings.esp_fill_transparency = Value
        if settings.esp_enabled then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= LocalPlayer then
                    HandleCharacter(player)
                end
            end
        end
    end
})

ConfigSection:AddSlider({
    Name = "Outline Transparency",
    Min = 0,
    Max = 1,
    Default = 0,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.05,
    Flag = "ESPOutlineTransparency",
    Save = true,
    Callback = function(Value)
        settings.esp_outline_transparency = Value
        if settings.esp_enabled then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= LocalPlayer then
                    HandleCharacter(player)
                end
            end
        end
    end
})

local TriggerbotTab = Window:MakeTab({
    Name = "Triggerbot",
    PremiumOnly = false
})

local SkinTab = Window:MakeTab({
    Name = "Skins",
    PremiumOnly = false
})

SkinTab:AddParagraph("⚠️ WARNING ⚠️", "Some skins might glitch/break the game.")

local PrimarySection = SkinTab:AddSection({
    Name = "Primary Weapons"
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
                swapWeaponSkins(weapon, Value)
            end
        })
    end
end

local SecondarySection = SkinTab:AddSection({
    Name = "Secondary Weapons"
})

for _, weapon in pairs(secondaryWeapons) do
    if weaponSkins[weapon] then
        SecondarySection:AddDropdown({
            Name = weapon,
            Default = "Default",
            Options = weaponSkins[weapon],
            Flag = weapon .. "Skin",
            Save = true,
            Callback = function(Value)
                swapWeaponSkins(weapon, Value)
            end
        })
    end
end

local MeleeSection = SkinTab:AddSection({
    Name = "Melee Weapons"
})

for _, weapon in pairs(meleeWeapons) do
    if weaponSkins[weapon] then
        MeleeSection:AddDropdown({
            Name = weapon,
            Default = "Default",
            Options = weaponSkins[weapon],
            Flag = weapon .. "Skin",
            Save = true,
            Callback = function(Value)
                swapWeaponSkins(weapon, Value)
            end
        })
    end
end

local UtilitySection = SkinTab:AddSection({
    Name = "Utility Items"
})

for _, weapon in pairs(utilityWeapons) do
    if weaponSkins[weapon] then
        UtilitySection:AddDropdown({
            Name = weapon,
            Default = "Default",
            Options = weaponSkins[weapon],
            Flag = weapon .. "Skin",
            Save = true,
            Callback = function(Value)
                swapWeaponSkins(weapon, Value)
            end
        })
    end
end

local MiscTab = Window:MakeTab({
    Name = "Misc",
    PremiumOnly = false
})

local stretchConnection = nil
local stretchEnabled = nil
local stretchAmount = 0.8

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
    Default = 0.8,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.1,
    ValueName = "x",
    Flag = "stretchAmount",
    Save = true,
    Callback = function(Value)
        stretchAmount = Value
    end
})

StretchSection:AddParagraph("⚠️ WARNING ⚠️", "Stretch resolution might mess up ESP.")

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

TriggerbotTab:AddParagraph("⚠️ WARNING ⚠️", "While holding right click triggerbot might not work some times.")

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

local lastFireTime = 0
local fireDelay = 0.05

local function checkTriggerbot()
    local currentTime = time()
    
    if not settings.triggerbot_enabled then
        isFiring = false
        isTargetValid = false
        return
    end
    
    if settings.triggerbot_require_rightclick and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        isFiring = false
        isTargetValid = false
        return
    end
    
    local target = Mouse.Target
    if not target then
        isFiring = false
        isTargetValid = false
        return
    end
    
    local character = target.Parent
    if not character then
        isFiring = false
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
        isFiring = false
        isTargetValid = false
        return
    end
    
    local player = game:GetService("Players"):GetPlayerFromCharacter(character)
    if not player or player == LocalPlayer then
        isFiring = false
        isTargetValid = false
        return
    end
    
    if settings.triggerbot_team_check and isTeammate(player) then
        isFiring = false
        isTargetValid = false
        return
    end
    
    if settings.triggerbot_alive_check and not is_player_alive(player) then
        isFiring = false
        isTargetValid = false
        return
    end
    
    if settings.triggerbot_wall_check and is_wall_between(Camera.CFrame.Position, targetPart.Position) then
        isFiring = false
        isTargetValid = false
        return
    end
    
    isTargetValid = true
    
    if isTargetValid then
        if currentTime - lastFireTime >= fireDelay then
            task.spawn(function()
                if settings.triggerbot_delay > 0 then
                    task.wait(settings.triggerbot_delay)
                end
                mouse1click()
            end)
            lastFireTime = currentTime
        end
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

local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            pcall(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    
                    if distance <= 500 then
                        if not ESPTable[player] then
                            CreateESP(player)
                        else
                            if ESPTable[player].ESP then
                                ESPTable[player].ESP.SetText(settings.esp_names and GetDisplayText(player) or "")
                            end
                        end
                    else
                        RemoveESP(player)
                    end
                end
            end)
        end
    end
end

RunService.RenderStepped:Connect(function()
    if not settings.esp_enabled then return end
    
    for player, espData in pairs(ESPTable) do
        if espData.ESP and player.Character and player.Character:FindFirstChild("Humanoid") then
            espData.ESP.SetText(GetDisplayText(player))
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not settings.esp_enabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local success, err = pcall(function()
            local character = player.Character
            if not character then return end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end
            
            local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
            
            if distance <= MAX_DISTANCE then
                if not ESPTable[player] then
                    CreateESP(player)
                end
            else
                RemoveESP(player)
            end
        end)
        
        if not success then
            warn("ESP Update Error:", err)
        end
    end
end)

OrionLib:Init()
