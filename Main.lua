local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- [[ 1. CONFIGURATION INITIALE ]] --
_G.TweenSpeed = 300
_G.AutoFarmEnabled = false
_G.SniperEnabled = false
_G.FruitESP = false
_G.AntiAFK = true
_G.BypassGates = true
_G.SafeMode = false
_G.SelectedWeapon = "Combat"

local Player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- [[ 2. MOTEUR D'AUTOFARM ]] --
local AutofarmPro = {}
local QuestsData = {
    -- Start Island
    {Level = 0, NPC = "Bandit Quest Giver", Name = "BanditQuest1", Mob = "Bandit", QuestID = 1, Pos = CFrame.new(1059, 16, 1549)},
    
    -- Jungle
    {Level = 10, NPC = "Adventurer", Name = "JungleQuest", Mob = "Monkey", QuestID = 1, Pos = CFrame.new(-1610, 37, 153)},
    {Level = 15, NPC = "Adventurer", Name = "JungleQuest", Mob = "Gorilla", QuestID = 2, Pos = CFrame.new(-1610, 37, 153)},
    
    -- Pirate Village
    {Level = 30, NPC = "Quest Giver", Name = "PirateVillageQuest", Mob = "Pirate", QuestID = 1, Pos = CFrame.new(-1922, 5, 3918)},
    {Level = 45, NPC = "Quest Giver", Name = "PirateVillageQuest", Mob = "Brute", QuestID = 2, Pos = CFrame.new(-1922, 5, 3918)},
    
    -- Desert
    {Level = 60, NPC = "Desert Adventurer", Name = "DesertQuest", Mob = "Desert Bandit", QuestID = 1, Pos = CFrame.new(896, 6, 4390)},
    {Level = 75, NPC = "Desert Adventurer", Name = "DesertQuest", Mob = "Desert Officer", QuestID = 2, Pos = CFrame.new(896, 6, 4390)},
    
    -- Frozen Village
    {Level = 90, NPC = "Snow Adventurer", Name = "SnowQuest", Mob = "Snow Bandit", QuestID = 1, Pos = CFrame.new(1385, 15, -1303)},
    {Level = 100, NPC = "Snow Adventurer", Name = "SnowQuest", Mob = "Snowman", QuestID = 2, Pos = CFrame.new(1385, 15, -1303)},
    {Level = 105, NPC = "Snow Adventurer", Name = "SnowQuest", Mob = "Yeti", QuestID = 3, Pos = CFrame.new(1385, 15, -1303)},
    
    -- Marine Fortress
    {Level = 120, NPC = "Marine Quest Giver", Name = "MarineQuest1", Mob = "Chief Petty Officer", QuestID = 1, Pos = CFrame.new(-4840, 22, 4350)},
    {Level = 150, NPC = "Marine Quest Giver", Name = "MarineQuest1", Mob = "Warden", QuestID = 2, Pos = CFrame.new(-4840, 22, 4350)},
    {Level = 190, NPC = "Marine Quest Giver", Name = "MarineQuest1", Mob = "Chief Warden", QuestID = 3, Pos = CFrame.new(-4840, 22, 4350)},
    {Level = 210, NPC = "Marine Quest Giver", Name = "MarineQuest1", Mob = "Swan", QuestID = 4, Pos = CFrame.new(-4840, 22, 4350)},
    
    -- Skylands (Lower)
    {Level = 225, NPC = "Sky Adventurer", Name = "SkyQuest", Mob = "Sky Bandit", QuestID = 1, Pos = CFrame.new(-1240, 357, -5912)},
    {Level = 250, NPC = "Sky Adventurer", Name = "SkyQuest", Mob = "Dark Steward", QuestID = 2, Pos = CFrame.new(-1240, 357, -5912)},
    
    -- Prison (Swan is handled in Marine Fortress usually, but if staying here:)
    {Level = 190, NPC = "Marine Quest Giver", Name = "MarineQuest1", Mob = "Chief Warden", QuestID = 3, Pos = CFrame.new(-4840, 22, 4350)},
    
    -- Magma Village
    {Level = 300, NPC = "Magma Adventurer", Name = "MagmaQuest", Mob = "Military Soldier", QuestID = 1, Pos = CFrame.new(-5315, 12, 8517)},
    {Level = 330, NPC = "Magma Adventurer", Name = "MagmaQuest", Mob = "Military Spy", QuestID = 2, Pos = CFrame.new(-5315, 12, 8517)},
    
    -- Underwater City
    {Level = 375, NPC = "Fishman Adventurer", Name = "FishmanQuest", Mob = "Fishman Warrior", QuestID = 1, Pos = CFrame.new(61122, 18, 1568)},
    {Level = 400, NPC = "Fishman Adventurer", Name = "FishmanQuest", Mob = "Fishman Commando", QuestID = 2, Pos = CFrame.new(61122, 18, 1568)},
    
    -- Skylands (Upper)
    {Level = 450, NPC = "Sky Quest Giver", Name = "SkyQuest2", Mob = "God's Guard", QuestID = 1, Pos = CFrame.new(-4721, 845, -9012)},
    {Level = 475, NPC = "Sky Quest Giver", Name = "SkyQuest2", Mob = "Shanda", QuestID = 2, Pos = CFrame.new(-4721, 845, -9012)},
    {Level = 525, NPC = "Sky Quest Giver", Name = "SkyQuest2", Mob = "Royal Squad", QuestID = 3, Pos = CFrame.new(-4721, 845, -9012)},
    {Level = 550, NPC = "Sky Quest Giver", Name = "SkyQuest2", Mob = "Royal Soldier", QuestID = 4, Pos = CFrame.new(-4721, 845, -9012)},
    
    -- Fountain City
    {Level = 625, NPC = "Cyborg Quest Giver", Name = "FountainQuest", Mob = "Galley Pirate", QuestID = 1, Pos = CFrame.new(5259, 38, 4050)},
    {Level = 650, NPC = "Cyborg Quest Giver", Name = "FountainQuest", Mob = "Galley Captain", QuestID = 2, Pos = CFrame.new(5259, 38, 4050)},
}

function AutofarmPro.GetTargetData()
    local lvl = Player.Data.Level.Value
    local target = QuestsData[1]
    for _, data in ipairs(QuestsData) do
        if lvl >= data.Level then target = data end
    end
    return target
end

function AutofarmPro.Start()
    _G.AutoFarmEnabled = true
    task.spawn(function()
        while _G.AutoFarmEnabled do
            pcall(function()
                local target = AutofarmPro.GetTargetData()
                -- Ta logique de combat et tween ici
                print("***Farming: " .. target.Mob .. "*** ⚔️")
            end)
            task.wait(1)
        end
    end)
end

_G.AutofarmPro = AutofarmPro -- Enregistrement global immédiat

-- [[ 3. FONCTIONS UTILITAIRES ]] --
local function ServerHop()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local PlaceId = game.PlaceId
    local Servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    for _, s in pairs(Servers.data) do
        if s.playing < s.maxPlayers and s.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(PlaceId, s.id)
            break
        end
    end
end

if _G.AntiAFK then
    local VirtualUser = game:GetService("VirtualUser")
    Player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

-- [[ 4. INTERFACE GRAPHIQUE (FLUENT) ]] --
local Window = Fluent:CreateWindow({
    Title = "YUUSCRIPT",
    SubTitle = "By YUUMA - Fix Edition",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 520),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Autofarm", Icon = "swords" }),
    Items = Window:AddTab({ Title = "Items & Fruits", Icon = "apple" }),
    Visuals = Window:AddTab({ Title = "Visuels", Icon = "eye" }),
    Misc = Window:AddTab({ Title = "Serveur & Misc", Icon = "shield" }),
    Settings = Window:AddTab({ Title = "Paramètres", Icon = "settings" })
}

local Options = Fluent.Options

-- SECTION MAIN
Tabs.Main:AddParagraph({Title = "Gestion du Farm Sea 1", Content = "Le farm utilise désormais le système de Bypass Gates."})

Tabs.Main:AddDropdown("WeaponDropdown", {
    Title = "Arme à utiliser",
    Values = {"Combat", "Saber", "Pipe", "Katana", "Cutlass", "Dual Katana", "Iron Mace"},
    Default = "Combat",
    Callback = function(Value) _G.SelectedWeapon = Value end
})

local FarmToggle = Tabs.Main:AddToggle("AutoFarm", {Title = "Activer l'Autofarm", Default = false })
FarmToggle:OnChanged(function()
    _G.AutoFarmEnabled = Options.AutoFarm.Value
    if _G.AutoFarmEnabled then
        if _G.AutofarmPro and _G.AutofarmPro.Start then
            _G.AutofarmPro.Start()
        else
            warn("***Erreur : AutofarmPro non prêt !***")
        end
    end
end)

Tabs.Main:AddSlider("TweenSpeed", {
    Title = "Vitesse de Vol",
    Default = 300, Min = 50, Max = 800, Rounding = 1,
    Callback = function(Value) _G.TweenSpeed = Value end
})

-- SECTION PHYSIQUE
Tabs.Main:AddToggle("BypassGates", {Title = "Bypass Gates", Default = true}):OnChanged(function(v) _G.BypassGates = v end)

-- SECTION MISC & VISUALS
Tabs.Visuals:AddToggle