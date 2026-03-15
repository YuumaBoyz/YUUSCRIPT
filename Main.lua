-- [[ 💎 YUUSCRIPT V3.0 - FUSION FINALE ]] --

-- **1. CHARGEMENT DES DÉPENDANCES**
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
_G.QuestData = nil
_G.AutoAttackEnabled = false
_G.FastAttackSpeed = 0.05

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- **3. SECURISATION INTERFACE (Fix : image_1e54ff.jpg)**
local pGui = Player:WaitForChild("PlayerGui", 30)
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

-- **5. MOTEURS DE FOND (Stats, Sniper, ESP)**
-- Auto-Stats
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

-- Fruit Sniper & ESP
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

task.spawn(function()
    while task.wait(1) do
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:IsA("Tool") and (obj.Name:find("Fruit") or obj:FindFirstChild("Handle")) then
                if _G.InstantSniper then
                    local char = Player.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.CFrame = obj.Handle.CFrame
                        firetouchinterest(root, obj.Handle, 0)
                        firetouchinterest(root, obj.Handle, 1)
                    end
                end
                if _G.FruitESP then CreateESP(obj.Handle, obj.Name) end
            end
        end
    end
end)

-- **3. MODULE : FAST ATTACK & AUTO-CLICKER**
local FastAttack = {}

local function EquipWeapon()
    local selected = _G.SelectedWeapon or "Combat"
    local char = Player.Character
    if not char then return end
    if not char:FindFirstChild(selected) then
        local tool = Player.Backpack:FindFirstChild(selected)
        if tool then char.Humanoid:EquipTool(tool) end
    end
end

function FastAttack.Attack()
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    EquipWeapon()
    
    local weapon = char:FindFirstChildOfClass("Tool")
    if weapon then
        -- Injection Remote (Dégâts réels)
        Remote:InvokeServer("Attack")
        -- Click visuel (Hitbox & Stabilité)
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(0, 0))
    end
end

function FastAttack.Start()
    if _G.AutoAttackEnabled then return end
    _G.AutoAttackEnabled = true
    task.spawn(function()
        while _G.AutoAttackEnabled do
            if _G.AutoFarmEnabled then
                pcall(function() FastAttack.Attack() end)
                task.wait(_G.FastAttackSpeed)
            else
                task.wait(0.5)
            end
        end
    end)
end

