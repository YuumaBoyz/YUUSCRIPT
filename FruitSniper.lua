local FruitSniper = {}
local Tween = _G.TweenModule 

-- [[ PARAMÈTRES ]] --
local SNIPE_SPEED = 350 
local CHECK_DELAY = 1.5
local DEBOUNCE = false 

-- [[ SYSTÈME DE NOTIFICATION ]] --
local function NotifyFruit(title, content, sub)
    if Fluent then
        Fluent:Notify({
            Title = title,
            Content = content,
            SubContent = sub,
            Duration = 5
        })
    else
        print("[" .. title .. "] " .. content)
    end
end

-- [[ LOGIQUE DE COLLECTE ]] --
function FruitSniper.CheckAndCollect()
    if DEBOUNCE or not _G.SniperEnabled then return end
    
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = character.HumanoidRootPart

    for _, item in pairs(workspace:GetChildren()) do
        -- Détection multi-format (Tool ou Model avec Handle)
        if (item:IsA("Tool") or item:IsA("Model")) and (item.Name:find("Fruit") or item:FindFirstChild("Handle") or item:FindFirstChild("Fruit")) then
            local targetPart = item:FindFirstChild("Handle") or item:FindFirstChildOfClass("Part")
            
            if targetPart then
                DEBOUNCE = true
                
                -- 1. SAUVEGARDE & PAUSE AUTOFARM 📍
                local oldCFrame = rootPart.CFrame
                local fruitName = item.Name
                local wasFarmEnabled = _G.AutoFarmEnabled
                _G.AutoFarmEnabled = false -- Pause pour éviter les conflits de mouvement
                
                NotifyFruit("🍎 Fruit Détecté", "Cible : " .. fruitName, "Téléportation prioritaire...")

                -- 2. DÉPLACEMENT SÉCURISÉ 🚀
                local move = Tween.MoveTo(targetPart.CFrame * CFrame.new(0, 2, 0), SNIPE_SPEED)
                
                local success = true
                local arrived = false
                
                -- Connexion pour détecter l'arrivée
                local connection
                connection = move.Completed:Connect(function() 
                    arrived = true 
                    connection:Disconnect()
                end)
                
                -- Timeout de sécurité (10s max pour le trajet)
                local start = tick()
                repeat task.wait() until arrived or (tick() - start) > 10
                
                if not arrived then success = false end

                -- 3. COLLECTE FORCÉE 🖐️
                if success then
                    task.wait(0.3)
                    -- Simulation de contact physique Triple A
                    firetouchinterest(rootPart, targetPart, 0) 
                    firetouchinterest(rootPart, targetPart, 1)
                    
                    task.wait(0.7) -- Latence serveur
                    NotifyFruit("✅ Succès", fruitName .. " récupéré !", "Retour au point de départ...")
                else
                    NotifyFruit("⚠️ Échec", "Le trajet a pris trop de temps.", "Retour forcé.")
                end

                -- 4. RETOUR & REPRISE 🔙
                local back = Tween.MoveTo(oldCFrame, SNIPE_SPEED)
                back.Completed:Wait()
                
                _G.AutoFarmEnabled = wasFarmEnabled -- Relance l'autofarm là où il en était
                DEBOUNCE = false
                break 
            end
        end
    end
end

-- [[ GESTION DES BOUCLES ]] --
function FruitSniper.StartLoop()
    _G.SniperEnabled = true
    NotifyFruit("🚀 Sniper Actif", "Scan du serveur en cours...", "Vérification toutes les " .. CHECK_DELAY .. "s")
    
    task.spawn(function()
        while _G.SniperEnabled do
            local success, err = pcall(FruitSniper.CheckAndCollect)
            if not success then 
                warn("Erreur Sniper: " .. err)
                DEBOUNCE = false 
            end
            task.wait(CHECK_DELAY)
        end
    end)
end

function FruitSniper.Stop()
    _G.SniperEnabled = false
    DEBOUNCE = false
    NotifyFruit("🔇 Sniper Off", "Scan interrompu.", "")
end

_G.FruitSniper = FruitSniper -- Export global pour l'interface
return FruitSniper