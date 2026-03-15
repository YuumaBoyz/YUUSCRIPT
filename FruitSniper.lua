local Tween = require(script.Parent.TweenModule)
local FruitSniper = {}

-- Paramètre de vitesse pour le sniper (souvent plus rapide que l'autofarm)
local SNIPE_SPEED = 300 

function FruitSniper.CheckAndCollect()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")

    for _, item in pairs(workspace:GetChildren()) do
        -- Vérification si l'objet est un fruit au sol
        if item:IsA("Tool") and (item.Name:find("Fruit") or item:FindFirstChild("Handle")) then
            -- Vérification supplémentaire pour éviter les faux positifs
            if item:FindFirstChild("Handle") then
                
                -- 1. SAUVEGARDE DE LA POSITION ACTUELLE 📍
                local oldCFrame = rootPart.CFrame
                print("🍎 Fruit détecté : " .. item.Name .. " ! Tentative de récupération...")

                -- 2. TÉLÉPORTATION VERS LE FRUIT 🚀
                local move = Tween.MoveTo(item.Handle.CFrame, SNIPE_SPEED)
                move.Completed:Wait()

                -- 3. COLLECTE (Simulation de contact physique) 🖐️
                task.wait(0.2)
                firetouchinterest(rootPart, item.Handle, 0) -- Touche
                firetouchinterest(rootPart, item.Handle, 1) -- Relâche
                task.wait(0.5) -- Temps de latence pour l'inventaire

                -- 4. RETOUR À LA POSITION DE DÉPART 🔙
                print("✅ Fruit collecté. Retour au farm...")
                local back = Tween.MoveTo(oldCFrame, SNIPE_SPEED)
                back.Completed:Wait()
                
                break -- Sort de la boucle pour ne pas traiter 5 fruits d'un coup
            end
        end
    end
end

-- Fonction de boucle pour l'UI Fluent
function FruitSniper.StartLoop()
    _G.SniperEnabled = true
    task.spawn(function()
        while _G.SniperEnabled do
            FruitSniper.CheckAndCollect()
            task.wait(1.5) -- Scan toutes les 1.5 secondes pour économiser les ressources
        end
    end)
end

function FruitSniper.Stop()
    _G.SniperEnabled = false
    print("🔇 Fruit Sniper désactivé.")
end

return FruitSniper