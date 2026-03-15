-- [[ LOADER DISCRET POUR JJSPLOIT ]] --

local base_url = "https://raw.githubusercontent.com/YuumaBoyz/YUUSCRIPT/main/Main.lua"

-- Fonction pour charger un module proprement
local function loadModule(fileName)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(base_url .. fileName))()
    end)
    if success then
        return result
    else
        warn("❌ Erreur de chargement : " .. fileName .. " | " .. result)
    end
end

-- Chargement des modules dans l'environnement global
_G.TweenModule = loadModule("TweenModule.lua")
_G.Autofarm = loadModule("Autofarm.lua")
_G.FruitSniper = loadModule("FruitSniper.lua")

-- Lancement de l'interface Fluent (que nous avons vue ensemble)
-- Assure-toi que ton Main.lua sur GitHub appelle bien _G.TweenModule etc.
loadModule("Main.lua")

print("✨ [System] : Modules chargés avec succès depuis GitHub !")