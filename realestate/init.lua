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
if economy.with_protection then
	dofile(economy.realestate.modpath.."/landsale.lua")
	dofile(economy.realestate.modpath.."/forsale_signs.lua")
end

-- landrush support
if economy.with_landrush then
	dofile(economy.realestate.modpath.."/landrush_landsale.lua")
end
