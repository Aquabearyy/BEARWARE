local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/MS-ESP/refs/heads/main/source.lua"))()
local ESPTable = {}

local Settings = {
    FillColor = Color3.new(1, 1, 1),
    OutlineColor = Color3.new(1, 1, 1),
    TextColor = Color3.new(1, 1, 1),
    TracerColor = Color3.new(1, 1, 1),
    ArrowColor = Color3.new(1, 1, 1),
    
    TextSize = 22,
    MaxDistance = 5000,
    FillTransparency = 0.75,
    OutlineTransparency = 0,
    ArrowOffset = 300,
    TracerOrigin = "Bottom",
    
    ShowDistance = true,
    ShowTracers = true,
    ShowArrows = true,
    ShowHealthText = true,
    RainbowESP = false,
    
    ESPEnabled = false
}

local function GetDisplayText(player)
    local text = player.Name
    if Settings.ShowHealthText and player.Character and player.Character:FindFirstChild("Humanoid") then
        text = string.format("%s [%.1f]", text, player.Character.Humanoid.Health)
    end
    return text
end

local function UpdateESP(player)
    if not ESPTable[player] or not ESPTable[player].ESP then return end
    
    local playerEsp = ESPTable[player].ESP
    playerEsp.Update({
        FillColor = Settings.FillColor,
        OutlineColor = Settings.OutlineColor,
        TextColor = Settings.TextColor,
        TextSize = Settings.TextSize,
        FillTransparency = Settings.FillTransparency,
        OutlineTransparency = Settings.OutlineTransparency,
        Tracer = {
            Enabled = Settings.ShowTracers,
            From = Settings.TracerOrigin,
            Color = Settings.TracerColor
        },
        Arrow = {
            Enabled = Settings.ShowArrows,
            CenterOffset = Settings.ArrowOffset,
            Color = Settings.ArrowColor
        }
    })
    playerEsp.SetText(GetDisplayText(player))
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
    if not (player.Character and player.Character.PrimaryPart and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0) then return end

    local playerEsp = ESPLibrary.ESP.Highlight({
        Name = GetDisplayText(player),
        Model = player.Character,
        MaxDistance = Settings.MaxDistance,
        FillColor = Settings.FillColor,
        OutlineColor = Settings.OutlineColor,
        TextColor = Settings.TextColor,
        TextSize = Settings.TextSize,
        FillTransparency = Settings.FillTransparency,
        OutlineTransparency = Settings.OutlineTransparency,
        Tracer = {
            Enabled = Settings.ShowTracers,
            From = Settings.TracerOrigin,
            Color = Settings.TracerColor
        },
        Arrow = {
            Enabled = Settings.ShowArrows,
            CenterOffset = Settings.ArrowOffset,
            Color = Settings.ArrowColor
        },
    })
    
    ESPTable[player] = {
        ESP = playerEsp,
        Connections = {}
    }
    
    ESPTable[player].Connections.HealthChanged = player.Character.Humanoid.HealthChanged:Connect(function(newHealth)
        if newHealth > 0 then
            playerEsp.SetText(GetDisplayText(player))
        else
            HandleCharacter(player)
        end
    end)
    
    ESPTable[player].Connections.CharacterRemoving = player.CharacterRemoving:Connect(function()
        HandleCharacter(player)
    end)
    
    ESPTable[player].Connections.CharacterAdded = player.CharacterAdded:Connect(function()
        HandleCharacter(player)
    end)
end

local function HandleCharacter(player)
    if not Settings.ESPEnabled then return end
    if player == game.Players.LocalPlayer then return end
    
    RemoveESP(player)
    CreateESP(player)
end

local function RefreshAllESP()
    if not Settings.ESPEnabled then return end
    
    for player in pairs(ESPTable) do
        RemoveESP(player)
    end
    table.clear(ESPTable)
    
    for _, player in ipairs(game.Players:GetPlayers()) do
        HandleCharacter(player)
    end
end

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "ESP", HidePremium = false})

local MainTab = Window:MakeTab({
    Name = "ESP",
    Icon = "rbxassetid://4483345998"
})

local ToggleSection = MainTab:AddSection({Name = "Toggles"})

