local scriptName = "Bear Hub - Fisch | " .. identifyexecutor()

if getgenv().BearHubFischLoaded then
    return
end
getgenv().BearHubFischLoaded = true

local repo = "https://raw.githubusercontent.com/deividcomsono/LinoriaLib/refs/heads/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = scriptName,
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0
})

Library.ShowCustomCursor = false

local Tabs = {
    Main = Window:AddTab("Main"),
    ["UI Settings"] = Window:AddTab("UI Settings")
}

local MoneyGroupBox = Tabs.Main:AddLeftGroupbox("Money")
local PlayerGroupBox = Tabs.Main:AddLeftGroupbox("Player")
local AutosGroupBox = Tabs.Main:AddRightGroupbox("Auto's")

local fireEventEnabled = false
local fireEventCount = 1
local connection

local function startLoop()
    if connection then
        connection:Disconnect()
    end
    connection = game:GetService('RunService').Stepped:Connect(function()
        for i = 1, fireEventCount do
            game:GetService("ReplicatedStorage").packages.Net["RE/DailyReward/Claim"]:FireServer()
        end
    end)
end

local function stopLoop()
    if connection then
        connection:Disconnect()
        connection = nil
    end
end

MoneyGroupBox:AddToggle("FireEventToggle", {
    Text = "Enable Auto Claim",
    Default = false,
    Callback = function(Value)
        fireEventEnabled = Value
        if Value then
            startLoop()
        else
            stopLoop()
        end
    end
})

MoneyGroupBox:AddSlider("FireEventCount", {
    Text = "Claims per Step",
    Default = 1,
    Min = 1,
    Max = 250,
    Rounding = 0,
    Callback = function(Value)
        fireEventCount = Value
        if fireEventEnabled then
            startLoop()
        end
    end
})

MoneyGroupBox:AddToggle("DisableAnnouncementsUIs", {
    Text = "Disable Notification UI.",
    Tooltip = "Less lag.",
    Default = false,
    Callback = function(Value)
        if Value then
            game:GetService("Players").LocalPlayer.PlayerGui.hud.safezone.announcements.Visible = false
            game:GetService("Players").LocalPlayer.PlayerGui.hud.safezone.StatChangeList.Visible = false
        else
            game:GetService("Players").LocalPlayer.PlayerGui.hud.safezone.announcements.Visible = true
            game:GetService("Players").LocalPlayer.PlayerGui.hud.safezone.StatChangeList.Visible = true
        end
    end
})

local walkOnWaterEnabled = false
local originalGravity

PlayerGroupBox:AddToggle("WalkOnWaterToggle", {
    Text = "Walk on Water",
    Default = false,
    Callback = function(Value)
        walkOnWaterEnabled = Value
        for _, v in pairs(game:GetService("Workspace").zones.fishing:GetChildren()) do
            if v.Name == "Ocean" then
                v.CanCollide = Value
            end
        end
    end
})

local noFogEnabled = false
local originalFogProperties = {}

PlayerGroupBox:AddToggle("NoFogToggle", {
    Text = "No Fog",
    Default = false,
    Callback = function(Value)
        noFogEnabled = Value
        local lighting = game:GetService("Lighting")
        
        if noFogEnabled then
            originalFogProperties.FogEnd = lighting.FogEnd
            originalFogProperties.FogStart = lighting.FogStart
            originalFogProperties.FogColor = lighting.FogColor

            lighting.FogEnd = 100000
            lighting.FogStart = 0
            lighting.FogColor = Color3.new(1, 1, 1)

            for _, atmosphere in pairs(lighting:GetDescendants()) do
                if atmosphere:IsA("Atmosphere") then
                    atmosphere:Destroy()
                end
            end
        else
            lighting.FogEnd = originalFogProperties.FogEnd or 1000
            lighting.FogStart = originalFogProperties.FogStart or 0
            lighting.FogColor = originalFogProperties.FogColor or Color3.new(1, 1, 1)
        end
    end
})

local fullbrightEnabled = false
local originalLightingProperties = {}
local brightLoop = nil

PlayerGroupBox:AddToggle("FullbrightToggle", {
    Text = "Fullbright",
    Default = false,
    Callback = function(Value)
        fullbrightEnabled = Value
        local lighting = game:GetService("Lighting")
        local runService = game:GetService("RunService")

        if Value then
            originalLightingProperties.Ambient = lighting.Ambient
            originalLightingProperties.Brightness = lighting.Brightness
            originalLightingProperties.GlobalShadows = lighting.GlobalShadows
            originalLightingProperties.ClockTime = lighting.ClockTime
            originalLightingProperties.FogEnd = lighting.FogEnd
            originalLightingProperties.OutdoorAmbient = lighting.OutdoorAmbient

            local function brightFunc()
                lighting.Brightness = 2
                lighting.ClockTime = 14
                lighting.FogEnd = 100000
                lighting.GlobalShadows = false
                lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            end

            brightLoop = runService.RenderStepped:Connect(brightFunc)
        else
            if brightLoop then
                brightLoop:Disconnect()
                brightLoop = nil
            end

            lighting.Ambient = originalLightingProperties.Ambient or Color3.new(0.5, 0.5, 0.5)
            lighting.Brightness = originalLightingProperties.Brightness or 1
            lighting.GlobalShadows = originalLightingProperties.GlobalShadows or true
            lighting.ClockTime = originalLightingProperties.ClockTime or 14
            lighting.FogEnd = originalLightingProperties.FogEnd or 100000
            lighting.OutdoorAmbient = originalLightingProperties.OutdoorAmbient or Color3.fromRGB(128, 128, 128)
        end
    end
})

