--
-- Bankaccount framework
--

-- ======
-- Helper
-- ======

local accountFile = function(name)
	return minetest.get_worldpath() .. economy.config:get("bank_path") .. "/" .. name .. ".txt"
end

-- =============
-- Account class
-- =============
 
BankAccount = {
	name = nil, -- account id
	owner = nil,  -- account holder/owner
	balance = 0,
	-- reason of freezing or nil if not frozen
	frozen = nil,
	transient = nil,
}

function BankAccount:new(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	self.__tostring = function (self) return self.name end
	self.name = object.name or object.owner
	return object
end

-- at this time owner and name are identical, but this might be changed in the future
function BankAccount:getOwner() return self.owner or name end

function BankAccount:printBalance() return economy.formatMoney(self.balance) end
-- return false if frozen with reason or true with 'nil' as reason
function BankAccount:assertActive()	return not self.frozen, self.frozen end
-- either account or playerfile with money privilege must exist
function BankAccount:exists() return (not self.transient) or minetest.get_player_privs(self:getOwner()).money end

function BankAccount:describe()
	return string.format("'%s' with %s. Frozen: %s", self.name, self:printBalance(), self.frozen or "no")
end

function BankAccount:assertSolvency(amount)
	if(amount > self.balance) then
		return false, string.format("Not enough funds. There is only %s available.", self:printBalance())
	end
	return true
end

function BankAccount:set(amount)
	if not self:exists() then return false, "neither account nor player exist" end

	local amount, feedback = economy.sanitizeAmount(amount)
	if not amount then return false, feedback end

	self.balance = amount
	return self:save()
end

function BankAccount:deposit(amount)
	if not self:exists() then return false, "neither account nor player exist" end

	local amount, feedback = economy.sanitizeAmount(amount)
	if not amount then return false, feedback end
	
	self.balance = self.balance + amount
	return self:save()
end

function BankAccount:withdraw(amount)
	if not self:exists() then return false, "neither account nor player exist" end

	local amount, feedback = economy.sanitizeAmount(amount)
	if not amount then return false, feedback end

	local solvent, feedback = self:assertSolvency(amount)
	if not solvent then return solvent, feedback end

	self.balance = self.balance - amount
	return self:save()
end

function BankAccount:freeze(reason)
	if not self:exists() then return false, "neither account nor player exist" end

	minetest.log("action", string.format("Bank: freezing account %s for %s", self.name, reason))
	self.frozen = reason
	minetest.chat_send_player(self:getOwner(), "Your bankaccount has been frozen: " .. reason)
	return self:save()
end

function BankAccount:unfreeze()
	if not self:exists() then return false, "neither account nor player exist" end

	minetest.log("action", "unfreezing account: " .. self.name)
	self.frozen = nil
	minetest.chat_send_player(self:getOwner(), "Your bankaccount has been unfrozen.")
	return self:save()
end

function BankAccount:save()
	local path = accountFile(self.name)
	minetest.debug(string.format("[Bank] saving account %s to %s ", self.name, path))
	
	local output = io.open(path, "w")
	-- remove transient flag direclty before serializing
	self.transient = nil
	output:write(minetest.serialize(self))
	io.close(output)
	
	-- update cache
	economy.bank.accounts[self.name] = self
	return true
end

-- ==================
-- Account management
-- ==================
economy.bank.accounts = economy.bank.accounts or {}

function economy.bank.createAccount(name)
	local initialAmount = math.floor(economy.config:get("initial_amount"))
	minetest.debug(string.format("[Bank] creating account %s with %s", name, economy.formatMoney(initialAmount)))
	return BankAccount:new{name=name, balance=initialAmount, transient=true}
end

function economy.bank.loadAccount(name)
	local path = accountFile(name)

	local input = io.open(path, "r")
	if(not input) then return nil end

	minetest.debug(string.format("[Bank] loading account %s from %s", name, path))
	local account = minetest.deserialize(input:read("*all"))
	io.close(input)

	-- wrap it into a class
	account = BankAccount:new(account)

	return account
end

-- imports simple "number in file" accounts from other mods
function economy.bank.importAccount(name)
	local import_path = economy.config:get("import_path")
	if not import_path then return false end

	local input = io.open(minetest.get_worldpath() .. import_path:format(name) , "r")
	if not input then return false end
	local balance = input:read("*n")
	io.close(output)

	minetest.log("info", string.format("[Bank] imported account %s with %s", name, economy.formatMoney(balance)))
	return BankAccount:new{name=name, balance=balance, transient=true}
end

function economy.bank.getAccount(name)
	assert(name and name ~= "", "Eeek! Something tried to get no account.")
	local account = economy.bank.accounts[name]
						or economy.bank.loadAccount(name)
						or economy.bank.importAccount(name)
						or economy.bank.createAccount(name)
						
	-- cache the account in memory to avoid having to read it consecutively
	economy.bank.accounts[name] = account
	
	return account
end

-- remove the account from the cache, when the player leaves the game
-- (crashing will obviously empty it too \o/)
minetest.register_on_leaveplayer(function(player)
	economy.bank.accounts[player:get_player_name()] = nil
end)
