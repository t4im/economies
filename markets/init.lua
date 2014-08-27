--
--
--
economy = economy or {}
economy.markets = economy.markets or {}
economy.markets.version = 1.00
economy.markets.modpath = minetest.get_modpath("markets")

-- load configuraton
dofile(economy.markets.modpath.."/config.lua")

-- load markets
dofile(economy.markets.modpath.."/market_stalls.lua")
dofile(economy.markets.modpath.."/bulk_vending_machine.lua")
dofile(economy.markets.modpath.."/full_line_vending_machine.lua")
dofile(economy.markets.modpath.."/displays.lua")
