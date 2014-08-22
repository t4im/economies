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
	balance = 0,
	-- reason of freezing or nil if not frozen
	frozen = nil,
	owner = nil,
	transient = nil,
}

function BankAccount:new(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	return object
end

function BankAccount:name() return self.owner end
function BankAccount:printBalance() return economy.formatMoney(self.balance) end
-- return false if frozen with reason or true with 'nil' as reason
function BankAccount:assertActive()	return not self.frozen, self.frozen end

function BankAccount:describe()
	return string.format("'%s' with %s. Frozen: %s", self:name(), self:printBalance(), self.frozen or "no")
end

function BankAccount:assertSolvency(amount)
	if(amount > self.balance) then
		return false, string.format("Not enough funds. There is only %s available.", self:printBalance())
	end
	return true
end

function BankAccount:set(amount)
	local amount, feedback = economy.sanitizeAmount(amount)
	if not amount then return false, feedback end

	self.balance = amount
	return self:save()
end

function BankAccount:deposit(amount)
	local amount, feedback = economy.sanitizeAmount(amount)
	if not amount then return false, feedback end
	
	self.balance = self.balance + amount
	return self:save()
end

function BankAccount:withdraw(amount)
	local amount, feedback = economy.sanitizeAmount(amount)
	if not amount then return false, feedback end

	local solvent, feedback = self:assertSolvency(amount)
	if not solvent then return solvent, feedback end

	self.balance = self.balance - amount
	return self:save()
end

-- subject is optional
function BankAccount:transferTo(other, amount, subject)
	local amount, feedback = economy.sanitizeAmount(amount)
	if not amount then return false, feedback end

	-- transferring to oneself is always a neutral action
	if(self:name() == other:name()) then return end

	local solvent, feedback = self:assertSolvency(amount)
	if not solvent then return solvent, feedback end
	
	local amountString = economy.formatMoney(amount)

	minetest.log("action", string.format("[Bank] transfer: %d (%s -> %s) %s", amount, self.owner, other.owner, subject or ""))

	self.balance = self.balance - amount
	other.balance = other.balance + amount

	minetest.chat_send_player(self.owner, string.format("You paid %s to %s", amountString, other.owner))
	minetest.chat_send_player(other.owner, string.format("%s paid you %s", self.owner, amountString))

	if subject then
		minetest.chat_send_player(other.owner, "Subject: " .. subject)
	end

	return self:save() and other:save()
end

function BankAccount:freeze(reason)
	minetest.log("action", string.format("Bank: freezing account %s for %s", self:name(), reason))
	self.frozen = reason
	minetest.chat_send_player(self.owner, "Your bankaccount has been frozen: " .. reason)
	return self:save()
end

function BankAccount:unfreeze()
	minetest.log("action", "unfreezing account: " .. self:name())
	self.frozen = nil
	minetest.chat_send_player(self.owner, "Your bankaccount has been unfrozen.")
	return self:save()
end

function BankAccount:save()
	local name = self:name()
	local path = accountFile(name)
	minetest.debug(string.format("[Bank] saving account %s to %s ", name, path))
	
	local output = io.open(path, "w")
	-- remove transient flag direclty before serializing
	self.transient = nil
	output:write(minetest.serialize(self))
	io.close(output)
	
	-- update cache
	economy.bank.accounts[name] = self
	return true
end

-- ==================
-- Account management
-- ==================
economy.bank.accounts = economy.bank.accounts or {}

function economy.bank.createAccount(name)
	local initialAmount = math.floor(economy.config:get("initial_amount"))
	minetest.debug(string.format("[Bank] creating account %s with %s", name, economy.formatMoney(initialAmount)))
	return BankAccount:new{owner=name, balance=initialAmount, transient=true}
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
	return BankAccount:new{owner=name, balance=balance, transient=true}
end

function economy.bank.getAccount(name)
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