local infiniteOxygenEnabled = false

PlayerGroupBox:AddToggle("InfiniteOxygenToggle", {
    Text = "Infinite Oxygen",
    Default = false,
    Callback = function(Value)
        infiniteOxygenEnabled = Value
        local character = game:GetService("Players").LocalPlayer.Character
        if character and character:FindFirstChild("client") and character.client:FindFirstChild("oxygen") then
            character.client.oxygen.Disabled = Value
        end
    end
})

local autoFishEnabled = false
local autoCastEnabled = false
local autoReelEnabled = false
local autoShakeEnabled = false
local showLurePercentEnabled = false

local function autoFish()
    while autoFishEnabled do
        local RodName = game:GetService("ReplicatedStorage").playerstats[game.Players.LocalPlayer.Name].Stats.rod.Value
        local Backpack = game.Players.LocalPlayer.Backpack
        local Character = game.Players.LocalPlayer.Character
        local PlayerGui = game.Players.LocalPlayer.PlayerGui

        if Backpack and Backpack:FindFirstChild(RodName) then
            Character.Humanoid:EquipTool(Backpack:FindFirstChild(RodName))
        end

        if Character and Character:FindFirstChild(RodName) and Character:FindFirstChild(RodName):FindFirstChild("bobber") then
            local XyzClone = game:GetService("ReplicatedStorage").resources.items.items.GPS.GPS.gpsMain.xyz:Clone()
            XyzClone.Parent = PlayerGui.hud.safezone.backpack
            XyzClone.Name = "Lure"
            XyzClone.Text = "<font color='#ff4949'>Lure </font>: 0%"

            repeat
                if autoShakeEnabled then
                    pcall(function()
                        PlayerGui.shakeui.safezone.button.Size = UDim2.new(1001, 0, 1001, 0)
                        game:GetService("VirtualUser"):Button1Down(Vector2.new(1, 1))
                        game:GetService("VirtualUser"):Button1Up(Vector2.new(1, 1))
                    end)
                end

                if showLurePercentEnabled then
                    XyzClone.Text = "<font color='#ff4949'>Lure </font>: " .. tostring(math.floor(Character:FindFirstChild(RodName).values.lure.Value * 100) / 100) .. "%"
                end

            until not Character or not Character:FindFirstChild(RodName) or not Character:FindFirstChild(RodName).values.bite.Value or not autoFishEnabled

            XyzClone:Destroy()

            if autoReelEnabled then
                repeat
                    pcall(function()
                        task.wait()
                        game:GetService("ReplicatedStorage").events.reelfinished:FireServer(1000000000000000000000000, true)
                        task.wait()
                    end)
                until not Character or not Character:FindFirstChild(RodName) or not Character:FindFirstChild(RodName).values.bite.Value or not autoFishEnabled
            end
        else
            if autoCastEnabled and Character and Character:FindFirstChild(RodName) then
                pcall(function()
                    Character:FindFirstChild(RodName).events.cast:FireServer(1000000000000000000000000)
                end)
            end
        end

        task.wait()
    end
end

AutosGroupBox:AddToggle("AutoFishToggle", {
    Text = "Auto Fish",
    Default = false,
    Callback = function(Value)
        autoFishEnabled = Value
        if Value then
            autoFish()
        end
    end
})

AutosGroupBox:AddToggle("AutoCastToggle", {
    Text = "Auto Cast",
    Default = false,
    Callback = function(Value)
        autoCastEnabled = Value
    end
})

AutosGroupBox:AddToggle("AutoReelToggle", {
    Text = "Auto Reel",
    Default = false,
    Callback = function(Value)
        autoReelEnabled = Value
    end
})

AutosGroupBox:AddToggle("AutoShakeToggle", {
    Text = "Auto Shake",
    Default = false,
    Callback = function(Value)
        autoShakeEnabled = Value
    end
})

AutosGroupBox:AddToggle("ShowLurePercentToggle", {
    Text = "Show Lure Percent",
    Default = false,
    Callback = function(Value)
        showLurePercentEnabled = Value
    end
})

local walkSpeedEnabled = false
local walkSpeedValue = 16
local originalWalkSpeed

PlayerGroupBox:AddToggle("WalkSpeedToggle", {
    Text = "Enable WalkSpeed",
    Default = false,
    Callback = function(Value)
        walkSpeedEnabled = Value
        if walkSpeedEnabled then
            originalWalkSpeed = game:GetService("Players").LocalPlayer.Character.Humanoid.WalkSpeed
            game:GetService("Players").LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeedValue
        else
            game:GetService("Players").LocalPlayer.Character.Humanoid.WalkSpeed = originalWalkSpeed or 16
        end
    end
})

PlayerGroupBox:AddSlider("WalkSpeedSlider", {
    Text = "WalkSpeed",
    Default = 16,
    Min = 16,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        walkSpeedValue = Value
        if walkSpeedEnabled then
            game:GetService("Players").LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeedValue
        end
    end
})

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
ThemeManager:SetFolder('BearHubFisch')
SaveManager:SetFolder('BearHubFisch')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
MenuGroup:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", {
    Default = "End",
    NoUI = true,
    Text = "Menu Keybind"
})

Library.ToggleKeybind = Options.MenuKeybind

Library:OnUnload(function()
    stopLoop()
    if stunCheckConnection then
        stunCheckConnection:Disconnect()
    end
    print("UI unloaded!")
end)
