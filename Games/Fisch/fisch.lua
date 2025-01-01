local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Config = {}
local AllFuncs = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local PlayerGui = LocalPlayer.PlayerGui
local Backpack = LocalPlayer.Backpack
local Lighting = game:GetService("Lighting")

local Window = OrionLib:MakeWindow({
    Name = "Fishing Script",
    HidePremium = false,
    SaveConfig = false, 
    ConfigFolder = "FishingScript",
    IntroEnabled = false
})

local MainTab = Window:MakeTab({
    Name = "Main"
})

local VisualsTab = Window:MakeTab({
    Name = "Visuals"
})

local TeleportTab = Window:MakeTab({
    Name = "Teleports"
})

local PlayerTab = Window:MakeTab({
    Name = "Player"
})

AllFuncs['Farm Fish'] = function()
    local RodName = ReplicatedStorage.playerstats[LocalPlayer.Name].Stats.rod.Value
    while Config['Farm Fish'] and task.wait() do
        if Backpack:FindFirstChild(RodName) then
            LocalPlayer.Character.Humanoid:EquipTool(Backpack:FindFirstChild(RodName))
        end
        if LocalPlayer.Character:FindFirstChild(RodName) and LocalPlayer.Character:FindFirstChild(RodName):FindFirstChild("bobber") then
            local XyzClone = game:GetService("ReplicatedStorage").resources.items.items.GPS.GPS.gpsMain.xyz:Clone()
            XyzClone.Parent = game.Players.LocalPlayer.PlayerGui:WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("backpack")
            XyzClone.Name = "Lure"
            XyzClone.Text = "<font color='#ff4949'>Lure </font>: 0%"
            repeat
                pcall(function()
                    PlayerGui:FindFirstChild("shakeui").safezone:FindFirstChild("button").Size = UDim2.new(1001, 0, 1001, 0)
                    game:GetService("VirtualUser"):Button1Down(Vector2.new(1, 1))
                    game:GetService("VirtualUser"):Button1Up(Vector2.new(1, 1))
                end)
                XyzClone.Text = "<font color='#ff4949'>Lure </font>: "..tostring(math.floor(LocalPlayer.Character:FindFirstChild(RodName).values.lure.Value * 100) / 100).."%"
                RunService.Heartbeat:Wait()
            until not LocalPlayer.Character:FindFirstChild(RodName) or LocalPlayer.Character:FindFirstChild(RodName).values.bite.Value or not Config['Farm Fish']
            XyzClone.Text = "<font color='#ff4949'>FISHING!</font>"
            delay(1.5, function()
                XyzClone:Destroy()
            end)
            repeat
                ReplicatedStorage.events.reelfinished:FireServer(1000000000000000000000000, true)
                task.wait(.5)
            until not LocalPlayer.Character:FindFirstChild(RodName) or not LocalPlayer.Character:FindFirstChild(RodName).values.bite.Value or not Config['Farm Fish']
        else
            if Config['Anchor'] and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.Anchored = false
                task.wait(0.1)
            end
            
            LocalPlayer.Character:FindFirstChild(RodName).events.cast:FireServer(1000000000000000000000000)
            task.wait(2)
            
            if Config['Anchor'] and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.Anchored = true
            end
        end
    end
end

MainTab:AddToggle({
    Name = "Auto Farm Fish",
    Default = false,
    Flag = "AutoFarm",
    Save = true,
    Callback = function(Value)
        Config['Farm Fish'] = Value
        if Value then
            task.spawn(AllFuncs['Farm Fish'])
        end
    end
})

MainTab:AddToggle({
    Name = "Anchor Character",
    Default = false,
    Flag = "Anchor",
    Save = true,
    Callback = function(Value)
        Config['Anchor'] = Value
        if Value then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.Anchored = true
            end
        else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.Anchored = false
            end
        end
    end
})

PlayerTab:AddToggle({
    Name = "Infinite Oxygen",
    Default = false,
    Flag = "InfiniteOxygen", 
    Save = true,
    Callback = function(Value)
        LocalPlayer.Character.client.oxygen.Disabled = Value
    end    
})

PlayerTab:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 500,
    Default = 16,
    Increment = 1,
    Flag = "WalkSpeed",
    Save = true,
    Callback = function(Value)
        LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end
})

PlayerTab:AddToggle({
    Name = "Walk on Water",
    Default = false,
    Flag = "WalkOnWater",
    Save = true,
    Callback = function(Value)
        for i,v in pairs(workspace.zones.fishing:GetChildren()) do
            if v.Name == "Ocean" then
                v.CanCollide = Value
            end
        end
    end
})

