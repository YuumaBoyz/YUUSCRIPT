-- [[ 💎 YUUSCRIPT : LOADER UNIVERSEL ]] --

local base_url = "https://raw.githubusercontent.com/YuumaBoyz/YUUSCRIPT/main/"

-- Configuration Initiale (À modifier selon tes besoins)
_G.SelectedWeapon = "Combat" -- Remplace par "Katana" ou autre si besoin
_G.TweenSpeed = 300          -- Vitesse du Tween
_G.AutoFarmEnabled = false   -- Par défaut à false pour sécurité au lancement

-- Fonction de chargement sécurisée
local function loadModule(fileName)
    local full_url = base_url .. fileName
    local success, result = pcall(function()
        return loadstring(game:HttpGet(full_url))()
    end)
    
    if success then
        return result
    else
        warn("❌ Erreur de chargement : " .. fileName .. " | " .. tostring(result))
        return nil
    end
end

-- [[ CHARGEMENT DES MODULES DANS L'ORDRE LOGIQUE ]] --

-- 1. Utilitaires de mouvement
_G.TweenModule = loadModule("TweenModule.lua")

-- 2. Système de combat (VITAL : Charger FastAttack AVANT l'Autofarm)
_G.FastAttack = loadModule("FastAttack.lua")

-- 3. Logique de jeu
_G.Autofarm = loadModule("Autofarm.lua")
_G.FruitSniper = loadModule("FruitSniper.lua")
_G.Visuals = loadModule("Visuals.lua")

-- [[ INITIALISATION ]] --

-- On lance la boucle du FastAttack en fond
if _G.FastAttack and _G.FastAttack.Start then
    _G.FastAttack.Start()
end

-- Lancement de l'interface (Main.lua)
loadModule("Main.lua")

print("✨ [YUUSCRIPT] : Système prêt. Fast Attack en veille.")