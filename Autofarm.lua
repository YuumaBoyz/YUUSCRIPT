local AutofarmPro = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local Player = Players.LocalPlayer

-- [[ SÉCURITÉ GUI AMÉLIORÉE ]] --
local function GetActiveQuest()
    -- On utilise pcall pour que même si le GUI change, le script ne crash pas
    local success, hasQuest = pcall(function()
        local main = Player:WaitForChild("PlayerGui", 5):FindFirstChild("Main")
        local questFrame = main and main:FindFirstChild("Quest")
        
        if questFrame and questFrame.Visible then
            local container = questFrame:FindFirstChild("Container")
            local title = container and container:FindFirstChild("QuestTitle")
            
            if title then
                -- Ta logique intelligente de détection
                if title:IsA("TextLabel") then return title.Text ~= "" end
                local realText = title:FindFirstChildWhichIsA("TextLabel")
                return realText and realText.Text ~= ""
            end
        end
        return false
    end)
    return success and hasQuest
end

-- [[ RECHERCHE SÉCURISÉE ]] --
local function GetClosestMob(targetName)
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    
    local closest, dist = nil, math.huge
    -- On sécurise le root part du joueur
    local myRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    for _, v in pairs(enemies:GetChildren()) do
        if v.Name == targetName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local r = v:FindFirstChild("HumanoidRootPart")
            if r then
                local d = (myRoot.Position - r.Position).Magnitude
                if d < dist then dist = d; closest = v end
            end
        end
    end
    return closest
end

function AutofarmPro.Start()
    _G.AutoFarmEnabled = true -- On s'assure qu'il est actif
    
    task.spawn(function()
        while _G.AutoFarmEnabled do
            local status, err = pcall(function()
                local char = Player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                -- Sécurité Level Data
                local dataFolder = Player:FindFirstChild("Data")
                local currentLevel = dataFolder and dataFolder:FindFirstChild("Level") and dataFolder.Level.Value or 0

                -- On vérifie que les quêtes existent
                if not _G.QuestsData then return end
                
                local target = _G.QuestsData[1]
                for _, data in ipairs(_G.QuestsData) do
                    if currentLevel >= data.Level then target = data end
                end

                if not GetActiveQuest() then
                    -- TP sur le NPC
                    root.CFrame = target.Pos
                    task.wait(0.5)
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", target.Name, target.QuestID)
                else
                    local mob = GetClosestMob(target.Mob)
                    if mob then
                        -- Équipement automatique
                        local tool = Player.Backpack:FindFirstChild(_G.SelectedWeapon) or char:FindFirstChild(_G.SelectedWeapon)
                        if tool then char.Humanoid:EquipTool(tool) end
                        
                        -- TP Combat (Au dessus pour éviter collision)
                        root.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0)
                        
                        -- Attaque
                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new(0,0))
                    else
                        -- Attente respawn (plus haut pour être tranquille)
                        root.CFrame = target.Pos * CFrame.new(0, 50, 0)
                    end
                end
            end)
            
            if not status then warn("⚠️ Erreur Autofarm Loop: " .. err) end
            task.wait(0.1)
        end
    end)
end

return AutofarmPro