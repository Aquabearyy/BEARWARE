if not game:IsLoaded() then
    game.Loaded:Wait()
end

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = string.format('SilentHub - %s | %s', game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name, identifyexecutor()),
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Main = Window:AddTab('Main'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera
local UserInputService = game:GetService("UserInputService")

local ESPSettings = {
    Enabled = false,
    BoxesEnabled = false,
    TracersEnabled = false,
    SkeletonEnabled = false,
    RainbowBoxes = false,
    RainbowTracers = false,
    RainbowSkeleton = false,
    MouseTracer = false,
    BoxColor = Color3.fromRGB(255, 0, 0),
    TracerColor = Color3.fromRGB(255, 0, 0),
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    BoxThickness = 1,
    TracerThickness = 1,
    SkeletonThickness = 1
}

getgenv().Settings = ESPSettings

local ESPObjects = {}

local SkeletonPoints = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
}

local function CreateSkeletonLines()
    local Lines = {}
    for i = 1, #SkeletonPoints do
        local Line = Drawing.new("Line")
        Line.Thickness = ESPSettings.SkeletonThickness
        Line.Transparency = 1
        table.insert(Lines, Line)
    end
    return Lines
end

local function CreateESPObjects()
    local Box = Drawing.new("Square")
    Box.Thickness = ESPSettings.BoxThickness
    Box.Filled = false
    Box.Transparency = 1
    
    local Tracer = Drawing.new("Line")
    Tracer.Thickness = ESPSettings.TracerThickness
    Tracer.Transparency = 1
    
    local SkeletonLines = CreateSkeletonLines()
    
    return {
        Box = Box,
        Tracer = Tracer,
        Skeleton = SkeletonLines
    }
end

local function UpdateESP(player)
    if not ESPObjects[player] then
        ESPObjects[player] = CreateESPObjects()
    end
    
    local objects = ESPObjects[player]
    
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        objects.Box.Visible = false
        objects.Tracer.Visible = false
        for _, line in ipairs(objects.Skeleton) do
            line.Visible = false
        end
        return
    end

    local character = player.Character
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
    
    if not onScreen then
        objects.Box.Visible = false
        objects.Tracer.Visible = false
        for _, line in ipairs(objects.Skeleton) do
            line.Visible = false
        end
        return
    end

    if ESPSettings.BoxesEnabled then
        local rootPos = hrp.Position
        local boxSize = Vector2.new(4000 / vector.Z, 5000 / vector.Z)
        objects.Box.Size = boxSize
        objects.Box.Position = Vector2.new(vector.X - boxSize.X / 2, vector.Y - boxSize.Y / 2)
        objects.Box.Visible = true
        objects.Box.Thickness = ESPSettings.BoxThickness
        if ESPSettings.RainbowBoxes then
            objects.Box.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        else
            objects.Box.Color = ESPSettings.BoxColor
        end
    else
        objects.Box.Visible = false
    end

    if ESPSettings.TracersEnabled then
        objects.Tracer.From = ESPSettings.MouseTracer and UserInputService:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        objects.Tracer.To = Vector2.new(vector.X, vector.Y)
        objects.Tracer.Visible = true
        objects.Tracer.Thickness = ESPSettings.TracerThickness
        if ESPSettings.RainbowTracers then
            objects.Tracer.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        else
            objects.Tracer.Color = ESPSettings.TracerColor
        end
    else
        objects.Tracer.Visible = false
    end

    if ESPSettings.SkeletonEnabled then
        for i, point in ipairs(SkeletonPoints) do
            local p1 = character:FindFirstChild(point[1])
            local p2 = character:FindFirstChild(point[2])
            
            if p1 and p2 then
                local p1_pos, p1_visible = Camera:WorldToViewportPoint(p1.Position)
                local p2_pos, p2_visible = Camera:WorldToViewportPoint(p2.Position)
                
                if p1_visible and p2_visible then
                    objects.Skeleton[i].From = Vector2.new(p1_pos.X, p1_pos.Y)
                    objects.Skeleton[i].To = Vector2.new(p2_pos.X, p2_pos.Y)
                    objects.Skeleton[i].Thickness = ESPSettings.SkeletonThickness
                    objects.Skeleton[i].Visible = true
                    
                    if ESPSettings.RainbowSkeleton then
                        objects.Skeleton[i].Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                    else
                        objects.Skeleton[i].Color = ESPSettings.SkeletonColor
                    end
                else
                    objects.Skeleton[i].Visible = false
                end
            else
                objects.Skeleton[i].Visible = false
            end
        end
    else
        for _, line in ipairs(objects.Skeleton) do
            line.Visible = false
        end
    end
