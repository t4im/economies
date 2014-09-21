--
--
--
DIR_DELIM = DIR_DELIM or "/"
economies = economies or {}
realestate = realestate or economies.realestate or {}
realestate.version = 1.00
realestate.modpath = minetest.get_modpath("realestate") .. DIR_DELIM

-- load configuraton
dofile(realestate.modpath .. "config.lua")

-- anything related to selling land
if economies.with_protection then
	dofile(realestate.modpath .. "landsale.lua")
	dofile(realestate.modpath .. "forsale_signs.lua")
end

-- protection mod support
if economies.with_landrush then
	dofile(realestate.modpath .. "implementations/landrush.lua")
end

if economies.with_areas then
	dofile(realestate.modpath .. "implementations/areas.lua")
end
