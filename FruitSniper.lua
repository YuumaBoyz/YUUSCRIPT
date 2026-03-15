local Tween = _G.TweenModule -- On utilise le module global chargé par le Loader
local FruitSniper = {}

-- Paramètres de configuration
local SNIPE_SPEED = 350 
local CHECK_DELAY = 1.5
local DEBOUNCE = false -- Empêche les doubles déclenchements

-- Système de notification fluide
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

function FruitSniper.CheckAndCollect()
    if DEBOUNCE or not _G.SniperEnabled then return end
    
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = character.HumanoidRootPart

    for _, item in pairs(workspace:GetChildren()) do
        -- Détection précise : objet Tool avec un Handle (fruit au sol)
        if item:IsA("Tool") and (item.Name:find("Fruit") or item:FindFirstChild("Handle")) then
            local handle = item:FindFirstChild("Handle")
            if handle then
                DEBOUNCE = true
                
                -- 1. SAUVEGARDE & NOTIFICATION DÉBUT 📍
                local oldCFrame = rootPart.CFrame
                local fruitName = item.Name
                NotifyFruit("🍎 Fruit Détecté", "Localisation : " .. fruitName, "Téléportation en cours...")

                -- 2. TÉLÉPORTATION SÉCURISÉE 🚀
                -- On utilise le moteur amélioré avec Noclip intégré
                local move = Tween.MoveTo(handle.CFrame, SNIPE_SPEED)
                
                -- Timeout de sécurité : si le move dure trop longtemps, on annule
                local success = true
                task.delay(10, function() if DEBOUNCE then success = false end end)
                
                move.Completed:Wait()

                -- 3. COLLECTE OPTIMISÉE 🖐️
                if success then
                    task.wait(0.3)
                    -- Simulation de ramassage par contact
                    firetouchinterest(rootPart, handle, 0) 
                    firetouchinterest(rootPart, handle, 1)
                    
                    task.wait(0.7) -- Latence pour laisser le temps au jeu d'enregistrer l'item
                    
                    NotifyFruit("✅ Succès", fruitName .. " a été ajouté à l'inventaire.", "Retour au point de farm...")
                else
                    NotifyFruit("⚠️ Échec", "Le fruit a disparu ou est inaccessible.", "Retour forcé.")
                end

                -- 4. RETOUR PRÉCIS 🔙
                local back = Tween.MoveTo(oldCFrame, SNIPE_SPEED)
                back.Completed:Wait()
                
                DEBOUNCE = false
                break 
            end
        end
    end
end

function FruitSniper.StartLoop()
    _G.SniperEnabled = true
    NotifyFruit("🚀 Sniper Actif", "Le scan des fruits est lancé.", "Fréquence : " .. CHECK_DELAY .. "s")
    
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
    NotifyFruit("🔇 Sniper Off", "Le système de collecte est désactivé.", "")
end

return FruitSniper