--[[ 👑 YUUSCRIPT V12 - OFFICIAL LOADER ]]
local function Load(file)
    -- ✅ UTILISATION DU LIEN RAW CORRECT
    local url = "https://github.com/YuumaBoyz/YUUSCRIPT/main/MainUI.lua" .. file .. ".lua"
    
    print("📡 Tentative de chargement : " .. file) -- Pour débugger dans la console (F9)

    local success, result = pcall(function()
        local code = game:HttpGet(url)
        if code then
            return loadstring(code)()
        end
    end)

    if success then 
        print("✅ Chargé avec succès : " .. file)
    else 
        warn("❌ Erreur de chargement : " .. file .. " -> " .. result) 
    end
end

-- Ordre de chargement critique
Load("Config")    
Load("Functions") 
Load("MainUI")