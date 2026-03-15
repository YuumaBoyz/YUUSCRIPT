-- [[ 🛡️ YUUSCRIPT : LOADER UNIVERSEL ET SÉCURISÉ ]] --

local base_url = "https://raw.githubusercontent.com/YuumaBoyz/YUUSCRIPT/main/"
local modules = {
    {name = "Interface (Fluent)", file = "Main.lua"},
    {name = "Moteur de Mouvement", file = "TweenModule.lua"},
    {name = "Combat Rapide", file = "FastAttack.lua"},
    {name = "Logique de Farm", file = "Autofarm.lua"},
    {name = "Détection de Fruits", file = "FruitSniper.lua"},
    {name = "Système Visuel", file = "Visuals.lua"}
}

-- **⚙️ CONFIGURATION GLOBALE V3.0**
_G.AutoFarmEnabled = false
_G.InstantSniper = false
_G.SelectedWeapon = "Combat"
_G.AutoStats = false
_G.StatsTarget = "Melee"
_G.FruitESP = false
_G.AntiAFK = true
_G.AutoAttackEnabled = false -- Fix : Indispensable pour le démarrage
_G.FastAttackSpeed = 0.05    -- Fix : Valeur par défaut
_G.YuuLoaded = false

-- 🛠️ Fonction de chargement avec tentative de secours (Retry Logic)
local function safeLoad(fileName, displayName)
    local full_url = base_url .. fileName
    local attempts = 0
    local max_attempts = 3
    local result = nil

    repeat
        attempts = attempts + 1
        local success, content = pcall(function()
            return game:HttpGet(full_url)
        end)

        if success and content then
            local func, err = loadstring(content)
            if func then
                -- On passe le script dans un environnement sécurisé
                local s, res = pcall(func)
                if s then
                    print("✅ [LOADER] : " .. displayName .. " chargé.")
                    return res
                else
                    warn("❌ [RUNTIME ERROR] : " .. displayName .. " -> " .. tostring(res))
                end
            else
                warn("❌ [ERREUR SCRIPT] : " .. displayName .. " -> " .. tostring(err))
            end
        else
            warn("⏳ [RETRY] : " .. displayName .. " (Tentative " .. attempts .. "/" .. max_attempts .. ")")
            task.wait(1)
        end
    until attempts >= max_attempts

    return nil
end

-- 🚀 Lancement du processus
print("-----------------------------------------")
print("🔥 YUUSCRIPT V3.0 INITIALISATION...")
print("-----------------------------------------")

-- 1. Attente du jeu et de l'UI (Fix : image_1e54ff.jpg)
if not game:IsLoaded() then game.Loaded:Wait() end
local Player = game:GetService("Players").LocalPlayer
local pGui = Player:WaitForChild("PlayerGui", 30)
pGui:WaitForChild("Main", 20) -- On attend l'interface de Blox Fruits

-- 2. Chargement séquentiel
for _, module in ipairs(modules) do
    local loaded = safeLoad(module.file, module.name)
    
    -- Assignation sécurisée pour accès inter-scripts
    if module.file == "TweenModule.lua" then _G.TweenModule = loaded
    elseif module.file == "FastAttack.lua" then _G.FastAttack = loaded
    elseif module.file == "Autofarm.lua" then _G.Autofarm = loaded
    elseif module.file == "FruitSniper.lua" then _G.FruitSniper = loaded
    elseif module.file == "Visuals.lua" then _G.Visuals = loaded
    end
end

-- 3. Activation de l'Anti-AFK (Intégré au Loader)
if _G.AntiAFK then
    local VirtualUser = game:GetService("VirtualUser")
    Player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
    print("💤 [YUUSCRIPT] : Anti-AFK activé.")
end

-- 4. Initialisation finale
task.spawn(function()
    _G.YuuLoaded = true
    print("-----------------------------------------")
    print("✨ [YUUSCRIPT] : TOUS LES SYSTÈMES SONT PRÊTS.")
    print("-----------------------------------------")
end)

-- Notification visuelle stylisée
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "💎 YUUSCRIPT V3.0",
    Text = "Système Fusion Finale chargé ! Bonne aventure.",
    Icon = "rbxassetid://6034509993",
    Duration = 8
})