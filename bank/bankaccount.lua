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
	frozen = false,
	owner = nil,
}

function BankAccount:new(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	return object
end

function BankAccount:rejectAction(actor, message)
		if(actor) then
			minetest.chat_send_player(actor, message)
		else
			minetest.log("error", string.filter("[Bank] (%s, %s) %s", message))
		end
end

function BankAccount:set(actor, amount)
	-- make sure no one tries to set Pi amount of credits, or similar annoyances
	amount = math.ceil(amount)

	if(amount < 0) then
		self:rejectAction(actor, "You cannot set a negative balance.")
		return
	end

	self.balance = amount
	self:save()
end

function BankAccount:getBalance()
	return self.balance or 0
end

function BankAccount:deposit(actor, amount)
	amount = math.ceil(amount)
	if(amount < 0) then
		self:rejectAction(actor, "You cannot deposit a negative amount.")
		return
	end
	
	self.balance = self.balance + amount
	self:save()
end

function BankAccount:withdraw(actor, amount)
	amount = math.ceil(amount)
	if(amount < 0) then
		self:rejectAction(actor, "You cannot withdraw a negative amount.")
		return
	end
	if(amount > self.balance) then
		self:rejectAction(actor, string.filter("Not enough funds. You cannot withdraw more than %s from this account.", economy.formatMoney(amount)))		
		return
	end

	self.balance = self.balance - amount
	self:save()
end

function BankAccount:transferTo(actor, other, amount)
	amount = math.ceil(amount)
	if(amount < 0) then
		self:rejectAction(actor, "You cannot transfer a negative amount.")
		return
	end
	if(amount > self.balance) then
		self:rejectAction(actor, string.filter("Not enough funds. You cannot transfer more than %s from this account.", economy.formatMoney(amount)))		
		return
	end
	
	minetest.debug(string.format("Bank: transfering %s from %s to %s.", economy.formatMoney(amount), self.owner, other.owner))
	self.balance = self.balance - amount
	other.balance = other.balance + amount
	self:save()
	other:save()
end

function BankAccount:freeze()
	minetest.debug("Bank: freezing account: " .. self:name())
	self.frozen = true
	self:save()
	minetest.chat_send_player(self.owner, "Your bankaccount has been frozen.")
end

function BankAccount:unfreeze()
	minetest.debug("Bank: unfreezing account: " .. self:name())
	self.frozen = false
	self:save()
	minetest.chat_send_player(self.owner, "Your bankaccount has been unfrozen.")
end

function BankAccount:isFrozen()
	return self.frozen or false
end

function BankAccount:name()
	return self.owner
end

function BankAccount:describe()
	return string.format("Account '%s' with %s. Status: %s", self:name(), economy.formatMoney(self.balance), self:isFrozen() and "frozen" or "active")
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
	minetest.debug(string.format("Bank: creating account %s with %s", name, economy.formatMoney(initialAmount)))
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

-- remove the account from the cache, when the player leaves the game
-- (crashing will obviously empty it too \o/)
minetest.register_on_leaveplayer(function(player)
	economy.bank.accounts[player:get_player_name()] = nil
end)