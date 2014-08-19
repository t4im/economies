--
-- Bankaccount framework
--

-- ======
-- Helper
-- ======

local accountFile = function(name)
	return minetest.get_worldpath() .. economy.config:get("bank_path") .. "/" .. name .. ".txt"
end

function economy.formatAmount(amount)
	local amountFormat = "%d%s"
	return amountFormat:format(amount, economy.config:get("currency_symbol"))
end

local formatAmount = economy.formatAmount

-- =============
-- Account class
-- =============
 
BankAccount = {
	balance = 0,
	frozen = false,
	owner = nil,
}

function BankAccount:new(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	return object
end

function BankAccount:set(amount)
	if(amount < 0) then
	-- error
	end
	amount = math.ceil(amount)
	
	self.balance = amount
end

function BankAccount:get()
	return self.balance or 0
end

function BankAccount:deposit(amount)
	amount = math.ceil(amount)
	if(amount < 0) then
	-- error
	end
	
	self.balance = self.balance + amount
end

function BankAccount:withdraw(amount)
	amount = math.ceil(amount)
	if(amount < 0) then
	-- error
	end

	self.balance = self.balance - amount
end

function BankAccount:transferTo(other, amount)
	amount = math.ceil(amount)
	if(amount < 0) then
	-- error
	end	
	if(amount > self.balance) then
	-- error
	end
	
	minetest.debug(string.format("Bank: transfering %s from %s to %s.", formatAmount(amount), self.owner, other.owner))
	self.balance = self.balance - amount
	other.balance = other.balance + amount
end

function BankAccount:freeze()
	minetest.debug("Bank: freezing account: " .. self:name())
	self.frozen = true
	minetest.chat_send_player(self.owner, "Your bankaccount has been frozen.")
end

function BankAccount:unfreeze()
	minetest.debug("Bank: unfreezing account: " .. self:name())
	self.frozen = false
	minetest.chat_send_player(self.owner, "Your bankaccount has been unfrozen.")
end

function BankAccount:isFrozen()
	return self.frozen or false
end

function BankAccount:name()
	return self.owner
end

function BankAccount:describe()
	return string.format("Account '%s' with %s. Status: %s", self:name(), formatAmount(self.balance), self:isFrozen() and "frozen" or "active")
end

function BankAccount:save()
	local name = self:name()
	local path = accountFile(name)
	minetest.debug(string.format("Bank: saving account %s to %s ", name, path))
	
	local output = io.open(path, "w")	
	output:write(minetest.serialize(self))
	io.close(output)
	
	-- update cache
	economy.bank.accounts[name] = self
end

-- ==================
-- Account management
-- ==================
economy.bank.accounts = economy.bank.accounts or {}

function economy.bank.createAccount(name)
	local initialAmount = math.floor(economy.config:get("initial_amount"))
	minetest.debug(string.format("Bank: creating account %s with %s", name, formatAmount(initialAmount)))
	return BankAccount:new{owner=name, balance=initialAmount}
end

function economy.bank.loadAccount(name)
	local path = accountFile(name)

	local input = io.open(path, "r")
	if(not input) then return nil end
	
	minetest.debug(string.format("Bank: loading account %s from %s", name, path))
	local account = minetest.deserialize(input:read("*all"))
	io.close(input)
	
	-- wrap it into a class
	account = BankAccount:new(account)
	
	minetest.debug("Bank: " .. account:describe())	
	return account
end

function economy.bank.getAccount(name)
	local account = economy.bank.accounts[name]
						or economy.bank.loadAccount(name)
						or economy.bank.createAccount(name)
						
	-- cache the account in memory to avoid having to read it consecutively
	economy.bank.accounts[name] = account
	
	return account
end