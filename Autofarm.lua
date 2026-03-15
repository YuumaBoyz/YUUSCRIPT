-- [[ 🛡️ ÉTAPE 1 : SERVICES ET VARIABLES DE BASE ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer
local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- **AMÉLIORATION : Intégration de ta base de données de monstres et quêtes 🗺️**
_G.QuestsData = {
    {Level = 0, NPC = "Bandit Quest Giver", Name = "BanditQuest1", Mob = "Bandit", QuestID = 1, Pos = CFrame.new(1059, 16, 1549)},
    {Level = 10, NPC = "Adventurer", Name = "JungleQuest", Mob = "Monkey", QuestID = 1, Pos = CFrame.new(-1610, 37, 153)},
    {Level = 15, NPC = "Adventurer", Name = "JungleQuest", Mob = "Gorilla", QuestID = 2, Pos = CFrame.new(-1610, 37, 153)},
    {Level = 30, NPC = "Quest Giver", Name = "PirateVillageQuest", Mob = "Pirate", QuestID = 1, Pos = CFrame.new(-1922, 5, 3918)},
    {Level = 45, NPC = "Quest Giver", Name = "PirateVillageQuest", Mob = "Brute", QuestID = 2, Pos = CFrame.new(-1922, 5, 3918)},
    {Level = 60, NPC = "Desert Adventurer", Name = "DesertQuest", Mob = "Desert Bandit", QuestID = 1, Pos = CFrame.new(896, 6, 4390)},
    {Level = 75, NPC = "Desert Adventurer", Name = "DesertQuest", Mob = "Desert Officer", QuestID = 2, Pos = CFrame.new(896, 6, 4390)},
    {Level = 90, NPC = "Snow Adventurer", Name = "SnowQuest", Mob = "Snow Bandit", QuestID = 1, Pos = CFrame.new(1385, 15, -1303)},
    {Level = 100, NPC = "Snow Adventurer", Name = "SnowQuest", Mob = "Snowman", QuestID = 2, Pos = CFrame.new(1385, 15, -1303)},
    {Level = 105, NPC = "Snow Adventurer", Name = "SnowQuest", Mob = "Yeti", QuestID = 3, Pos = CFrame.new(1385, 15, -1303)},
    {Level = 120, NPC = "Marine Quest Giver", Name = "MarineQuest1", Mob = "Chief Petty Officer", QuestID = 1, Pos = CFrame.new(-4840, 22, 4350)},
    {Level = 150, NPC = "Marine Quest Giver", Name = "MarineQuest1", Mob = "Warden", QuestID = 2, Pos = CFrame.new(-4840, 22, 4350)},
    {Level = 190, NPC = "Marine Quest Giver", Name = "MarineQuest1", Mob = "Chief Warden", QuestID = 3, Pos = CFrame.new(-4840, 22, 4350)},
    {Level = 210, NPC = "Marine Quest Giver", Name = "MarineQuest1", Mob = "Swan", QuestID = 4, Pos = CFrame.new(-4840, 22, 4350)},
    {Level = 225, NPC = "Sky Adventurer", Name = "SkyQuest", Mob = "Sky Bandit", QuestID = 1, Pos = CFrame.new(-1240, 357, -5912)},
    {Level = 300, NPC = "Magma Adventurer", Name = "MagmaQuest", Mob = "Military Soldier", QuestID = 1, Pos = CFrame.new(-5315, 12, 8517)},
    {Level = 375, NPC = "Fishman Adventurer", Name = "FishmanQuest", Mob = "Fishman Warrior", QuestID = 1, Pos = CFrame.new(61122, 18, 1568)},
    {Level = 625, NPC = "Cyborg Quest Giver", Name = "FountainQuest", Mob = "Galley Pirate", QuestID = 1, Pos = CFrame.new(5259, 38, 4050)},
}

_G.SelectedWeapon = "Combat"

-- [[ ⏳ ÉTAPE 2 : CHARGEMENT SÉCURISÉ DE L'INTERFACE ]] --
local pGui = Player:WaitForChild("PlayerGui", 10)
if not pGui then warn("⚠️ [ERREUR FATALE] : PlayerGui introuvable.") return end

local mainGui = pGui:WaitForChild("Main", 10)
if not mainGui then warn("⚠️ [ERREUR FATALE] : Interface 'Main' introuvable.") return end

-- [[ 📦 ÉTAPE 3 : INITIALISATION DE LA TABLE DU MOTEUR ]] --
local AutofarmPro = {}
_G.AutofarmPro = AutofarmPro
_G.AutoFarmEnabled = false

-- [[ 🔍 ÉTAPE 4 : DÉTECTION BLINDÉE ET UTILITAIRES ]] --
local function GetActiveQuest()
    local hasQuest = false
    local success, err = pcall(function()
        local questFrame = mainGui:FindFirstChild("Quest")
        if questFrame and questFrame.Visible then
            local container = questFrame:FindFirstChild("Container")
            if container then
                local titleObj = container:FindFirstChildWhichIsA("TextLabel")
                if titleObj and titleObj.Text ~= "" then
                    hasQuest = true
                end
            end
        end
    end)
    return hasQuest
end

local function GetClosestMob(targetName)
    local closest, dist = nil, math.huge
    for _, v in pairs(workspace.Enemies:GetChildren()) do
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

local function EquipWeapon()
    local tool = Player.Backpack:FindFirstChild(_G.SelectedWeapon)
    if tool then Player.Character.Humanoid:EquipTool(tool) end
end

-- [[ ⚔️ ÉTAPE 5 : MOTEUR PRINCIPAL D'AUTOFARM ]] --
function AutofarmPro.Start()
    task.spawn(function()
        while _G.AutoFarmEnabled do
            local success, err = pcall(function()
                local char = Player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                -- **Recherche de la bonne quête selon ton niveau 📊**
                local lvl = Player.Data.Level.Value
                local targetData = _G.QuestsData[1]
                for _, data in ipairs(_G.QuestsData) do
                    if lvl >= data.Level then targetData = data end
                end

                local isQuestActive = GetActiveQuest()
                
                if not isQuestActive then
                    -- **Aller chercher la quête 🏃‍♂️**
                    root.CFrame = targetData.Pos
                    task.wait(0.5)
                    Remote:InvokeServer("StartQuest", targetData.Name, targetData.QuestID)
                else
                    -- **Aller tuer le monstre 🗡️**
                    local mob = GetClosestMob(targetData.Mob)
                    if mob and mob:FindFirstChild("HumanoidRootPart") then
                        EquipWeapon()
                        -- Position au-dessus du monstre pour taper sans prendre de coups
                        root.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new())
                    else
                        -- S'il n'y a pas de monstre, on attend en l'air au point de spawn ☁️
                        root.CFrame = targetData.Pos * CFrame.new(0, 40, 0)
                    end
                end
            end)
            
            if not success then
                warn("⚠️ [ERREUR MOTEUR] : " .. tostring(err))
            end
            
            -- Petite pause pour éviter de faire planter ton PC 🖥️
            task.wait(0.1)
        end
    end)
end

-- [[ 🖥️ ÉTAPE 6 : CRÉATION DE L'INTERFACE UTILISATEUR ]] --
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({ Title = "YUUSCRIPT V3.0", TabWidth = 160, Size = UDim2.fromOffset(580, 520), Theme = "Dark" })
local Tabs = { Main = Window:AddTab({ Title = "Autofarm", Icon = "swords" }) }

-- Menu déroulant pour choisir l'arme 🪓
Tabs.Main:AddDropdown("WeaponDropdown", {
    Title = "Arme", Values = {"Combat", "Saber", "Pipe", "Katana", "Cutlass"},
    Default = "Combat", Callback = function(v) _G.SelectedWeapon = v end
})

-- Bouton d'activation principal 🔘
Tabs.Main:AddToggle("AutoFarm", {Title = "Activer l'Autofarm", Default = false }):OnChanged(function()
    _G.AutoFarmEnabled = Fluent.Options.AutoFarm.Value
    
    if _G.AutoFarmEnabled then
        if AutofarmPro.Start then
            AutofarmPro.Start()
        else
            warn("⚠️ [ERREUR FATALE] La fonction Start n'a pas été trouvée !")
        end
    end
end)

-- [[ ✅ ÉTAPE 7 : RETOUR DU MODULE ]] --
return AutofarmPro