-- [[ 🛡️ YUUSCRIPT V3.0 - SYSTEME INTEGRAL COMPLET ]] --

-- **1. CHARGEMENT DES DÉPENDANCES ET MANAGERS**
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- **2. CONFIGURATION ET VARIABLES GLOBALES**
_G.AutoFarmEnabled = false
_G.InstantSniper = false
_G.SelectedWeapon = "Combat"
_G.AutoStats = false
_G.StatsTarget = "Melee"
_G.FruitESP = false
_G.AntiAFK = true

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- **3. SECURISATION INTERFACE (Fix : image_1e54ff.jpg)**
local pGui = Player:WaitForChild("PlayerGui", 20)
local mainGui = pGui:WaitForChild("Main", 20) 

-- **4. FONCTIONS TECHNIQUES (Fix : Text is not a valid member of Frame)**
local function IsQuestActive()
    if not mainGui then return false end
    local qFrame = mainGui:FindFirstChild("Quest")
    if qFrame and qFrame.Visible then
        local container = qFrame:FindFirstChild("Container")
        if container then
            local title = container:FindFirstChildWhichIsA("TextLabel")
            return title and title.Text ~= ""
        end
    end
    return false
end

-- **5. MOTEUR AUTO-STATS**
task.spawn(function()
    while task.wait(1) do
        if _G.AutoStats then
            pcall(function()
                local points = Player.Data.StatsPoints.Value
                if points > 0 then
                    Remote:InvokeServer("AddPoint", _G.StatsTarget, points)
                end
            end)
        end
    end
end)

