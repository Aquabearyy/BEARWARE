local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local httpService = game:GetService("HttpService")

local ThemeManager = {} do
    ThemeManager.Folder = "SilentHub"
    ThemeManager.Settings = {
        Theme = "Amethyst"
    }
    function ThemeManager:SetFolder(folder)
        self.Folder = folder
        if not isfolder(self.Folder) then
            makefolder(self.Folder)
        end
    end
    function ThemeManager:SetLibrary(library)
        self.Library = library
    end
    function ThemeManager:SaveSettings()
        writefile(self.Folder .. "/theme.json", httpService:JSONEncode(self.Settings))
    end
    function ThemeManager:LoadSettings()
        local path = self.Folder .. "/theme.json"
        if isfile(path) then
            local data = readfile(path)
            local success, decoded = pcall(httpService.JSONDecode, httpService, data)
            if success then
                self.Settings.Theme = decoded.Theme
            end
        end
    end
end

Config = {}
local AllFuncs = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local PlayerGui = LocalPlayer.PlayerGui
local Backpack = LocalPlayer.Backpack

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
            LocalPlayer.Character:FindFirstChild(RodName).events.cast:FireServer(1000000000000000000000000)
            task.wait(2)
        end
    end
end

local Window = Fluent:CreateWindow({
    Title = "Silent Hub",
    SubTitle = "Private Script",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = ThemeManager.Settings.Theme,
    MinimizeKey = Enum.KeyCode.LeftControl
})

ThemeManager:SetLibrary(Fluent)
ThemeManager:SetFolder("SilentHub")
ThemeManager:LoadSettings()

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" })
}

local Farming = Tabs.Main:AddSection("Farming")

Farming:AddToggle("AutoFarm", {
    Title = "Auto Farm Fish",
    Default = false,
    Callback = function(Value)
        Config['Farm Fish'] = Value
        if Value then
            task.spawn(AllFuncs['Farm Fish'])
        end
    end
})

local ThemeDropdown = Tabs.Main:AddDropdown("Theme", {
    Title = "Theme",
    Description = "Changes the interface theme",
    Values = Fluent.Themes,
    Default = table.find(Fluent.Themes, ThemeManager.Settings.Theme) or 1,
    Callback = function(Value)
        Fluent:SetTheme(Value)
        ThemeManager.Settings.Theme = Value
        ThemeManager:SaveSettings()
    end
})

Window:SelectTab(1)

Fluent:Notify({
    Title = "Silent Hub",
    Content = "The script has been loaded.",
    Duration = 8
})
