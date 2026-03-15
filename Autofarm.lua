local Tween = require(script.Parent.TweenModule)
local Autofarm = {}

-- Configuration interne (Peut être lié à l'UI plus tard)
local DISTANCE_ABOVE_MOB = 5 -- Se placer légèrement au-dessus pour éviter les dégâts

function Autofarm.Start(npcName, questName, mobName)
    _G.AutoFarmEnabled = true
    
    task.spawn(function()
        while _G.AutoFarmEnabled do
            task.wait(0.1)
            
            -- Vérifier si on a déjà une quête active
            local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
            local hasQuest = playerGui.Main:FindFirstChild("Quest") and playerGui.Main.Quest.Visible
            
            if not hasQuest then
                -- 1. ALLER PRENDRE LA QUÊTE
                local npc = workspace.NPCs:FindFirstChild(npcName)
                if npc and npc:FindFirstChild("HumanoidRootPart") then
                    print("✨ Déplacement vers le NPC : " .. npcName)
                    local tween = Tween.MoveTo(npc.HumanoidRootPart.CFrame, _G.TweenSpeed)
                    tween.Completed:Wait()
                    
                    -- Interaction avec le Remote du jeu pour accepter la quête
                    -- Note : Le nom du Remote peut varier selon la version du jeu
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", questName, 1)
                end
            else
                -- 2. ALLER TUER LES MOBS
                for _, mob in pairs(workspace.Enemies:GetChildren()) do
                    if mob.Name == mobName and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                        print("⚔️ Cible verrouillée : " .. mobName)
                        
                        -- On boucle sur le mob jusqu'à sa mort
                        repeat
                            if not _G.AutoFarmEnabled then break end
                            
                            -- Positionnement stratégique au-dessus du mob
                            Tween.MoveTo(mob.HumanoidRootPart.CFrame * CFrame.new(0, DISTANCE_ABOVE_MOB, 0), _G.TweenSpeed)
                            
                            -- Simulation d'attaque (Clique/Tool activation)
                            local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
                            if tool then
                                tool:Activate()
                            end
                            
                            task.wait(0.1)
                        until not mob or not mob:FindFirstChild("Humanoid") or mob.Humanoid.Health <= 0
                        
                        -- Petite pause pour la stabilité
                        task.wait(0.5)
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