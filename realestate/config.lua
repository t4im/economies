--
-- configuration handling
--
-- use economy.conf in your worldpath to change any settings listed as defaults here
--
local defaults = {
}

-- configuration slurping
economy.config = economy.config or Settings(minetest.get_worldpath().."/economy.conf")
local conf_table = economy.config:to_table()

for k, v in pairs(defaults) do
	if conf_table[k] == nil then economy.config:set(k, v) end
end

economy.debug = conf_table["debug"] or minetest.setting_getbool("debug_mods")
