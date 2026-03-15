local Autofarm = {}
local Tween = _G.TweenModule 

-- [[ CONFIGURATION ]] --
local DISTANCE_ABOVE_MOB = 7 -- Hauteur de sécurité légèrement augmentée pour les Boss

-- [[ BASE DE DONNÉES SEA 1 (INCLUANT BOSS) ]] --
local QuestData = {
    {Level = 0,   Mob = "Bandit",             NPC = "Bandit Quest Giver", QuestName = "BanditQuest1", Pos = Vector3.new(1059, 16, 1547)},
    {Level = 10,  Mob = "Monkey",             NPC = "Monkey Quest Giver", QuestName = "MonkeyQuest1", Pos = Vector3.new(-1598, 37, 153)},
    {Level = 15,  Mob = "Gorilla",            NPC = "Monkey Quest Giver", QuestName = "GorillaQuest1", Pos = Vector3.new(-1598, 37, 153)},
    {Level = 30,  Mob = "Pirate",             NPC = "Pirate Island",      QuestName = "PirateIslandQuest1", Pos = Vector3.new(-1141, 4, 3832)},
    {Level = 60,  Mob = "Desert Bandit",      NPC = "Desert Adventurer",  QuestName = "DesertQuest1", Pos = Vector3.new(894, 6, 4390)},
    {Level = 90,  Mob = "Snow Bandit",        NPC = "Snow Adventurer",    QuestName = "SnowQuest1", Pos = Vector3.new(1389, 15, -1299)},
    -- BOSS : YETI
    {Level = 110, Mob = "Yeti",               NPC = "Snow Adventurer",    QuestName = "SnowQuest3", Pos = Vector3.new(1389, 15, -1299)},
    {Level = 120, Mob = "Chief Petty Officer",NPC = "Marine Officer",      QuestName = "MarineFordQuest1", Pos = Vector3.new(-4894, 20, 4265)},
    -- BOSS : VICE ADMIRAL
    {Level = 130, Mob = "Vice Admiral",       NPC = "Marine Officer",      QuestName = "MarineFordQuest2", Pos = Vector3.new(-4894, 20, 4265)},
    {Level = 150, Mob = "Sky Bandit",         NPC = "Sky Adventurer",     QuestName = "SkyQuest1", Pos = Vector3.new(-4840, 718, -2620)},
    -- BOSS : WARDEN
    {Level = 200, Mob = "Warden",             NPC = "Chief Warden",       QuestName = "PrisonQuest1", Pos = Vector3.new(4879, 6, 734)},
    -- BOSS : CHIEF WARDEN
    {Level = 230, Mob = "Chief Warden",       NPC = "Chief Warden",       QuestName = "PrisonQuest2", Pos = Vector3.new(4879, 6, 734)},
    {Level = 250, Mob = "Toga Warrior",       NPC = "Head Chef",          QuestName = "UnderwaterQuest1", Pos = Vector3.new(613, 31, 5953)},
    {Level = 300, Mob = "Military Soldier",   NPC = "Military Detective", QuestName = "MagmaQuest1", Pos = Vector3.new(-5314, 12, 8515)},
    {Level = 425, Mob = "Fishman Warrior",    NPC = "Fishman Warrior",    QuestName = "FishmanQuest1", Pos = Vector3.new(-3683, 7, -5282)},
    -- BOSS : ARLONG (SAWFISH)
    {Level = 475, Mob = "Sawfish",            NPC = "Fishman Warrior",    QuestName = "FishmanQuest3", Pos = Vector3.new(-3683, 7, -5282)},
    {Level = 525, Mob = "God's Guard",        NPC = "Mole",               QuestName = "SkyExp1Quest1", Pos = Vector3.new(-4545, 843, -5283)},
    {Level = 625, Mob = "Galley Pirate",      NPC = "Cyborg",             QuestName = "FountainQuest1", Pos = Vector3.new(5259, 38, 4050)},
    -- BOSS : CYBORG
    {Level = 675, Mob = "Cyborg",             NPC = "Cyborg",             QuestName = "FountainQuest3", Pos = Vector3.new(5259, 38, 4050)}
}

-- [[ LOGIQUE DE DÉTECTION DE NIVEAU ]] --
local function GetMyQuest()
    local level = game.Players.LocalPlayer.Data.Level.Value
    local best = QuestData[1]
    for _, q in ipairs(QuestData) do
        if level >= q.Level then best = q end
    end
    return best
end

-- [[ BOUCLE PRINCIPALE ]] --
function Autofarm.Start()
    _G.AutoFarmEnabled = true
    local player = game.Players.LocalPlayer
    
    task.spawn(function()
        while _G.AutoFarmEnabled do
            task.wait(0.1)
            
            -- Vérification du personnage
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then continue end
            local rootPart = character.HumanoidRootPart
            
            -- Vérification de l'interface de quête
            local playerGui = player:WaitForChild("PlayerGui")
            local mainGui = playerGui:FindFirstChild("Main")
            local hasQuest = mainGui and mainGui:FindFirstChild("Quest") and mainGui.Quest.Visible
            
            local current = GetMyQuest()

            if not hasQuest then
                -- ⚡ TP INSTANTANÉ AU NPC
                print("⚡ TP Instant au NPC : " .. current.NPC)
                rootPart.CFrame = CFrame.new(current.Pos)
                task.wait(0.3)
                
                -- Interaction Remote pour prendre la quête
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", current.QuestName, 1)
                task.wait(0.2)
            else
                -- ⚡ RECHERCHE DE LA CIBLE (MOB OU BOSS)
                local targetMob = nil
                
                -- On cherche dans Enemies et dans le Workspace (pour les Boss)
                local potentialTargets = {}
                if workspace:FindFirstChild("Enemies") then
                    for _, v in pairs(workspace.Enemies:GetChildren()) do table.insert(potentialTargets, v) end
                end
                for _, v in pairs(workspace:GetChildren()) do
                    if v.Name == current.Mob then table.insert(potentialTargets, v) end
                end

                for _, mob in pairs(potentialTargets) do
                    if mob.Name == current.Mob and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                        targetMob = mob
                        break
                    end
                end

                if targetMob then
                    print("⚔️ Cible verrouillée : " .. targetMob.Name)
                    -- TP initial direct sur l'ennemi
                    rootPart.CFrame = targetMob.HumanoidRootPart.CFrame * CFrame.new(0, DISTANCE_ABOVE_MOB, 0)
                    
                    -- Combat rapproché avec Tween pour suivre les mouvements
                    repeat
                        if not _G.AutoFarmEnabled then break end
                        if not targetMob:FindFirstChild("HumanoidRootPart") then break end
                        
                        -- Le Tween reste utile ici pour coller au mob sans saccades
                        Tween.MoveTo(targetMob.HumanoidRootPart.CFrame * CFrame.new(0, DISTANCE_ABOVE_MOB, 0), 500)
                        
                        -- Auto-clic de l'arme équipée
                        local tool = character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                        
                        task.wait(0.1)
                    until not targetMob or not targetMob:FindFirstChild("Humanoid") or targetMob.Humanoid.Health <= 0
                else
                    -- Attente au spawn point (en hauteur pour la sécurité)
                    rootPart.CFrame = CFrame.new(current.Pos) + Vector3.new(0, 60, 0)
                    task.wait(1)
                end
            end
        end
    end)
end

function Autofarm.Stop()
    _G.AutoFarmEnabled = false
    print("🛑 Autofarm désactivé.")
end

return Autofarm