--
--
--
DIR_DELIM = DIR_DELIM or "/"
economies = economies or {}
markets = markets or {}
markets.version = 1.00
markets.modpath = minetest.get_modpath("markets") .. DIR_DELIM

-- load configuraton
dofile(markets.modpath .. "config.lua")

-- load crafting materials and upgrades
--dofile(economies.markets.modpath .. "components.lua")

-- load markets
dofile(markets.modpath .. "market_setup.lua")
dofile(markets.modpath .. "market.lua")
dofile(markets.modpath .. "market_stalls.lua")
dofile(markets.modpath .. "bulk_vending_machines.lua")
dofile(markets.modpath .. "full_line_vending_machines.lua")
dofile(markets.modpath .. "displays.lua")

economies.markets = markets
