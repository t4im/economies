--
-- configuration handling
--
-- use economies.conf in your worldpath to change any settings listed as defaults here
--
economies.register_config_defaults({
	initial_amount = "0",
	bank_path = "bank",
	-- formatstring. If set, load balance out of the file found via this configuration.
	-- path is expected relative to the world path
	-- Use %s for the playername.
	import_path = nil,
	-- the format to import from:
	-- 'nif' (number-in-file) for accounts stored in one file per account with just a number in it
	-- 'table' for accounts stored in one table in a file per account
	-- 'bigtable' for accounts stored in one big table, containing all accounts
	import_type = nil,
	max_journal_size = "5",
})

-- optional dependency support
economies.with_plastic = minetest.get_modpath("homedecor") ~= nil
			or minetest.get_modpath("pipeworks") ~= nil -- defines plastic if homedecor is not available
economies.with_compressor = minetest.get_modpath("technic") ~= nil
