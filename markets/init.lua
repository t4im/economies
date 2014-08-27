--
--
--
economy = economy or {}
economy.markets = economy.markets or {}
economy.markets.version = 1.00
economy.markets.modpath = minetest.get_modpath("markets")

-- load configuraton
dofile(economy.markets.modpath.."/config.lua")

