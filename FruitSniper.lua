local FruitSniper = {}
-- Plus besoin de Tween ici pour la collecte

-- [[ PARAMÈTRES ]] --
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

-- [[ LOGIQUE DE COLLECTE INSTANTANÉE ]] --
function FruitSniper.CheckAndCollect()
    if DEBOUNCE or not _G.SniperEnabled then return end
    
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = character.HumanoidRootPart

    for _, item in pairs(workspace:GetChildren()) do
        if (item:IsA("Tool") or item:IsA("Model")) and (item.Name:find("Fruit") or item:FindFirstChild("Handle") or item:FindFirstChild("Fruit")) then
            local targetPart = item:FindFirstChild("Handle") or item:FindFirstChildOfClass("Part")
            
            if targetPart then
                DEBOUNCE = true
                
                -- 1. SAUVEGARDE & PAUSE 📍
                local oldCFrame = rootPart.CFrame
                local fruitName = item.Name
                local wasFarmEnabled = _G.AutoFarmEnabled
                _G.AutoFarmEnabled = false 
                
                NotifyFruit("🍎 Fruit Détecté", "Cible : " .. fruitName, "TP Instantané...")

                -- 2. TÉLÉPORTATION DIRECTE ⚡
                task.wait(0.1)
                rootPart.CFrame = targetPart.CFrame * CFrame.new(0, 2, 0)
                
                -- 3. COLLECTE FORCÉE 🖐️
                task.wait(0.2)
                firetouchinterest(rootPart, targetPart, 0) 
                firetouchinterest(rootPart, targetPart, 1)
                
                task.wait(0.5) -- Temps de latence serveur pour confirmer l'inventaire
                NotifyFruit("✅ Succès", fruitName .. " récupéré !", "Retour au farm...")

                -- 4. RETOUR INSTANTANÉ 🔙
                rootPart.CFrame = oldCFrame
                
                task.wait(0.1)
                _G.AutoFarmEnabled = wasFarmEnabled 
                DEBOUNCE = false
                break 
            end
        end
    end
end

-- [[ GESTION DES BOUCLES ]] --
function FruitSniper.StartLoop()
    _G.SniperEnabled = true
    NotifyFruit("🚀 Sniper Actif", "Scan Instantané actif", "")
    
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

_G.FruitSniper = FruitSniper 
return FruitSniper