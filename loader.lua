-- Loader centralisé

local configUrl = "https://raw.githubusercontent.com/TONPSEUDO/TONREPO/main/config.json"

local HttpService = game:GetService("HttpService")
local config = HttpService:JSONDecode(game:HttpGet(configUrl))

-- Exécute automatiquement les deux liens configurables
loadstring(game:HttpGet(config.link1))()
loadstring(game:HttpGet(config.link2))()