-- **6. LOGIQUE D'AUTOFARM**
_G.QuestsData = {
    -- Starter Island (Lv. 0 - 10)
    {Level = 0, NPC = "Bandit Quest Giver", Name = "BanditQuest1", Mob = "Bandit", QuestID = 1, Pos = CFrame.new(1059, 16, 1549)},

    -- Jungle (Lv. 10 - 30)
    {Level = 10, NPC = "Adventurer", Name = "JungleQuest", Mob = "Monkey", QuestID = 1, Pos = CFrame.new(-1610, 37, 153)},
    {Level = 15, NPC = "Adventurer", Name = "JungleQuest", Mob = "Gorilla", QuestID = 2, Pos = CFrame.new(-1610, 37, 153)},
    {Level = 20, NPC = "Adventurer", Name = "JungleQuest", Mob = "King Gorilla", QuestID = 3, Pos = CFrame.new(-1610, 37, 153)}, -- BOSS

    -- Pirate Village (Lv. 30 - 60)
    {Level = 30, NPC = "Pirate Quest Giver", Name = "PirateVillageQuest", Mob = "Pirate", QuestID = 1, Pos = CFrame.new(-1140, 4, 3828)},
    {Level = 45, NPC = "Pirate Quest Giver", Name = "PirateVillageQuest", Mob = "Brute", QuestID = 2, Pos = CFrame.new(-1140, 4, 3828)},
    {Level = 55, NPC = "Pirate Quest Giver", Name = "PirateVillageQuest", Mob = "Bobby", QuestID = 3, Pos = CFrame.new(-1140, 4, 3828)}, -- BOSS

    -- Desert (Lv. 60 - 90)
    {Level = 60, NPC = "Desert Quest Giver", Name = "DesertQuest", Mob = "Desert Bandit", QuestID = 1, Pos = CFrame.new(894, 6, 4390)},
    {Level = 75, NPC = "Desert Quest Giver", Name = "DesertQuest", Mob = "Desert Officer", QuestID = 2, Pos = CFrame.new(894, 6, 4390)},

    -- Frozen Village (Lv. 90 - 120)
    {Level = 90, NPC = "Snow Quest Giver", Name = "SnowQuest", Mob = "Snow Bandit", QuestID = 1, Pos = CFrame.new(1385, 87, -1298)},
    {Level = 100, NPC = "Snow Quest Giver", Name = "SnowQuest", Mob = "Snowman", QuestID = 2, Pos = CFrame.new(1385, 87, -1298)},
    {Level = 105, NPC = "Snow Quest Giver", Name = "SnowQuest", Mob = "Yeti", QuestID = 3, Pos = CFrame.new(1385, 87, -1298)}, -- BOSS

    -- Marine Fortress (Lv. 120 - 150)
    {Level = 120, NPC = "Marine Quest Giver", Name = "MarineQuest", Mob = "Chief Petty Officer", QuestID = 1, Pos = CFrame.new(-4390, 73, 2988)},
    {Level = 130, NPC = "Marine Quest Giver", Name = "MarineQuest", Mob = "Muay Thai Marine", QuestID = 2, Pos = CFrame.new(-4390, 73, 2988)},
    {Level = 130, NPC = "Marine Quest Giver", Name = "MarineQuest", Mob = "Vice Admiral", QuestID = 3, Pos = CFrame.new(-4390, 73, 2988)}, -- BOSS

    -- Skylands (Lv. 150 - 190)
    {Level = 150, NPC = "Sky Quest Giver", Name = "SkyQuest", Mob = "Sky Bandit", QuestID = 1, Pos = CFrame.new(-4839, 717, -2612)},
    {Level = 175, NPC = "Sky Quest Giver", Name = "SkyQuest", Mob = "Dark Steward", QuestID = 2, Pos = CFrame.new(-4839, 717, -2612)},

    -- Prison (Lv. 190 - 250)
    {Level = 190, NPC = "Prisoner Quest Giver", Name = "PrisonQuest", Mob = "Prisoner", QuestID = 1, Pos = CFrame.new(5307, 1, 474)},
    {Level = 210, NPC = "Prisoner Quest Giver", Name = "PrisonQuest", Mob = "Dangerous Prisoner", QuestID = 2, Pos = CFrame.new(5307, 1, 474)},
    {Level = 230, NPC = "Prisoner Quest Giver", Name = "PrisonQuest", Mob = "Warden", QuestID = 3, Pos = CFrame.new(5307, 1, 474)}, -- BOSS
    {Level = 240, NPC = "Prisoner Quest Giver", Name = "PrisonQuest", Mob = "Chief Warden", QuestID = 4, Pos = CFrame.new(5307, 1, 474)}, -- BOSS
    {Level = 250, NPC = "Prisoner Quest Giver", Name = "PrisonQuest", Mob = "Swan", QuestID = 5, Pos = CFrame.new(5307, 1, 474)}, -- BOSS

    -- Magma Village (Lv. 300 - 375)
    {Level = 300, NPC = "Magma Quest Giver", Name = "MagmaQuest", Mob = "Military Soldier", QuestID = 1, Pos = CFrame.new(-5313, 12, 8515)},
    {Level = 325, NPC = "Magma Quest Giver", Name = "MagmaQuest", Mob = "Military Spy", QuestID = 2, Pos = CFrame.new(-5313, 12, 8515)},
    {Level = 350, NPC = "Magma Quest Giver", Name = "MagmaQuest", Mob = "Magma Admiral", QuestID = 3, Pos = CFrame.new(-5313, 12, 8515)}, -- BOSS

    -- Underwater City (Lv. 375 - 450)
    {Level = 375, NPC = "Fishman Quest Giver", Name = "FishmanQuest", Mob = "Fishman Warrior", QuestID = 1, Pos = CFrame.new(61122, 18, 1568)},
    {Level = 400, NPC = "Fishman Quest Giver", Name = "FishmanQuest", Mob = "Fishman Commando", QuestID = 2, Pos = CFrame.new(61122, 18, 1568)},
    {Level = 425, NPC = "Fishman Quest Giver", Name = "FishmanQuest", Mob = "Fishman Lord", QuestID = 3, Pos = CFrame.new(61122, 18, 1568)}, -- BOSS

    -- Upper Skylands (Lv. 450 - 525)
    {Level = 450, NPC = "Sky Quest Giver", Name = "SkyQuest2", Mob = "God's Guard", QuestID = 1, Pos = CFrame.new(-7903, 5545, -379)},
    {Level = 475, NPC = "Sky Quest Giver", Name = "SkyQuest2", Mob = "Shanda", QuestID = 2, Pos = CFrame.new(-7903, 5545, -379)},
    {Level = 500, NPC = "Sky Quest Giver", Name = "SkyQuest2", Mob = "Wysper", QuestID = 3, Pos = CFrame.new(-7903, 5545, -379)}, -- BOSS
    
    -- Upper Skylands 2 (Lv. 525 - 625)
    {Level = 525, NPC = "Sky Quest Giver", Name = "SkyQuest3", Mob = "Royal Squad", QuestID = 1, Pos = CFrame.new(-4720, 5670, -1430)},
    {Level = 550, NPC = "Sky Quest Giver", Name = "SkyQuest3", Mob = "Royal Soldier", QuestID = 2, Pos = CFrame.new(-4720, 5670, -1430)},
    {Level = 575, NPC = "Sky Quest Giver", Name = "SkyQuest3", Mob = "Thunder God", QuestID = 3, Pos = CFrame.new(-4720, 5670, -1430)}, -- BOSS (Enel)

    -- Fountain City (Lv. 625 - 700)
    {Level = 625, NPC = "Cyborg Quest Giver", Name = "FountainQuest", Mob = "Galley Pirate", QuestID = 1, Pos = CFrame.new(5259, 38, 4050)},
    {Level = 650, NPC = "Cyborg Quest Giver", Name = "FountainQuest", Mob = "Galley Captain", QuestID = 2, Pos = CFrame.new(5259, 38, 4050)},
    {Level = 675, NPC = "Cyborg Quest Giver", Name = "FountainQuest", Mob = "Cyborg", QuestID = 3, Pos = CFrame.new(5259, 38, 4050)}, -- BOSS
}

