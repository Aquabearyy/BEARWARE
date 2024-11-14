if not game:IsLoaded() then
    game.Loaded:Wait()
end

local orionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local player = players.LocalPlayer

local window = orionLib:MakeWindow({
    IntroText = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
    IntroIcon = "rbxassetid://15315284749",
    Name = "SilentHub - " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. " | " .. identifyexecutor(),
    IntroToggleIcon = "rbxassetid://7734091286",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "sxlent404"
})

local itemTab = window:MakeTab({
    Name = "Items",
    Icon = "rbxassetid://6034767621"
})

local antiTab = window:MakeTab({
    Name = "Anti",
    Icon = "rbxassetid://13793170713"
})

itemTab:AddToggle({
    Name = "Item ESP",
    Default = false,
    Flag = "itemESP",
    Callback = function(v)
        for _, item in workspace.Items:GetChildren() do
            if not item:IsA("Tool") then continue end
            if not item:FindFirstChild("Highlight") and v then
                local highlight = Instance.new("Highlight")
                highlight.Parent = item
            elseif item:FindFirstChild("Highlight") and not v then
                item.Highlight:Destroy()
            end
        end
    end
})

local function getClosestItem()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local closestItem = nil
    local closestDistance = math.huge
    
    for _, item in pairs(workspace.Items:GetChildren()) do
        if item:IsA("Tool") then
            local distance = (item.Handle.Position - character.HumanoidRootPart.Position).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestItem = item
            end
        end
    end
    
    return closestItem
end

itemTab:AddToggle({
    Name = "Auto Get Closest Item",
    Default = false,
    Flag = "getClosest",
    Callback = function(Value)
        if Value then
            local item = getClosestItem()
            if not item then
                orionLib.Flags["getClosest"]:Set(false)
                return
            end
            
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            local distance = (item.Handle.Position - character.HumanoidRootPart.Position).Magnitude
            local tweenInfo = TweenInfo.new(distance/200, Enum.EasingStyle.Linear)
            
            local tween = tweenService:Create(character.HumanoidRootPart, tweenInfo, {
                CFrame = CFrame.new(item.Handle.Position)
            })
            
            tween:Play()
            tween.Completed:Connect(function()
                if character:FindFirstChild("Humanoid") then
                    character.Humanoid:EquipTool(item)
                    task.wait()
                    if orionLib.Flags["autoUseItems"].Value then
                        item:Activate()
                    end
                    character.Humanoid:UnequipTools()
                end
                orionLib.Flags["getClosest"]:Set(false)
            end)
        end
    end
})

itemTab:AddToggle({
    Name = "Auto Use Items",
    Default = false,
    Flag = "autoUseItems"
})

local acidSection = antiTab:AddSection({
    Name = "Acid Settings"
})

acidSection:AddToggle({
    Name = "Safe Acid",
    Default = false,
    Callback = function(v)
        for _, acid in workspace.Map.AcidAbnormality:GetChildren() do
            if acid.Name == "Acid" and acid:IsA("BasePart") and acid:FindFirstChildWhichIsA("TouchTransmitter") then
                acid.CanTouch = not v
            end
        end
    end
})

acidSection:AddToggle({
    Name = "Solid Acid",
    Default = false,
    Callback = function(v)
        for _, acid in workspace.Map.AcidAbnormality:GetChildren() do
            if acid.Name == "Acid" and acid:IsA("BasePart") and acid:FindFirstChildWhichIsA("TouchTransmitter") then
                acid.CanCollide = v
            end
        end
    end
})

local lavaSection = antiTab:AddSection({
    Name = "Lava Settings"
})

lavaSection:AddToggle({
    Name = "Safe Lava",
    Default = false,
    Callback = function(v)
        workspace.Map.DragonDepths:WaitForChild("Lava").CanTouch = not v
    end
})

lavaSection:AddToggle({
    Name = "Solid Lava",
    Default = false,
    Callback = function(v)
        workspace.Map.DragonDepths:WaitForChild("Lava").CanCollide = v
    end
})

local miscSection = antiTab:AddSection({
    Name = "Misc Settings"
})

miscSection:AddToggle({
    Name = "Anti Trip",
    Default = false,
    Callback = function(v)
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not v)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not v)
        end
    end
})

miscSection:AddToggle({
    Name = "Anti Sit",
    Default = false,
    Callback = function(v)
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, not v)
        end
    end
})

workspace.Items.ChildAdded:Connect(function(item)
    if not item:IsA("Tool") then return end
    if orionLib.Flags["itemESP"].Value then
        local highlight = Instance.new("Highlight")
        highlight.Parent = item
    end
end)

orionLib:Init()
