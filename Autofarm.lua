--[[
    💎 YUUSCRIPT : ULTIMATE STATE-MACHINE AUTOFARM (V2.0)
    Expert : Expert Luau Developer
    Target : Blox Fruits (Standard Logic)
]]

local AutofarmPro = {}

-- [[ SERVICES ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

-- [[ VARIABLES LOCALES ]] --
local Player = Players.LocalPlayer
local Tween = _G.TweenModule
local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- [[ CONFIGURATION DES QUÊTES (AVEC QUEST ID INTÉGRÉ) ]] --
-- L'ajout de "QuestID" est VITAL pour synchroniser la quête acceptée avec le mob ciblé.
local QuestsData = {
    -- [[ STARTER ISLAND ]] --
    {Level = 0, NPC = "Bandit Quest Giver", Name = "BanditQuest1", Mob = "Bandit", QuestID = 1, Pos = CFrame.new(1059, 16, 1549)},
    
    -- [[ JUNGLE ]] --
    {Level = 10, NPC = "Adventurer", Name = "JungleQuest", Mob = "Monkey", QuestID = 1, Pos = CFrame.new(-1610, 37, 153)},
    {Level = 15, NPC = "Adventurer", Name = "JungleQuest", Mob = "Gorilla", QuestID = 2, Pos = CFrame.new(-1610, 37, 153)},
    
    -- [[ PIRATE VILLAGE ]] --
    {Level = 30, NPC = "Pirate Adventurer", Name = "BuggyQuest1", Mob = "Pirate", QuestID = 1, Pos = CFrame.new(-1141, 5, 3827)},
    {Level = 40, NPC = "Pirate Adventurer", Name = "BuggyQuest1", Mob = "Brute", QuestID = 2, Pos = CFrame.new(-1141, 5, 3827)},
    {Level = 55, NPC = "Pirate Adventurer", Name = "BuggyQuest1", Mob = "Bobby", QuestID = 3, Pos = CFrame.new(-1141, 5, 3827)},
    
    -- [[ DESERT ]] --
    {Level = 60, NPC = "Desert Adventurer", Name = "DesertQuest", Mob = "Desert Bandit", QuestID = 1, Pos = CFrame.new(896, 6, 4390)},
    {Level = 75, NPC = "Desert Adventurer", Name = "DesertQuest", Mob = "Desert Officer", QuestID = 2, Pos = CFrame.new(896, 6, 4390)},
    
    -- [[ FROZEN VILLAGE ]] --
    {Level = 90, NPC = "Snow Adventurer", Name = "SnowQuest", Mob = "Snow Bandit", QuestID = 1, Pos = CFrame.new(1385, 15, -1303)},
    {Level = 100, NPC = "Snow Adventurer", Name = "SnowQuest", Mob = "Snowman", QuestID = 2, Pos = CFrame.new(1385, 15, -1303)},
    {Level = 105, NPC = "Snow Adventurer", Name = "SnowQuest", Mob = "Yeti", QuestID = 3, Pos = CFrame.new(1385, 15, -1303)},
    
    -- [[ MARINE FORTRESS ]] --
    {Level = 120, NPC = "Marine Officer", Name = "MarineQuest2", Mob = "Chief Petty Officer", QuestID = 1, Pos = CFrame.new(-4942, 21, 4381)},
    {Level = 150, NPC = "Marine Officer", Name = "MarineQuest2", Mob = "Vice Admiral", QuestID = 2, Pos = CFrame.new(-4942, 21, 4381)},
    
    -- [[ SKY ISLANDS ]] --
    {Level = 150, NPC = "Sky Adventurer", Name = "SkyQuest", Mob = "Sky Bandit", QuestID = 1, Pos = CFrame.new(-4842, 718, -2620)},
    {Level = 175, NPC = "Sky Adventurer", Name = "SkyQuest", Mob = "Dark Master", QuestID = 2, Pos = CFrame.new(-4842, 718, -2620)},
}

-- [[ SYSTÈME DE LOGS ]] --
local function Log(emoji, msg)
    print(string.format("%s [YUUSCRIPT] : %s", emoji, msg))
end

-- [[ SÉCURITÉ : SURVIE ]] --
local function CheckHealth()
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and (hum.Health / hum.MaxHealth) < 0.25 then 
        return false -- Déclenche le repli
    end
    return true
end

-- [[ LECTURE DE L'INTERFACE : QUÊTE ACTIVE ]] --
local function GetActiveQuest()
    local pGui = Player:FindFirstChild("PlayerGui")
    if pGui and pGui:FindFirstChild("Main") and pGui.Main:FindFirstChild("Quest") then
        return pGui.Main.Quest.Visible
    end
    return false
end

-- [[ MOTEUR DE DÉCISION DU NIVEAU ]] --
function AutofarmPro.GetTargetData()
    local currentLevel = Player.Data.Level.Value
    local target = QuestsData[1]
    
    -- Parcourt les données. Dès qu'on a le niveau, on met à jour la cible.
    for _, data in ipairs(QuestsData) do
        if currentLevel >= data.Level then
            target = data
        end
    end
    return target
end

-- [[ AUTO-ÉQUIPEMENT (SANS DÉLAI) ]] --
local function EquipWeapon()
    local weaponName = _G.SelectedWeapon or "Melee" -- Sécurité par défaut
    local char = Player.Character
    if char and not char:FindFirstChild(weaponName) then
        local tool = Player.Backpack:FindFirstChild(weaponName)
        if tool then
            char.Humanoid:EquipTool(tool)
        end
    end
end

-- [[ 🎯 FILTRAGE CHIRURGICAL ET OPTIMISÉ ]] --
local function GetClosestMob(targetName, spawnPos)
    local closestMob = nil
    local shortestDistance = math.huge
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if not root then return nil end

    for _, mob in pairs(workspace.Enemies:GetChildren()) do
        -- 1. NOM STRICT : Pas d'approximation permise.
        if mob.Name == targetName then
            local hum = mob:FindFirstChild("Humanoid")
            local mobRoot = mob:FindFirstChild("HumanoidRootPart")
            
            -- 2. EN VIE ET PHYSIQUEMENT PRÉSENT
            if hum and mobRoot and hum.Health > 0 then
                
                -- 3. DISTANCE : On calcule par rapport au point de spawn de la quête, pas du joueur !
                -- Ça empêche de cibler un mob glitché à 10 000 studs de distance.
                local distance = (mobRoot.Position - spawnPos.Position).Magnitude
                
                -- Si le mob est dans la zone logique de la quête (< 1000 studs)
                if distance < 1000 and distance < shortestDistance then
                    shortestDistance = distance
                    closestMob = mob
                end
            end
        end
    end
    
    return closestMob
end

-- [[ BOUCLE PRINCIPALE DE L'AUTOFARM ]] --
function AutofarmPro.Start()
    _G.AutoFarmEnabled = true
    Log("🚀", "***Machine à États lancée !*** Système de ciblage strict activé.")

    task.spawn(function()
        while _G.AutoFarmEnabled do
            local success, err = pcall(function()
                local char = Player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local currentTarget = AutofarmPro.GetTargetData()

                -- ÉTAPE 1 : GESTION DE LA QUÊTE
                if not GetActiveQuest() then
                    -- On annule tout mouvement en cours
                    if Tween.Stop then Tween.Stop() end 
                    
                    -- Déplacement vers le PNJ
                    _G.TweenModule.MoveTo(currentTarget.Pos, _G.TweenSpeed).Completed:Wait()
                    
                    -- 🔧 LE CORRECTIF EST ICI : On utilise currentTarget.QuestID !
                    Remote:InvokeServer("StartQuest", currentTarget.Name, currentTarget.QuestID)
                    task.wait(0.5)

                -- ÉTAPE 2 : VÉRIFICATION SANTÉ
                elseif not CheckHealth() then
                    Log("🛡️", "***Repli Tactique.*** PV bas.")
                    root.CFrame = root.CFrame * CFrame.new(0, 150, 0) -- On monte dans le ciel
                    task.wait(2) -- On attend la régénération

                -- ÉTAPE 3 : COMBAT
                else
                    EquipWeapon()
                    
                    -- On cherche le mob PARFAIT autour de la zone de la quête
                    local targetMob = GetClosestMob(currentTarget.Mob, currentTarget.Pos)

                    if targetMob then
                        local mobRoot = targetMob:FindFirstChild("HumanoidRootPart")
                        
                        -- TP au-dessus et verrouillage de la vue vers le bas (CFrame.Angles)
                        -- Cela garantit que la hitbox de ton arme touche toujours.
                        root.CFrame = mobRoot.CFrame * CFrame.new(0, 25, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                        
                        -- Verrouillage de la position pour empêcher les ennemis de te pousser
                        root.Velocity = Vector3.new(0, 0, 0)

                        -- Spam Clic Brutal
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new(0, 0))
                    else
                        -- Si aucun monstre EXACT n'est trouvé, on attend au point de spawn.
                        -- Finis les dérives aléatoires sur la carte !
                        _G.TweenModule.MoveTo(currentTarget.Pos, _G.TweenSpeed)
                    end
                end
            end)

            if not success then
                warn("⚠️ Erreur Autofarm: " .. tostring(err))
                task.wait(1) -- Pause de sécurité en cas d'erreur moteur
            end
            
            -- Délai ultra-court pour maximiser les TPS (Ticks Per Second)
            task.wait() 
        end
    end)
end

function AutofarmPro.Stop()
    _G.AutoFarmEnabled = false
    -- Relâche le clic souris virtuellement pour éviter un bug de clic infini
    VirtualUser:Button1Up(Vector2.new(0,0)) 
    Log("🛑", "***Système arrêté avec succès.***")
end

return AutofarmPro