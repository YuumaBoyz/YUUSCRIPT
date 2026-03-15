-- [[ MODULE FRUIT SNIPER : INSTANT TP & PICKUP ]] --
local FruitSniper = {}

-- [[ VARIABLES DE CONTRÔLE ]] --
_G.InstantSniper = true -- Toggle Global
local DEBOUNCE = false
local CHECK_DELAY = 0.1 -- Fréquence de scan (Ultra-Rapide)

-- [[ NOTIFICATIONS ]] --
local function Notify(title, msg, type)
    if Fluent then
        Fluent:Notify({
            Title = title,
            Content = msg,
            SubContent = "Fruit Detection System",
            Duration = 5
        })
    else
        print(string.format("🍎 [%s] : %s", title, msg))
    end
end

-- [[ LOGIQUE DE SNIPE ]] --
function FruitSniper.Snap(item)
    if DEBOUNCE or not _G.InstantSniper then return end
    
    local player = game.Players.LocalPlayer
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Identification de la partie tactile (Handle)
    local handle = item:FindFirstChild("Handle") or item:FindFirstChildOfClass("Part") or item:FindFirstChildOfClass("MeshPart")
    if not handle then return end

    DEBOUNCE = true
    
    local success, err = pcall(function()
        -- 1. SAUVEGARDE & SÉCURITÉ 📍
        local oldCFrame = root.CFrame
        local wasFarmEnabled = _G.AutoFarmEnabled -- On coupe l'autofarm pour éviter les conflits
        _G.AutoFarmEnabled = false
        
        Notify("🍎 FRUIT DÉTECTÉ", "Cible : " .. item.Name, "success")

        -- 2. DÉSACTIVATION COLLISION (NOCLIP TEMPORAIRE) 👻
        local noclip = game:GetService("RunService").Stepped:Connect(function()
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end)

        -- 3. TÉLÉPORTATION INSTANTANÉE (BRUTE FORCE) ⚡
        -- On ignore la vélocité pour un TP propre
        root.Velocity = Vector3.new(0,0,0)
        root.CFrame = handle.CFrame * CFrame.new(0, 1, 0)
        task.wait(0.05) -- Latence minimale pour le moteur physique

        -- 4. COLLECTE FORCÉE (FIRETOUCHINTEREST) 🖐️
        -- Signal 0 : Début de contact | Signal 1 : Fin de contact
        firetouchinterest(root, handle, 0)
        task.wait(0.05)
        firetouchinterest(root, handle, 1)

        -- 5. ATTENTE VALIDATION SERVEUR ⏳
        task.wait(0.3) 

        -- 6. RETOUR AU POINT D'ORIGINE 🔙
        root.CFrame = oldCFrame
        noclip:Disconnect()
        
        -- Relance l'autofarm si nécessaire
        _G.AutoFarmEnabled = wasFarmEnabled
        Notify("✅ COLLECTÉ", item.Name .. " est dans l'inventaire.", "info")
    end)

    if not success then
        warn("⚠️ Erreur Sniper : " .. tostring(err))
    end
    
    DEBOUNCE = false
end

-- [[ BOUCLE DE SCAN HAUTE PRIORITÉ ]] --
function FruitSniper.Start()
    task.spawn(function()
        Notify("🚀 SNIPER ACTIF", "Scan du Workspace (0.1s) lancé.", "info")
        
        while true do
            if _G.InstantSniper and not DEBOUNCE then
                -- Scan rapide du Workspace
                for _, obj in pairs(workspace:GetChildren()) do
                    if (obj:IsA("Tool") or obj:IsA("Model")) then
                        -- Détection par nom ou présence de "Fruit"
                        if obj.Name:find("Fruit") or obj:FindFirstChild("Fruit") then
                            FruitSniper.Snap(obj)
                            break -- On sort pour traiter le fruit trouvé
                        end
                    end
                end
            end
            task.wait(CHECK_DELAY)
        end
    end)
end

-- Exportation globale
_G.FruitSniper = FruitSniper 
return FruitSniper