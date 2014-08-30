--
-- configuration handling
--
-- use economy.conf in your worldpath to change any settings listed as defaults here
--
local defaults = {
	initial_amount = "0",
	currency_format = "%dcr",
	currency_name = "credit",
	bank_path = "/bank",
	-- formatstring. If set, load balance out of the file found via this configuration.
	-- path is expected relative to the world path
	-- Use %s for the playername.
	import_path = nil,
	-- the format to import from: 'nif' (number-in-file), 'bigtable'
	import_type = nil,
	max_journal_size = "5",
}

-- configuration slurping
economy.config = economy.config or Settings(minetest.get_worldpath().."/economy.conf")
local conf_table = economy.config:to_table()

for k, v in pairs(defaults) do
	if conf_table[k] == nil then economy.config:set(k, v) end
end

economy.debugging = conf_table["debug"] or minetest.setting_getbool("debug_mods")

-- optional dependency support
economy.with_plastic = minetest.get_modpath("homedecore") ~= nil
			or minetest.get_modpath("pipeworks") ~= nil -- defines plastic if homedecore is not available
economy.with_compressor = minetest.get_modpath("technic") ~= nil