ToggleSection:AddToggle({
    Name = "Player ESP",
    Default = false,
    Callback = function(Value)
        Settings.ESPEnabled = Value
        if Value then
            for _, player in ipairs(game.Players:GetPlayers()) do
                HandleCharacter(player)
            end
            
            game.Players.PlayerAdded:Connect(function(player)
                HandleCharacter(player)
            end)
            
            game.Players.PlayerRemoving:Connect(function(player)
                RemoveESP(player)
            end)
        else
            for player in pairs(ESPTable) do
                RemoveESP(player)
            end
            table.clear(ESPTable)
        end
    end    
})

ToggleSection:AddToggle({
    Name = "Show Health",
    Default = true,
    Callback = function(Value)
        Settings.ShowHealthText = Value
        RefreshAllESP()
    end
})

ToggleSection:AddToggle({
    Name = "Show Distance",
    Default = true,
    Callback = function(Value)
        Settings.ShowDistance = Value
        ESPLibrary.Distance.Set(Value)
    end
})

ToggleSection:AddToggle({
    Name = "Show Tracers",
    Default = true,
    Callback = function(Value)
        Settings.ShowTracers = Value
        RefreshAllESP()
    end
})

ToggleSection:AddDropdown({
    Name = "Tracer Origin",
    Default = "Bottom",
    Options = {"Top", "Center", "Bottom", "Mouse"},
    Callback = function(Value)
        Settings.TracerOrigin = Value
        RefreshAllESP()
    end    
})

ToggleSection:AddToggle({
    Name = "Show Arrows",
    Default = true,
    Callback = function(Value)
        Settings.ShowArrows = Value
        RefreshAllESP()
    end
})

ToggleSection:AddToggle({
    Name = "Rainbow ESP",
    Default = false,
    Callback = function(Value)
        Settings.RainbowESP = Value
        ESPLibrary.Rainbow.Set(Value)
    end
})

local ColorSection = MainTab:AddSection({Name = "Colors"})

ColorSection:AddColorpicker({
    Name = "Fill Color",
    Default = Color3.new(1, 1, 1),
    Callback = function(Value)
        Settings.FillColor = Value
        RefreshAllESP()
    end
})

ColorSection:AddColorpicker({
    Name = "Outline Color",
    Default = Color3.new(1, 1, 1),
    Callback = function(Value)
        Settings.OutlineColor = Value
        RefreshAllESP()
    end
})

ColorSection:AddColorpicker({
    Name = "Text Color",
    Default = Color3.new(1, 1, 1),
    Callback = function(Value)
        Settings.TextColor = Value
        RefreshAllESP()
    end
})

ColorSection:AddColorpicker({
    Name = "Tracer Color",
    Default = Color3.new(1, 1, 1),
    Callback = function(Value)
        Settings.TracerColor = Value
        RefreshAllESP()
    end
})

ColorSection:AddColorpicker({
    Name = "Arrow Color",
    Default = Color3.new(1, 1, 1),
    Callback = function(Value)
        Settings.ArrowColor = Value
        RefreshAllESP()
    end
})

local ConfigSection = MainTab:AddSection({Name = "Configuration"})

ConfigSection:AddSlider({
    Name = "Text Size",
    Min = 12,
    Max = 32,
    Default = 22,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    Callback = function(Value)
        Settings.TextSize = Value
        RefreshAllESP()
    end    
})

ConfigSection:AddSlider({
    Name = "Fill Transparency",
    Min = 0,
    Max = 1,
    Default = 0.75,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.05,
    Callback = function(Value)
        Settings.FillTransparency = Value
        RefreshAllESP()
    end    
})

ConfigSection:AddSlider({
    Name = "Outline Transparency",
    Min = 0,
    Max = 1,
    Default = 0,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.05,
    Callback = function(Value)
        Settings.OutlineTransparency = Value
        RefreshAllESP()
    end    
})

ConfigSection:AddSlider({
    Name = "Arrow Offset",
    Min = 100,
    Max = 500,
    Default = 300,
    Color = Color3.fromRGB(255,255,255),
    Increment = 25,
    Callback = function(Value)
        Settings.ArrowOffset = Value
        RefreshAllESP()
    end    
})

OrionLib:Init()
