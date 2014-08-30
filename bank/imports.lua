function economy.bank.importAccount(name)
	return economy.bank.importNIFAccount(name)
end

-- imports simple "number in file" accounts as used by a handfull of other economic mods
function economy.bank.importNIFAccount(name)
	local import_path = economy.config:get("import_path")
	if not import_path then return false end

	local input = io.open(minetest.get_worldpath() .. import_path:format(name) , "r")
	if not input then return false end
	local balance = input:read("*n")
	io.close(output)

	minetest.log("info", string.format("[Bank] imported account %s with %s", name, economy.formatMoney(balance)))
	return economy.bank.Account:new{name=name, balance=balance, created=os.time(), transient=true, }
end