PlayerTab:AddToggle({
    Name = "No Clip",
    Default = false,
    Flag = "NoClip",
    Save = true,
    Callback = function(Value)
        if Value then
            RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    end
})

PlayerTab:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end
})

local TeleportLocations = {
    ["Moosewood"] = Vector3.new(473.989990, 150.940002, 254.020004),
    ["Roslit Bay"] = Vector3.new(-1695.300049, 148.000000, 739.239990),
    ["Roslit Hamlet"] = Vector3.new(-1469.050049, 132.529999, 711.000000),
    ["Roslit Volcano"] = Vector3.new(-1962.729980, 166.080002, 284.820007),
    ["Mushgrove Swamp"] = Vector3.new(2442.810059, 130.899994, -686.159973),
    ["Terrapin Island"] = Vector3.new(-161.610001, 145.039993, 1939.359985),
    ["Snowcap Island"] = Vector3.new(2606.929932, 135.279999, 2397.350098),
    ["Sunstone Island"] = Vector3.new(-923.770020, 135.490005, -1126.890015),
    ["Forsaken Shores"] = Vector3.new(-2587.719971, 148.750000, 1643.510010),
    ["Forsaken Shores (XP)"] = Vector3.new(-2674.560059, 164.750000, 1760.209961),
    ["Statue Of Sovereignty"] = Vector3.new(45.060001, 132.380005, -1013.830017),
    ["Sovereginty Mines"] = Vector3.new(-27.950001, 136.490005, -1121.439941),
    ["Keepers Altar"] = Vector3.new(1296.560059, -805.289978, -298.609985),
    ["Vertigo"] = "Soon",
    ["The Depths"] = "Soon",
    ["Desolate Deep"] = "Soon",
    ["Desolate Pocket"] = "Soon",
    ["Brine Pool"] = "Soon",
    ["Ancient Isle"] = Vector3.new(6059.620117, 195.279999, 281.369995),
    ["Ancient Isle (Fish)"] = Vector3.new(5800.850098, 135.300003, 406.809998),
    ["Ancient Archives"] = "Soon",
    ["The Ocean"] = Vector3.new(1447.849976, 135.000000, -7649.649902),
    ["Deep Ocean"] = "Soon", 
    ["Earmark Island"] = "Soon",
    ["Haddock Rock"] = "Soon",
    ["The Arch"] = Vector3.new(1007.799988, 131.320007, -1238.900024),
    ["Birch Cay"] = "Soon",
    ["Harvesters Spike"] = "Soon",
    ["Northern Expedition"] = "Soon"
}

local locations = {}
for location, _ in pairs(TeleportLocations) do
    table.insert(locations, location)
end

TeleportTab:AddDropdown({
    Name = "Select Location",
    Default = "The Ocean",
    Options = locations,
    Callback = function(Value)
        Config['SelectedLocation'] = Value
    end    
})

TeleportTab:AddButton({
    Name = "Teleport",
    Callback = function()
        if Config['SelectedLocation'] and TeleportLocations[Config['SelectedLocation']] then
            if TeleportLocations[Config['SelectedLocation']] == "Soon" then
                OrionLib:MakeNotification({
                    Name = "Teleport Failed",
                    Content = "This location is coming soon!",
                    Image = "rbxassetid://4483345998",
                    Time = 5
                })
                return
            end
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(TeleportLocations[Config['SelectedLocation']])
        end
    end
})

VisualsTab:AddToggle({
    Name = "Remove Fog",
    Default = false,
    Flag = "RemoveFog",
    Save = true,
    Callback = function(Value)
        if Value then
            if game:GetService("Lighting"):FindFirstChild("Sky") then
                game:GetService("Lighting"):FindFirstChild("Sky").Parent = game:GetService("Lighting").bloom
            end
        else
            if game:GetService("Lighting").bloom:FindFirstChild("Sky") then
                game:GetService("Lighting").bloom:FindFirstChild("Sky").Parent = game:GetService("Lighting")
            end
        end
    end
})

VisualsTab:AddToggle({
    Name = "Full Bright",
    Default = false,
    Flag = "FullBright",
    Save = true,
    Callback = function(Value)
        if Value then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        else
            Lighting.Brightness = 1
            Lighting.ClockTime = game:GetService("Lighting").TimeOfDay
            Lighting.FogEnd = 10000
            Lighting.GlobalShadows = true
            Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        end
    end
})

OrionLib:Init()
