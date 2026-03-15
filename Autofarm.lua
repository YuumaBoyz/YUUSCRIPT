-- [[ 1. INITIALISATION DU MODULE ]] --
local AutofarmPro = {} 
_G.AutofarmPro = AutofarmPro -- Enregistrement immédiat pour éviter l'erreur "nil value"

-- [[ SERVICES ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

-- [[ VARIABLES ]] --
local Player = Players.LocalPlayer
local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- [[ FONCTIONS UTILITAIRES ]] --
local function Log(emoji, msg) 
    print(string.format("%s ***[YUUSCRIPT ENGINE] : %s***", emoji, msg)) 
end

local function Stabilize(root, enable)
    if enable then
        if not root:FindFirstChild("YuuVelocity") then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "YuuVelocity"
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = root
        end
    else
        if root:FindFirstChild("YuuVelocity") then root.YuuVelocity:Destroy() end
    end
end

-- [[ MOTEUR DE COMBAT PRINCIPAL ]] --
function AutofarmPro.Start()
    if not _G.AutoFarmEnabled then return end
    Log("⚔️", "Lancement du cycle de combat...")

    task.spawn(function()
        while _G.AutoFarmEnabled do
            local success, err = pcall(function()
                local char = Player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                local targetData = AutofarmPro.GetTargetData()
                
                -- [[ DÉTECTION SÉCURISÉE DU TEXTE (Correctif Warning Jaune) ]] --
                -- Ce bloc empêche l'erreur "Text is not a valid member of Frame"
                local pGui = Player:FindFirstChild("PlayerGui")
                local questFrame = pGui and pGui:FindFirstChild("Main") and pGui.Main:FindFirstChild("Quest")
                local hasQuest = false

                if questFrame and questFrame.Visible then
                    local container = questFrame:FindFirstChild("Container")
                    local titleObj = container and container:FindFirstChild("QuestTitle")
                    
                    -- Vérification stricte du type d'objet
                    if titleObj and (titleObj:IsA("TextLabel") or titleObj:IsA("TextBox")) then
                        if titleObj.Text ~= "" then
                            hasQuest = true
                        end
                    end
                end
                
                -- [[ LOGIQUE DE FARM ]] --
                if not hasQuest then
                    -- ÉTAPE 1 : PRENDRE LA QUÊTE
                    Stabilize(root, false)
                    root.CFrame = targetData.Pos
                    task.wait(0.5)
                    Remote:InvokeServer("StartQuest", targetData.Name, targetData.QuestID)
                else
                    -- ÉTAPE 2 : COMBAT
                    local mob = GetClosestMob(targetData.Mob, targetData.Pos)
                    if mob and mob:FindFirstChild("HumanoidRootPart") then
                        Stabilize(root, true)
                        root.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new(0,0))
                    else
                        root.CFrame = targetData.Pos * CFrame.new(0, 30, 0)
                    end
                end
            end)
            
            if not success then warn("❌ ***Erreur Moteur : " .. err .. "***") end
            task.wait() 
        end
        
        -- Nettoyage à l'arrêt
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Stabilize(Player.Character.HumanoidRootPart, false)
        end
    end)
end

function AutofarmPro.Stop()
    _G.AutoFarmEnabled = false
    Log("🛑", "Arrêt du moteur de farm.")
end

-- [[ 3. INTERFACE UTILISATEUR (DERNIÈRE ÉTAPE) ]] --
-- Placé ici pour s'assurer que AutofarmPro.Start existe déjà
local FarmToggle = Tabs.Main:AddToggle("AutoFarm", {Title = "Activer l'Autofarm", Default = false })

FarmToggle:OnChanged(function()
    _G.AutoFarmEnabled = Options.AutoFarm.Value
    if _G.AutoFarmEnabled then
        -- Correctif définitif pour l'erreur de la ligne 53
        if _G.AutofarmPro and _G.AutofarmPro.Start then
            _G.AutofarmPro.Start()
        else
            warn("⚠️ ***[YUUSCRIPT] : Le moteur n'est pas encore prêt !***")
        end
    end
end)

-- [[ FINALISATION ]] --
_G.AutofarmPro = AutofarmPro
return AutofarmPro