local import_path = economy.config:get("import_path")
local import_type = economy.config:get("import_type")

-- imports simple "number in file" accounts as used by a handfull of other economic mods
local function importNIFAccount(name)
	local input = io.open(minetest.get_worldpath() .. import_path:format(name) , "r")
	if not input then return false end
	local balance = input:read("*n")
	io.close(output)
	return economy.bank.Account:new{name=name, balance=balance, created=os.time(), transient=true, }
end

-- imports from a passed table by common used table field names
local function importAccountTableEntry(name, entry)
	local balance = nil
	local frozen = nil

	if type(entry) == "number" then
		balance = entry
	elseif type(entry) == "table" then
		balance = entry.money
		frozen = entry.frozen
	end

	if not balance then -- fail if the most important expectation is not met
		return nil
	end

	return economy.bank.Account:new{name=name, balance=balance, created=os.time(), transient=true, frozen=frozen,}
end

-- imports accounts serialized into one big table
local function importBigTableAccount(name)
	local input = io.open(minetest.get_worldpath() .. import_path , "r")
	if not input then return false end
	local accounts =  minetest.deserialize(input:read("*all"))
	io.close(output)
	return importAccountTableEntry(name, accounts[name])
end

-- imports accounts serialized into one table per account
local function importBigTableAccount(name)
	local input = io.open(minetest.get_worldpath() .. import_path:format(name) , "r")
	if not input then return false end
	local accountTable =  minetest.deserialize(input:read("*all"))
	io.close(output)
	return importAccountTableEntry(name, accountTable)
end

function economy.bank.importAccount(name)
	if not import_path or not import_type then
		return nil
	end
	local account = nil
	if import_type == "nif" then
		account = importNIFAccount(name)
	elseif import_type == "bigtable" then
		account = importBigTableAccount(name)
	end

	if account then		
		minetest.log("info", string.format("[Bank] imported account %s with %s", name, economy.formatMoney(balance)))
		return account
	end
	return nil
end