end

local ESPGroup = Tabs.Main:AddLeftGroupbox('ESP Settings')
local BoxGroup = Tabs.Main:AddRightGroupbox('Box ESP')
local TracerGroup = Tabs.Main:AddRightGroupbox('Tracer ESP')
local SkeletonGroup = Tabs.Main:AddRightGroupbox('Skeleton ESP')

ESPGroup:AddToggle('ESP_Enabled', {
    Text = 'Enable ESP',
    Default = false,
    Callback = function(Value)
        ESPSettings.Enabled = Value
    end
})

BoxGroup:AddToggle('BoxESP', {
    Text = 'Box ESP',
    Default = false,
    Callback = function(Value)
        ESPSettings.BoxesEnabled = Value
    end
})

BoxGroup:AddToggle('RainbowBoxes', {
    Text = 'Rainbow Boxes',
    Default = false,
    Callback = function(Value)
        ESPSettings.RainbowBoxes = Value
    end
})

BoxGroup:AddLabel('Box Color'):AddColorPicker('BoxColor', {
    Default = ESPSettings.BoxColor,
    Title = 'ESP Box Color',
    Callback = function(Value)
        ESPSettings.BoxColor = Value
    end
})

BoxGroup:AddSlider('BoxThickness', {
    Text = 'Box Thickness',
    Default = 1,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Callback = function(Value)
        ESPSettings.BoxThickness = Value
    end
})

TracerGroup:AddToggle('TracerESP', {
    Text = 'Tracer ESP',
    Default = false,
    Callback = function(Value)
        ESPSettings.TracersEnabled = Value
    end
})

TracerGroup:AddToggle('MouseTracer', {
    Text = 'Mouse Tracers',
    Default = false,
    Callback = function(Value)
        ESPSettings.MouseTracer = Value
    end
})

TracerGroup:AddToggle('RainbowTracers', {
    Text = 'Rainbow Tracers',
    Default = false,
    Callback = function(Value)
        ESPSettings.RainbowTracers = Value
    end
})

TracerGroup:AddLabel('Tracer Color'):AddColorPicker('TracerColor', {
    Default = ESPSettings.TracerColor,
    Title = 'ESP Tracer Color',
    Callback = function(Value)
        ESPSettings.TracerColor = Value
    end
})

TracerGroup:AddSlider('TracerThickness', {
    Text = 'Tracer Thickness',
    Default = 1,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Callback = function(Value)
        ESPSettings.TracerThickness = Value
    end
})

SkeletonGroup:AddToggle('SkeletonESP', {
    Text = 'Skeleton ESP',
    Default = false,
    Callback = function(Value)
        ESPSettings.SkeletonEnabled = Value
    end
})

SkeletonGroup:AddToggle('RainbowSkeleton', {
    Text = 'Rainbow Skeleton',
    Default = false,
    Callback = function(Value)
        ESPSettings.RainbowSkeleton = Value
    end
})

SkeletonGroup:AddLabel('Skeleton Color'):AddColorPicker('SkeletonColor', {
    Default = ESPSettings.SkeletonColor,
    Title = 'ESP Skeleton Color',
    Callback = function(Value)
        ESPSettings.SkeletonColor = Value
    end
})

SkeletonGroup:AddSlider('SkeletonThickness', {
    Text = 'Skeleton Thickness',
    Default = 1,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Callback = function(Value)
        ESPSettings.SkeletonThickness = Value
    end
})

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('SilentHub')
SaveManager:SetFolder('SilentHub/specific-game')

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])

Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, object in pairs(ESPObjects[player]) do
            if typeof(object) == "table" then
                for _, line in ipairs(object) do
                    line:Remove()
                end
            else
                object:Remove()
            end
        end
        ESPObjects[player] = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if ESPSettings.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                UpdateESP(player)
            end
        end
    else
        for _, objects in pairs(ESPObjects) do
            objects.Box.Visible = false
            objects.Tracer.Visible = false
            for _, line in ipairs(objects.Skeleton) do
                line.Visible = false
            end
        end
    end
end)

Library:Init()
