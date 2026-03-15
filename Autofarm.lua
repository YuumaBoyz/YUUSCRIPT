-- [[ 🛡️ ÉTAPE 1 : SERVICES ET VARIABLES DE BASE ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer
local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- [[ ⏳ ÉTAPE 2 : CHARGEMENT SÉCURISÉ DE L'INTERFACE (Correction 3 & 4) ]] --
-- **CORRECTION : On sécurise l'accès à PlayerGui et Main avec des Timeouts de 10s.**
-- **AMÉLIORATION : On stocke mainGui en variable locale pour éviter les recherches répétitives (gain de perf).**
local pGui = Player:WaitForChild("PlayerGui", 10)
if not pGui then
    warn("⚠️ [ERREUR FATALE] : PlayerGui introuvable après 10 secondes. Arrêt propre du script.")
    return -- Arrête le script sans crash
end

local mainGui = pGui:WaitForChild("Main", 10)
if not mainGui then
    warn("⚠️ [ERREUR FATALE] : Interface 'Main' introuvable après 10 secondes. Arrêt propre du script.")
    return -- Arrête le script sans crash
end

-- [[ 📦 ÉTAPE 3 : INITIALISATION DE LA TABLE DU MOTEUR ]] --
local AutofarmPro = {}
_G.AutofarmPro = AutofarmPro
_G.AutoFarmEnabled = false

-- [[ 🔍 ÉTAPE 4 : DÉTECTION DE QUÊTE BLINDÉE (Correction 2 & 4) ]] --
local function GetActiveQuest()
    local hasQuest = false
    
    -- **AMÉLIORATION : Le pcall empêche la boucle de farm de crash si la fenêtre de quête est supprimée subitement par le jeu.**
    local success, err = pcall(function()
        local questFrame = mainGui:FindFirstChild("Quest")
        
        if questFrame and questFrame.Visible then
            local container = questFrame:FindFirstChild("Container")
            if container then
                -- **CORRECTION : On utilise FindFirstChildWhichIsA("TextLabel") au lieu du nom "QuestTitle".**
                -- **Cela garantit que l'objet est bien un texte avant de lire la propriété .Text ! Fini les erreurs "Frame".**
                local titleObj = container:FindFirstChildWhichIsA("TextLabel")
                
                if titleObj and titleObj.Text ~= "" then
                    hasQuest = true
                end
            end
        end
    end)
    
    if not success then 
        warn("⚠️ [AVERTISSEMENT] Erreur de lecture du GUI ignorée : " .. tostring(err)) 
    end
    
    return hasQuest
end

-- [[ ⚔️ ÉTAPE 5 : MOTEUR PRINCIPAL D'AUTOFARM (Correction 1) ]] --
-- **CORRECTION : La fonction Start est définie AVANT l'interface. Plus aucune erreur "attempt to call a nil value" !**
function AutofarmPro.Start()
    task.spawn(function()
        while _G.AutoFarmEnabled do
            local success, err = pcall(function()
                local char = Player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                -- Utilisation de notre fonction ultra-sécurisée
                local isQuestActive = GetActiveQuest()
                
                -- Logique simplifiée (à adapter avec tes données QuestsData)
                if not isQuestActive then
                    -- Logique pour prendre la quête
                    -- root.CFrame = ...
                    -- Remote:InvokeServer("StartQuest", ...)
                else
                    -- Logique pour combattre les monstres
                    -- VirtualUser:CaptureController()
                    -- VirtualUser:Button1Down(Vector2.new(0,0))
                end
            end)
            
            if not success then
                warn("⚠️ [ERREUR MOTEUR] : " .. tostring(err))
            end
            
            task.wait(0.5)
        end
    end)
end

-- [[ 🖥️ ÉTAPE 6 : CRÉATION DE L'INTERFACE UTILISATEUR (En tout dernier) ]] --
-- **CORRECTION : L'UI est chargée après que AutofarmPro.Start soit parfaitement fonctionnel et en mémoire.**
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({ Title = "YUUSCRIPT V3.0", TabWidth = 160, Size = UDim2.fromOffset(580, 520), Theme = "Dark" })
local Tabs = { Main = Window:AddTab({ Title = "Autofarm", Icon = "swords" }) }

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

-- [[ ✅ ÉTAPE 7 : RETOUR DU MODULE COMPLET ]] --
-- **CORRECTION : La table AutofarmPro est retournée uniquement lorsqu'elle est remplie à 100%.**
return AutofarmPro