-- **6. MOTEUR FRUIT SNIPER & ESP**
local function CreateESP(part, name)
    if part:FindFirstChild("YuuESP") then return end
    local bbg = Instance.new("BillboardGui", part)
    bbg.Name = "YuuESP"
    bbg.AlwaysOnTop = true
    bbg.Size = UDim2.new(0, 200, 0, 50)
    bbg.ExtentsOffset = Vector3.new(0, 3, 0)
    local lbl = Instance.new("TextLabel", bbg)
    lbl.Text = "🍎 " .. name
    lbl.TextColor3 = Color3.fromRGB(255, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.TextScaled = true
end

-- **7. LOGIQUE D'AUTOFARM**
_G.QuestsData = {
    {Level = 0, NPC = "Bandit Quest Giver", Name = "BanditQuest1", Mob = "Bandit", QuestID = 1, Pos = CFrame.new(1059, 16, 1549)},
    {Level = 10, NPC = "Adventurer", Name = "JungleQuest", Mob = "Monkey", QuestID = 1, Pos = CFrame.new(-1610, 37, 153)},
    {Level = 625, NPC = "Cyborg Quest Giver", Name = "FountainQuest", Mob = "Galley Pirate", QuestID = 1, Pos = CFrame.new(5259, 38, 4050)},
}

local function GetClosestMob(targetName)
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    local closest, dist = nil, math.huge
    for _, v in pairs(enemies:GetChildren()) do
        if v.Name == targetName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local r = v:FindFirstChild("HumanoidRootPart")
            if r then
                local d = (Player.Character.HumanoidRootPart.Position - r.Position).Magnitude
                if d < dist then dist = d; closest = v end
            end
        end
    end
    return closest
end

local function StartFarmLoop()
    task.spawn(function()
        while _G.AutoFarmEnabled do
            pcall(function()
                local char = Player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end

                local target = _G.QuestsData[1]
                for _, data in ipairs(_G.QuestsData) do
                    if Player.Data.Level.Value >= data.Level then target = data end
                end

                if not IsQuestActive() then
                    char.HumanoidRootPart.CFrame = target.Pos
                    Remote:InvokeServer("StartQuest", target.Name, target.QuestID)
                else
                    local mob = GetClosestMob(target.Mob)
                    if mob then
                        local tool = Player.Backpack:FindFirstChild(_G.SelectedWeapon) or char:FindFirstChild(_G.SelectedWeapon)
                        if tool then char.Humanoid:EquipTool(tool) end
                        char.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0)
                        VirtualUser:Button1Down(Vector2.new())
                    else
                        char.HumanoidRootPart.CFrame = target.Pos * CFrame.new(0, 60, 0)
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end

-- **8. CRÉATION DE L'INTERFACE (GUI)**
local Window = Fluent:CreateWindow({
    Title = "YUUSCRIPT V3.0", SubTitle = "Full Unlocked Edition",
    TabWidth = 160, Size = UDim2.fromOffset(580, 520), Acrylic = true, Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Autofarm", Icon = "swords" }),
    Stats = Window:AddTab({ Title = "Stats", Icon = "bar-chart" }),
    Fruits = Window:AddTab({ Title = "Fruits", Icon = "apple" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "plus-circle" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- [[ TAB : AUTOFARM ]] --
Tabs.Main:AddDropdown("Weapon", {
    Title = "Arme à utiliser", Values = {"Combat", "Saber", "Pipe", "Katana", "Cutlass"},
    Default = "Combat", Callback = function(v) _G.SelectedWeapon = v end
})

Tabs.Main:AddToggle("FarmToggle", {Title = "Activer l'Autofarm", Default = false}):OnChanged(function()
    _G.AutoFarmEnabled = Fluent.Options.FarmToggle.Value
    if _G.AutoFarmEnabled then StartFarmLoop() end
end)

-- [[ TAB : STATS ]] --
Tabs.Stats:AddDropdown("StatTarget", {
    Title = "Statistique à monter", Values = {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"},
    Default = "Melee", Callback = function(v) _G.StatsTarget = v end
})

Tabs.Stats:AddToggle("StatsToggle", {Title = "Auto-Stats (Points illimités)", Default = false}):OnChanged(function()
    _G.AutoStats = Fluent.Options.StatsToggle.Value
end)

-- [[ TAB : FRUITS ]] --
Tabs.Fruits:AddToggle("SniperToggle", {Title = "Fruit Sniper (Instant TP)", Default = false}):OnChanged(function()
    _G.InstantSniper = Fluent.Options.SniperToggle.Value
end)

Tabs.Fruits:AddToggle("ESPToggle", {Title = "ESP Fruits", Default = false}):OnChanged(function()
    _G.FruitESP = Fluent.Options.ESPToggle.Value
end)

-- [[ TAB : MISC ]] --
Tabs.Misc:AddButton({
    Title = "Server Hop", Description = "Change de serveur pour trouver des boss/fruits",
    Callback = function()
        local Servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, s in pairs(Servers.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id)
            end
        end
    end
})

Tabs.Misc:AddButton({
    Title = "Rejoindre Pirate/Marine",
    Callback = function() Remote:InvokeServer("SetTeam", "Pirates") end
})

-- [[ TAB : SETTINGS ]] --
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:SetLibrary(Fluent)
SaveManager:SetFolder("YuuScript/Configs")
SaveManager:BuildConfigSection(Tabs.Settings)

Tabs.Settings:AddButton({
    Title = "Fermer le Script", Callback = function()
        _G.AutoFarmEnabled = false
        _G.InstantSniper = false
        Fluent:Destroy()
    end
})

-- **9. INITIALISATION DES BOUCLES DE FOND**
task.spawn(function()
    while task.wait(1) do
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:IsA("Tool") and (obj.Name:find("Fruit") or obj:FindFirstChild("Handle")) then
                -- Sniper
                if _G.InstantSniper then
                    local char = Player.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.CFrame = obj.Handle.CFrame
                        firetouchinterest(root, obj.Handle, 0)
                        firetouchinterest(root, obj.Handle, 1)
                    end
                end
                -- ESP
                if _G.FruitESP then CreateESP(obj.Handle, obj.Name) end
            end
        end
    end
end)

if _G.AntiAFK then
    Player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

SaveManager:LoadAutoloadConfig()
Window:SelectTab(1)
Fluent:Notify({Title = "YUUSCRIPT V3.0", Content = "🚀 Interface intégrale chargée !", Duration = 5})