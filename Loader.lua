--[[ 👑 YUUMA LOADER V12 ]]
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- 📢 Notification de lancement
Fluent:Notify({
    Title = "👑 YUUSCRIPT",
    Content = "Initialisation du chargement...",
    Duration = 3
})

-- 📥 CHARGEMENT DU FICHIER 1 (LOGIQUE)
local success1, err1 = pcall(function()
    -- REMPLACE LE LIEN CI-DESSOUS PAR TON LIEN RAW GITHUB POUR YUUSCRIPT1.lua
    loadstring(game:HttpGet("https://raw.githubusercontent.com/TON_NOM/TON_REPO/main/YUUSCRIPT1.lua"))()
end)

if not success1 then
    warn("❌ ERREUR FICHIER 1 : " .. tostring(err1))
end

task.wait(0.5) -- Petit délai pour laisser les fonctions s'enregistrer

-- 📥 CHARGEMENT DU FICHIER 2 (INTERFACE)
local success2, err2 = pcall(function()
    -- REMPLACE LE LIEN CI-DESSOUS PAR TON LIEN RAW GITHUB POUR YUUSCRIPT2.lua
    loadstring(game:HttpGet("https://raw.githubusercontent.com/TON_NOM/TON_REPO/main/YUUSCRIPT2.lua"))()
end)

if not success2 then
    warn("❌ ERREUR FICHIER 2 : " .. tostring(err2))
end

Fluent:Notify({
    Title = "✅ CHARGÉ",
    Content = "YUUSCRIPT est prêt !",
    Duration = 5
})