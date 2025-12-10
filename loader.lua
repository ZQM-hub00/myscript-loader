-- loader.lua - central loader (place this in your GitHub repo)
local HttpService = game:GetService("HttpService")

-- METS ICI ton raw config URL (déjà OK pour toi)
local configUrl = "https://raw.githubusercontent.com/ZQM-hub00/myscript-loader/refs/heads/main/config.json"

-- Try to download config
local ok, raw = pcall(function() return game:HttpGet(configUrl) end)
if not ok then
    warn("Loader: impossible de charger config.json:", raw)
    return
end

local config
local ok2, err = pcall(function() config = HttpService:JSONDecode(raw) end)
if not ok2 then
    warn("Loader: erreur JSON config:", err)
    return
end

-- Récupération avec fallback
local link1 = (config.link1 and tostring(config.link1) ~= "" ) and config.link1
local link2 = (config.link2 and tostring(config.link2) ~= "" ) and config.link2

if not link1 and not link2 then
    warn("Loader: pas de liens valides dans config.json")
    return
end

-- Affiche dans la console pour debug
print("Loader: link1 =", link1)
print("Loader: link2 =", link2)

-- Si tu veux exécuter les scripts contenus dans link1/link2 (ATTENTION: remote code)
-- loadstring(game:HttpGet(link1))()
-- loadstring(game:HttpGet(link2))()

-- Pour ton UI, tu peux envoyer les liens au jeu, par ex. :
-- (ici on se contente de les garder disponibles)
return {
    link1 = link1,
    link2 = link2
}
