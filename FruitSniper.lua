local FruitSniper = {}

-- [[ PARAMÈTRES ]] --
local CHECK_DELAY = 1.0 -- Scan plus rapide
local DEBOUNCE = false 

function FruitSniper.CheckAndCollect()
    if DEBOUNCE or not _G.SniperEnabled then return end
    
    local player = game.Players.LocalPlayer
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    for _, item in pairs(workspace:GetChildren()) do
        -- Détection du fruit
        if (item:IsA("Tool") or item:IsA("Model")) and (item.Name:find("Fruit") or item:FindFirstChild("Handle")) then
            local targetPart = item:FindFirstChild("Handle") or item:FindFirstChildOfClass("Part")
            
            if targetPart then
                DEBOUNCE = true
                
                -- 1. PAUSE & SAUVEGARDE
                local oldCFrame = rootPart.CFrame
                local wasFarmEnabled = _G.AutoFarmEnabled
                _G.AutoFarmEnabled = false 
                
                print("⚡ [SNIPER] TP INSTANT : " .. item.Name)

                -- 2. TÉLÉPORTATION BRUTALE (Pas de trajet) 🚀
                -- On le fait deux fois pour bypasser les petites latences de vélocité
                rootPart.CFrame = targetPart.CFrame
                task.wait(0.1)
                rootPart.CFrame = targetPart.CFrame
                
                -- 3. COLLECTE PHYSIQUE
                firetouchinterest(rootPart, targetPart, 0) 
                task.wait(0.1)
                firetouchinterest(rootPart, targetPart, 1)
                
                -- Petit délai pour que le serveur valide l'item dans l'inventaire
                task.wait(0.3) 

                -- 4. RETOUR INSTANTANÉ & REPRISE
                rootPart.CFrame = oldCFrame
                task.wait(0.1)
                
                _G.AutoFarmEnabled = wasFarmEnabled 
                DEBOUNCE = false
                break 
            end
        end
    end
end

function FruitSniper.StartLoop()
    _G.SniperEnabled = true
    task.spawn(function()
        while _G.SniperEnabled do
            pcall(FruitSniper.CheckAndCollect)
            task.wait(CHECK_DELAY)
        end
    end)
end

function FruitSniper.Stop()
    _G.SniperEnabled = false
    DEBOUNCE = false
end

_G.FruitSniper = FruitSniper 
return FruitSniper