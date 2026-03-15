-- [[ MODULE AUTOFARM CORRIGÉ ]] --
local Autofarm = {}

-- On récupère le module Tween depuis l'environnement global (chargé par le Loader)
local Tween = _G.TweenModule 

-- Configuration interne
local DISTANCE_ABOVE_MOB = 5 

function Autofarm.Start(npcName, questName, mobName)
    -- Sécurité : on vérifie si le module Tween est bien présent
    if not Tween then 
        warn("❌ Erreur : TweenModule n'est pas chargé dans _G !")
        return 
    end

    _G.AutoFarmEnabled = true
    print("🚀 Démarrage de l'Autofarm pour : " .. mobName)
    
    task.spawn(function()
        while _G.AutoFarmEnabled do
            task.wait(0.1)
            
            -- Vérification de la quête
            local player = game.Players.LocalPlayer
            local playerGui = player:WaitForChild("PlayerGui")
            local mainGui = playerGui:FindFirstChild("Main")
            local hasQuest = mainGui and mainGui:FindFirstChild("Quest") and mainGui.Quest.Visible
            
            if not hasQuest then
                -- 1. ALLER PRENDRE LA QUÊTE
                local npc = workspace.NPCs:FindFirstChild(npcName)
                if npc and npc:FindFirstChild("HumanoidRootPart") then
                    print("✨ TP vers NPC : " .. npcName)
                    local move = Tween.MoveTo(npc.HumanoidRootPart.CFrame, _G.TweenSpeed)
                    move.Completed:Wait()
                    
                    -- Interaction Remote
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", questName, 1)
                end
            else
                -- 2. ALLER TUER LES MOBS
                local enemies = workspace:FindFirstChild("Enemies")
                if enemies then
                    for _, mob in pairs(enemies:GetChildren()) do
                        if mob.Name == mobName and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                            print("⚔️ Combat : " .. mobName)
                            
                            repeat
                                if not _G.AutoFarmEnabled then break end
                                
                                -- On suit le mob avec le Tween amélioré (Noclip inclus)
                                Tween.MoveTo(mob.HumanoidRootPart.CFrame * CFrame.new(0, DISTANCE_ABOVE_MOB, 0), _G.TweenSpeed)
                                
                                -- Attaque
                                local character = player.Character
                                local tool = character and character:FindFirstChildOfClass("Tool")
                                if tool then
                                    tool:Activate()
                                end
                                
                                task.wait(0.1)
                            until not mob or not mob:FindFirstChild("Humanoid") or mob.Humanoid.Health <= 0
                            
                            task.wait(0.5)
                        end
                    end
                end
            end
        end
    end)
end

function Autofarm.Stop()
    _G.AutoFarmEnabled = false
    print("🛑 Autofarm stoppé.")
end

return Autofarm