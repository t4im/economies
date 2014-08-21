--
--
--
economy = economy or {}
economy.realestate = economy.realestate or {}
economy.realestate.version = 1.00
economy.realestate.modpath = minetest.get_modpath("realestate")

-- load configuraton
dofile(economy.realestate.modpath.."/config.lua")

-- load signs
dofile(economy.realestate.modpath.."/forsale_signs.lua")
