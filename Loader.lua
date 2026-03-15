-- [[ LOADER DISCRET POUR JJSPLOIT ]] --

-- On s'arrête bien au "/" pour pouvoir coller le nom des fichiers derrière
local base_url = "https://raw.githubusercontent.com/YuumaBoyz/YUUSCRIPT/main/"

-- Fonction pour charger un module proprement
local function loadModule(fileName)
    -- On construit l'URL complète ici
    local full_url = base_url .. fileName
    
    local success, result = pcall(function()
        return loadstring(game:HttpGet(full_url))()
    end)
    
    if success then
        -- Si le module retourne une table (comme TweenModule), on la récupère
        return result
    else
        warn("❌ Erreur de chargement : " .. fileName .. " | " .. result)
        return nil
    end
end

-- Chargement des modules
-- Note : On les met dans _G pour qu'ils soient accessibles partout
_G.TweenModule = loadModule("TweenModule.lua")
_G.Autofarm = loadModule("Autofarm.lua")
_G.FruitSniper = loadModule("FruitSniper.lua")

-- Lancement de l'interface principale
loadModule("Main.lua")

print("✨ [System] : Modules chargés avec succès depuis GitHub !")