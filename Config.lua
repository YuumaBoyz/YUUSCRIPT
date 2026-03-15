--[[ ⚙️ CONFIGURATION INTERNE ]]
_G.Settings = {
    -- Farm
    AutoFarm = false,
    Weapon = "Melee",
    Distance = 10,
    FastAttackSpeed = 0.05,
    BringMobs = true,
    
    -- GodMode / Orbit
    GodMode = false,
    OrbitSpeed = 7,
    OrbitRadius = 8,
    VerticalOffset = 10,
    
    -- Fruits & Items
    AutoCollect = false,
    FruitESP = false,
    AutoStore = true,
    
    -- Système
    SafeMode = true,
    CurrentTarget = nil
}

-- Rendre les variables accessibles partout sans taper _G.Settings
setmetatable(_G, {
    __index = _G.Settings
})