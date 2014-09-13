--
--
--
economies = economies or {}
realestate = realestate or economies.realestate or {}
realestate.version = 1.00
realestate.modpath = minetest.get_modpath("realestate")

-- load configuraton
dofile(realestate.modpath.."/config.lua")

-- anything related to selling land
if economies.with_protection then
	dofile(realestate.modpath.."/landsale.lua")
	dofile(realestate.modpath.."/forsale_signs.lua")
end

-- landrush support
if economies.with_landrush then
	dofile(realestate.modpath.."/implementations/landrush.lua")
end