local function IsQuestActive()
    local mainGui = Player.PlayerGui:FindFirstChild("Main")
    if mainGui and mainGui:FindFirstChild("Quest") and mainGui.Quest.Visible then
        local container = mainGui.Quest:FindFirstChild("Container")
        if container then
            local title = container:FindFirstChildWhichIsA("TextLabel")
            return title and title.Text ~= ""
        end
    end
    return false
end

local function GetClosestMob(targetName)
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    local closest, dist = nil, math.huge
    for _, v in pairs(enemies:GetChildren()) do
        if v.Name == targetName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local root = v:FindFirstChild("HumanoidRootPart")
            if root then
                local d = (Player.Character.HumanoidRootPart.Position - root.Position).Magnitude
                if d < dist then dist = d; closest = v end
            end
        end
    end
    return closest
end

local function StartFarmLoop()
    task.spawn(function()
        -- On lance la boucle d'attaque en parallèle
        FastAttack.Start()
        
        while _G.AutoFarmEnabled do
            pcall(function()
                local char = Player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end

                local level = Player.Data.Level.Value
                local target = _G.QuestsData[1]
                for _, q in ipairs(_G.QuestsData) do
                    if level >= q.Level then target = q end
                end

                if not IsQuestActive() then
                    char.HumanoidRootPart.CFrame = target.Pos
                    task.wait(0.5)
                    Remote:InvokeServer("StartQuest", target.Name, target.QuestID)
                else
                    local mob = GetClosestMob(target.Mob)
                    if mob then
                        -- Farm au-dessus (Safe)
                        char.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0)
                    else
                        -- Retour zone de spawn
                        char.HumanoidRootPart.CFrame = target.Pos * CFrame.new(0, 60, 0)
                    end
                end
            end)
            task.wait(0.1)
        end
        _G.AutoAttackEnabled = false -- Stop l'attaque si farm stop
    end)
end

-- **7. CRÉATION DE L'INTERFACE (GUI)**
local Window = Fluent:CreateWindow({
    Title = "YUUSCRIPT V3.0", SubTitle = "Ultimate Edition (Fix)",
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

local Options = Fluent.Options

-- [[ TAB : AUTOFARM ]] --
Tabs.Main:AddDropdown("Weapon", {
    Title = "Arme à utiliser", Values = {"Combat", "Saber", "Pipe", "Katana", "Cutlass"},
    Default = "Combat", Callback = function(v) _G.SelectedWeapon = v end
})

Tabs.Main:AddToggle("FarmToggle", {Title = "Activer l'Autofarm", Default = false}):OnChanged(function()
    _G.AutoFarmEnabled = Options.FarmToggle.Value
    if _G.AutoFarmEnabled then StartFarmLoop() end
end)

Tabs.Main:AddSlider("AttackSpeed", {
    Title = "Vitesse d'Attaque",
    Description = "Plus bas = Plus rapide (Attention au kick)",
    Default = 0.05,
    Min = 0.01,
    Max = 0.5,
    Rounding = 2,
    Callback = function(Value)
        _G.FastAttackSpeed = Value
    end
})

-- [[ TAB : STATS ]] --
Tabs.Stats:AddDropdown("StatTarget", {
    Title = "Statistique à monter", Values = {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"},
    Default = "Melee", Callback = function(v) _G.StatsTarget = v end
})

Tabs.Stats:AddToggle("StatsToggle", {Title = "Auto-Stats", Default = false}):OnChanged(function()
    _G.AutoStats = Options.StatsToggle.Value
end)

-- [[ TAB : FRUITS ]] --
Tabs.Fruits:AddToggle("SniperToggle", {Title = "Fruit Sniper (Instant TP)", Default = false}):OnChanged(function()
    _G.InstantSniper = Options.SniperToggle.Value
end)

Tabs.Fruits:AddToggle("ESPToggle", {Title = "ESP Fruits", Default = false}):OnChanged(function()
    _G.FruitESP = Options.ESPToggle.Value
end)

-- [[ TAB : MISC ]] --
Tabs.Misc:AddButton({
    Title = "Server Hop", Description = "Change de serveur",
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

-- **8. INITIALISATION FINALE**
if _G.AntiAFK then
    Player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

SaveManager:LoadAutoloadConfig()
Window:SelectTab(1)
Fluent:Notify({Title = "YUUSCRIPT V3.0", Content = "🚀 Système intégral et sécurisé chargé !", Duration = 5})