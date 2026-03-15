local Autofarm = {}
local Tween = _G.TweenModule 

-- [[ CONFIGURATION ]] --
local DISTANCE_ABOVE_MOB = 7 
local USE_SKILLS = true

-- [[ BASE DE DONNÉES SEA 1 ]] --
local QuestData = {
    {Level = 0,   Mob = "Bandit",             NPC = "Bandit Quest Giver", QuestName = "BanditQuest1", Pos = Vector3.new(1059, 16, 1547)},
    {Level = 10,  Mob = "Monkey",             NPC = "Monkey Quest Giver", QuestName = "MonkeyQuest1", Pos = Vector3.new(-1598, 37, 153)},
    {Level = 15,  Mob = "Gorilla",            NPC = "Monkey Quest Giver", QuestName = "GorillaQuest1", Pos = Vector3.new(-1598, 37, 153)},
    {Level = 30,  Mob = "Pirate",             NPC = "Pirate Island",      QuestName = "PirateIslandQuest1", Pos = Vector3.new(-1141, 4, 3832)},
    {Level = 60,  Mob = "Desert Bandit",      NPC = "Desert Adventurer",  QuestName = "DesertQuest1", Pos = Vector3.new(894, 6, 4390)},
    {Level = 90,  Mob = "Snow Bandit",        NPC = "Snow Adventurer",    QuestName = "SnowQuest1", Pos = Vector3.new(1389, 15, -1299)},
    {Level = 110, Mob = "Yeti",               NPC = "Snow Adventurer",    QuestName = "SnowQuest3", Pos = Vector3.new(1389, 15, -1299)},
    {Level = 130, Mob = "Vice Admiral",       NPC = "Marine Officer",     QuestName = "MarineFordQuest2", Pos = Vector3.new(-4894, 20, 4265)},
    {Level = 150, Mob = "Sky Bandit",         NPC = "Sky Adventurer",     QuestName = "SkyQuest1", Pos = Vector3.new(-4840, 718, -2620)},
    {Level = 230, Mob = "Chief Warden",       NPC = "Chief Warden",       QuestName = "PrisonQuest2", Pos = Vector3.new(4879, 6, 734)},
    {Level = 475, Mob = "Sawfish",            NPC = "Fishman Warrior",    QuestName = "FishmanQuest3", Pos = Vector3.new(-3683, 7, -5282)},
    {Level = 675, Mob = "Cyborg",             NPC = "Cyborg",             QuestName = "FountainQuest3", Pos = Vector3.new(5259, 38, 4050)}
}

-- [[ FONCTION : NOCLIP (ÉVITE DE S'ENFONCER) ]] --
local function ApplyNoclip()
    if _G.AutoFarmEnabled then
        local character = game.Players.LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end

-- [[ FONCTION : ÉQUIPER L'ARME AUTOMATIQUEMENT ]] --
local function AutoEquip()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if character and not character:FindFirstChildOfClass("Tool") then
        local backpack = player.Backpack
        -- Priorité : Fruit ou Epée présente dans le Backpack
        local tool = backpack:FindFirstChild("Melee") or backpack:FindFirstChildOfClass("Tool")
        if tool then
            character.Humanoid:EquipTool(tool)
        end
    end
end

-- [[ FONCTION : SKILLS SPAM (Z,X,C,V) ]] --
local function UseSkills()
    if not USE_SKILLS then return end
    local VIM = game:GetService("VirtualInputManager")
    for _, key in ipairs({"Z", "X", "C", "V"}) do
        VIM:SendKeyEvent(true, Enum.KeyCode[key], false, game)
        task.wait(0.01) -- Délai ultra court pour spam
        VIM:SendKeyEvent(false, Enum.KeyCode[key], false, game)
    end
end

-- [[ LOGIQUE DE QUÊTE SELON LE NIVEAU ]] --
local function GetMyQuest()
    local level = game.Players.LocalPlayer.Data.Level.Value
    local best = QuestData[1]
    for _, q in ipairs(QuestData) do
        if level >= q.Level then best = q end
    end
    return best
end

function Autofarm.Start()
    _G.AutoFarmEnabled = true
    local player = game.Players.LocalPlayer
    
    -- 🛡️ BOUCLE NOCLIP PERMANENTE (Priorité haute)
    task.spawn(function()
        while _G.AutoFarmEnabled do
            ApplyNoclip()
            task.wait(0.1)
        end
    end)

    -- ⚔️ BOUCLE PRINCIPALE DE FARM
    task.spawn(function()
        while _G.AutoFarmEnabled do
            task.wait(0.05)
            local character = player.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then continue end
            local rootPart = character.HumanoidRootPart
            
            local hasQuest = player.PlayerGui.Main:FindFirstChild("Quest") and player.PlayerGui.Main.Quest.Visible
            local current = GetMyQuest()

            if not hasQuest then
                -- ⚡ TP INSTANT AU NPC (Gain de temps max)
                rootPart.CFrame = CFrame.new(current.Pos)
                task.wait(0.3)
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", current.QuestName, 1)
                task.wait(0.1)
            else
                -- 🔍 RECHERCHE DE CIBLE INTELLIGENTE
                local targetMob = nil
                local potentialTargets = {}
                
                -- Fusion des scans (Workspace + Dossier Enemies)
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
                    -- 🔧 PRÉPARATION COMBAT
                    AutoEquip()
                    
                    repeat
                        if not _G.AutoFarmEnabled then break end
                        if not targetMob:FindFirstChild("HumanoidRootPart") then break end
                        
                        -- 🏎️ UTILISATION DU TWEEN POUR COLLER AU MOB (Stabilité)
                        Tween.MoveTo(targetMob.HumanoidRootPart.CFrame * CFrame.new(0, DISTANCE_ABOVE_MOB, 0), 800)
                        
                        -- 💥 ATTAQUE NORMALE + SPAM SKILLS
                        local tool = character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                        UseSkills()
                        
                        task.wait(0.1)
                    until not targetMob or not targetMob:FindFirstChild("Humanoid") or targetMob.Humanoid.Health <= 0
                else
                    -- ☁️ ATTENTE SÉCURISÉE (Évite de tomber ou d'être frappé)
                    rootPart.CFrame = CFrame.new(current.Pos) + Vector3.new(0, 80, 0)
                    task.wait(0.5)
                end
            end
        end
    end)
end

function Autofarm.Stop()
    _G.AutoFarmEnabled = false
    print("🛑 Autofarm arrêté.")
end

return Autofarm