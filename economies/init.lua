--
--
DIR_DELIM = DIR_DELIM or "/"
economies = economies or {}
economies.modpath = minetest.get_modpath("economies") .. DIR_DELIM

-- semantic versioning
economies.version = { major = 0, minor = 0, patch = 0 }

-- load configuration
dofile(economies.modpath .. "config.lua")

-- smartfs formspec framework
dofile(economies.modpath .. "smartfs.lua")

-- load generic classes
dofile(economies.modpath .. "agent.lua")

-- load utilties used by the economies mods
dofile(economies.modpath .. "money.lua")
dofile(economies.modpath .. "building_utilities.lua")
dofile(economies.modpath .. "notifications.lua")
