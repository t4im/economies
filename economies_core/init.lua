--
--
economies = economies or {}
economies.modpath = minetest.get_modpath("economies_core")

-- semantic versioning
economies.version = economies.version or {}
economies.version.major = 0
economies.version.minor = 0
economies.version.patch = 0

-- load configuration
dofile(economies.modpath.."/config.lua")

-- load utilties used by the economies mods
dofile(economies.modpath.."/notifications.lua")
