--[[ 👑 YUUSCRIPT V12 - OFFICIAL LOADER ]]
local function Load(file)
    -- Remplace "YUUMA_REPO" par ton vrai lien GitHub brut plus tard
    local url = "https://raw.githubusercontent.com/YUUMA_REPO/main/" .. file .. ".lua"
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success then warn("❌ Erreur de chargement : " .. file .. " -> " .. result) end
end

-- Ordre de chargement critique
Load("Config")    -- 1. On définit les variables
Load("Functions") -- 2. On charge les moteurs
Load("MainUI")    -- 3. On affiche l'interface