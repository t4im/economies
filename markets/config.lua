--
-- configuration handling
--
-- use economies.conf in your worldpath to change any settings listed as defaults here
--
local defaults = {
}

-- configuration slurping
economies.config = economies.config or Settings(minetest.get_worldpath()  .. DIR_DELIM .. "economies.conf")
local conf_table = economies.config:to_table()

for k, v in pairs(defaults) do
	if conf_table[k] == nil then economies.config:set(k, v) end
end

economies.debugging = conf_table["debug"] or minetest.setting_getbool("debug_mods")
