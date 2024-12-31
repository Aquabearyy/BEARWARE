local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local httpService = game:GetService("HttpService")
local Config = {}
local AllFuncs = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local PlayerGui = LocalPlayer.PlayerGui
local Backpack = LocalPlayer.Backpack

local TeleportLocations = {
   ["Sunstone Island"] = CFrame.new(-913.630615234375, 137.29348754882812, -1129.8995361328125),
   ["Roslit Bay"] = CFrame.new(-1501.675537109375, 133, 416.2070007324219),
   ["Random Islands"] = CFrame.new(237.6944580078125, 139.34976196289062, 43.103424072265625),
   ["Moosewood"] = CFrame.new(433.7972106933594, 147.07003784179688, 261.80218505859375),
   ["Executive Headquarters"] = CFrame.new(-36.46199035644531, -246.55001831054688, 205.77120971679688),
   ["Enchant Room"] = CFrame.new(1310.048095703125, -805.292236328125, -162.34507751464844),
   ["Statue Of Sovereignty"] = CFrame.new(22.098665237426758, 159.01470947265625, -1039.8543701171875),
   ["Mushgrove Swamp"] = CFrame.new(2442.805908203125, 130.904052734375, -686.1648559570312),
   ["Snowcap Island"] = CFrame.new(2589.534912109375, 134.9249267578125, 2333.099365234375),
   ["Terrapin Island"] = CFrame.new(152.3716278076172, 154.91015625, 2000.9171142578125),
   ["Best Spot"] = CFrame.new(1447.8507080078125, 133.49998474121094, -7649.64501953125)
}

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

AllFuncs['Anchor'] = function()
   local function setAnchor(value)
       if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
           LocalPlayer.Character.HumanoidRootPart.Anchored = value
       end
   end
   setAnchor(true)
   LocalPlayer.CharacterAdded:Connect(function()
       if Config['Anchor'] then
           task.wait()
           setAnchor(true)
       end
   end)
end

local Window = OrionLib:MakeWindow({
   Name = "Bear Hub",
   HidePremium = false,
   SaveConfig = false, 
   ConfigFolder = "BearHub",
   IntroEnabled = false
})

local MainTab = Window:MakeTab({
   Name = "Main",
   PremiumOnly = false
})

local TeleportSection = MainTab:AddSection({
   Name = "Teleports"
})

TeleportSection:AddDropdown({
   Name = "Select Location",
   Default = "Best Spot",
   Options = (function()
       local locations = {}
       for location, _ in pairs(TeleportLocations) do
           table.insert(locations, location)
       end
       return locations
   end)(),
   Callback = function(Value)
       Config['SelectedLocation'] = Value
   end    
})

TeleportSection:AddButton({
   Name = "Teleport",
   Callback = function()
       if Config['SelectedLocation'] and TeleportLocations[Config['SelectedLocation']] then
           if Config['SelectedLocation'] == "Best Spot" then
               local forceFieldPart = Instance.new("Part")
               forceFieldPart.Size = Vector3.new(10, 1, 10)
               forceFieldPart.Position = Vector3.new(1447.8507080078125, 131.49998474121094, -7649.64501953125)
               forceFieldPart.Anchored = true
               forceFieldPart.BrickColor = BrickColor.new("White")
               forceFieldPart.Material = Enum.Material.SmoothPlastic
               forceFieldPart.Parent = game.Workspace
               
               local forceField = Instance.new("ForceField")
               forceField.Parent = forceFieldPart
           end
           LocalPlayer.Character.HumanoidRootPart.CFrame = TeleportLocations[Config['SelectedLocation']]
       end
   end
})

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
           task.spawn(AllFuncs['Anchor'])
       else
           if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
               LocalPlayer.Character.HumanoidRootPart.Anchored = false
           end
       end
   end
})

OrionLib:Init()
