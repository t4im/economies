local economies = economies
--
-- configuration handling
--
-- use economies.conf in your worldpath to change any settings listed as defaults here
--

-- set up configuration slurping
economies.config = Settings(minetest.get_worldpath() .. DIR_DELIM .. "economies.conf")
function economies.register_config_defaults(defaults)
	local config = economies.config
	local config_table = config:to_table()
	for k, v in pairs(defaults) do
		if config_table[k] == nil then config:set(k, v) end
	end
end

-- register own config defaults
economies.register_config_defaults({
	debug = minetest.setting_getbool("debug_mods"),
	currency_format = "%dcr",
	currency_name = "credit",
})
