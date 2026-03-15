-- [[ 1. RÉINITIALISATION DU MOTEUR ]] --
_G.AutoFarmEnabled = false
local AutofarmPro = {}

-- [[ 2. FONCTION DE DÉTECTION SÉCURISÉE (Cible l'erreur Frame) ]] --
local function IsQuestActive()
    local success, result = pcall(function()
        local pGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
        local questFrame = pGui and pGui.Main.Quest
        if questFrame and questFrame.Visible then
            local container = questFrame:FindFirstChild("Container")
            local title = container and container:FindFirstChild("QuestTitle")
            -- On vérifie que c'est bien un objet texte avant de lire .Text
            if title and (title:IsA("TextLabel") or title:IsA("TextBox")) then
                return title.Text ~= ""
            end
        end
        return false
    end)
    return success and result or false
end

-- [[ 3. DÉFINITION DE LA FONCTION START (Avant l'interface) ]] --
function AutofarmPro.Start()
    if _G.AutoFarmEnabled then
        task.spawn(function()
            while _G.AutoFarmEnabled do
                local ok, err = pcall(function()
                    -- Ta logique de farm ici
                    if not IsQuestActive() then
                        -- Prendre quête
                    else
                        -- Taper mobs
                    end
                end)
                if not ok then warn("Erreur boucle : " .. err) end
                task.wait(1)
            end
        end)
    end
end

-- On l'enregistre dans le global pour être sûr
_G.AutofarmPro = AutofarmPro

-- [[ 4. CRÉATION DE L'INTERFACE (En dernier !) ]] --
-- Assure-toi que tes variables Fluent, Window et Tabs sont bien définies au-dessus
Tabs.Main:AddToggle("AutoFarm", {Title = "Activer l'Autofarm", Default = false }):OnChanged(function()
    _G.AutoFarmEnabled = Fluent.Options.AutoFarm.Value
    
    -- On vérifie manuellement si la fonction est là pour éviter l'erreur "nil value"
    if _G.AutoFarmEnabled then
        if _G.AutofarmPro and _G.AutofarmPro.Start then
            _G.AutofarmPro.Start()
        else
            warn("ERREUR : Le moteur n'est pas chargé correctement.")
        end
    end
end)