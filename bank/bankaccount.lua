--
-- Bankaccount framework
--

-- ======
-- Helper
-- ======

local accountFile = function(name)
	return minetest.get_worldpath() .. economy.config:get("bank_path") .. "/" .. name .. ".txt"
end

-- processes a passed amount value
-- returns the resulting amount or nil if unsuccessful
local processAmount = function(amount)
	-- first lets make sure we really have a number
	amount = tonumber(amount)
	if not amount then return nil, "Not a number" end

	-- make sure no one tries to set Pi amount of credits, or similar annoyances
	amount = math.ceil(amount)

	-- ignore any neutral operations
	if(amount == 0) then return nil, "Successfully done nothing" end

	-- we generally don't allow operations on negative values
	if(amount < 0) then
		return nil, "You must not pass a negative amount."
	end

	return amount
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

function BankAccount:name() return self.owner end
function BankAccount:getBalance() return self.balance or 0 end
function BankAccount:printBalance() return economy.formatMoney(self.balance) end
function BankAccount:isFrozen() return self.frozen or false end
function BankAccount:printStatus() return (self:isFrozen() and "frozen" or "active") end

function BankAccount:describe()
	return string.format("Account '%s' with %s. Status: %s", self:name(), self:printBalance(), self:printStatus())
end

function BankAccount:assertSolvency(amount)
	if(amount > self.balance) then
		return false, string.format("Not enough funds. There is only %s available.", self:printBalance())
	end
	return true
end

function BankAccount:assertActive()
	if (self:isFrozen()) then
		return false, "Account is frozen."
	end
	return true
end

function BankAccount:set(amount)
	local amount, feedback = processAmount(amount)
	if not amount then return false, feedback end

	self.balance = amount
	return self:save()
end

function BankAccount:deposit(amount)
	local amount, feedback = processAmount(amount)
	if not amount then return false, feedback end
	
	self.balance = self.balance + amount
	return self:save()
end

function BankAccount:withdraw(amount)
	local amount, feedback = processAmount(amount)
	if not amount then return false, feedback end

	local solvent, feedback = self:assertSolvency(amount)
	if not solvent then return solvent, feedback end

	self.balance = self.balance - amount
	return self:save()
end

function BankAccount:transferTo(other, amount)
	local amount, feedback = processAmount(amount)
	if not amount then return false, feedback end

	-- transferring to oneself is always a neutral action
	if(self:name() == other:name()) then return end

	local solvent, feedback = self:assertSolvency(amount)
	if not solvent then return solvent, feedback end
	
	local amountString = economy.formatMoney(amount)

	minetest.debug(string.format("Bank: transferring %s from %s to %s.", economy.formatMoney(amount), self.owner, other.owner))

	self.balance = self.balance - amount
	other.balance = other.balance + amount

	minetest.chat_send_player(self.owner, string.format("You paid %s to %s", amountString, other.owner))
	minetest.chat_send_player(other.owner, string.format("%s paid you %s", self.owner, amountString))

	return self:save() and other:save()
end

function BankAccount:freeze()
	minetest.debug("Bank: freezing account: " .. self:name())
	self.frozen = true
	minetest.chat_send_player(self.owner, "Your bankaccount has been frozen.")
	return self:save()
end

function BankAccount:unfreeze()
	minetest.debug("Bank: unfreezing account: " .. self:name())
	self.frozen = false
	minetest.chat_send_player(self.owner, "Your bankaccount has been unfrozen.")
	return self:save()
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
	return true
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