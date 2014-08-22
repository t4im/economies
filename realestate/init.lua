--
--
--
economy = economy or {}
economy.realestate = economy.realestate or {}
economy.realestate.version = 1.00
economy.realestate.modpath = minetest.get_modpath("realestate")

-- load configuraton
dofile(economy.realestate.modpath.."/config.lua")

-- anything related to selling land
dofile(economy.realestate.modpath.."/landsale.lua")
dofile(economy.realestate.modpath.."/forsale_signs.lua")

-- landrush support
if minetest.get_modpath("landrush") then
dofile(economy.realestate.modpath.."/landrush_landsale.lua")
end
