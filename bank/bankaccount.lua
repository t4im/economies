economies = economies or {}
economies.bank = economies.bank or {}

-- =============
-- Account class
-- =============
 
economies.bank.Account = {
	name = nil, -- account id
	owner = nil,  -- account holder/owner
	balance = 0,
	-- reason of freezing or nil if not frozen
	frozen = nil,
	-- time of account creation (or import)
	created = nil,
	transient = nil,
}

function economies.bank.Account:new(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	self.__tostring = function (self) return self.name end
	self.name = object.name or object.owner
	return object
end

-- at this time owner and name are identical, but this might be changed in the future
function economies.bank.Account:getOwner() return self.owner or name end

function economies.bank.Account:printBalance() return economies.formatMoney(self.balance) end
-- return false if frozen with reason or true with 'nil' as reason
function economies.bank.Account:assertActive()	return not self.frozen, self.frozen end
-- either account or playerfile with money privilege must exist
function economies.bank.Account:exists() return (not self.transient) or minetest.get_player_privs(self:getOwner()).money end

function economies.bank.Account:describe()
	return string.format("'%s' with %s. Frozen: %s", self.name, self:printBalance(), self.frozen or "no")
end

function economies.bank.Account:assertSolvency(amount)
	if(amount > self.balance) then
		return false, string.format("Not enough funds. There is only %s available.", self:printBalance())
	end
	return true
end

function economies.bank.Account:set(amount)
	if not self:exists() then return false, "neither account nor player exist" end

	local amount, feedback = economies.sanitizeAmount(amount)
	if not amount then return false, feedback end

	self.balance = amount
	return self:save()
end

function economies.bank.Account:deposit(amount)
	if not self:exists() then return false, "neither account nor player exist" end

	local amount, feedback = economies.sanitizeAmount(amount)
	if not amount then return false, feedback end
	
	self.balance = self.balance + amount
	return self:save()
end

function economies.bank.Account:withdraw(amount)
	if not self:exists() then return false, "neither account nor player exist" end

	local amount, feedback = economies.sanitizeAmount(amount)
	if not amount then return false, feedback end

	local solvent, feedback = self:assertSolvency(amount)
	if not solvent then return solvent, feedback end

	self.balance = self.balance - amount
	return self:save()
end

function economies.bank.Account:freeze(reason)
	if not self:exists() then return false, "neither account nor player exist" end

	economies.logAction("freezing account %s for %s", self.name, reason)
	self.frozen = reason
	minetest.chat_send_player(self:getOwner(), "Your bankaccount has been frozen: " .. reason)
	return self:save()
end

function economies.bank.Account:unfreeze()
	if not self:exists() then return false, "neither account nor player exist" end
	economies.logAction("unfreezing account: " .. self.name)
	self.frozen = nil
	minetest.chat_send_player(self:getOwner(), "Your bankaccount has been unfrozen.")
	return self:save()
end

function economies.bank.Account:save()
	local path = accountFile(self.name)
	economies.logDebug("saving account %s to %s ", self.name, path)
	
	local output = io.open(path, "w")
	-- remove transient flag direclty before serializing
	self.transient = nil
	output:write(minetest.serialize(self))
	io.close(output)
	
	-- update cache
	economies.bank.accounts[self.name] = self
	return true
end

-- ==================
-- Account management
-- ==================
economies.bank.accounts = economies.bank.accounts or {}

local bankPath = minetest.get_worldpath() .. economies.config:get("bank_path") .. "/"
local accountFile = function(name) return bankPath .. name .. ".account" end

-- initial run to load indexed information and check our bank path exists at all during startup
function economies.bank.initBankPath()
	local input = io.open(bankPath .. ".index", "w")
	if(not input) then return false end
	io.close(input)
	return true
end
assert(economies.bank.initBankPath(), "Could not access the account location. Make sure you created the directory " .. bankPath)

function economies.bank.createAccount(name)
	local initialAmount = math.floor(economies.config:get("initial_amount"))
	economies.logDebug("creating account %s with %s", name, economies.formatMoney(initialAmount))
	return economies.bank.Account:new{name=name, balance=initialAmount, created=os.time(), transient=true, }
end

function economies.bank.loadAccount(name)
	local path = accountFile(name)

	local input = io.open(path, "r")
	if(not input) then return nil end

	economies.logDebug("loading account %s from %s", name, path)
	local account = minetest.deserialize(input:read("*all"))
	io.close(input)

	-- wrap it into a class
	account = economies.bank.Account:new(account)

	return account
end

function economies.bank.getAccount(name)
	if not name or name == "" then error("You must not pass nil or the empty string to getAccount.", 2) end
	local account = economies.bank.accounts[name]
						or economies.bank.loadAccount(name)
						or economies.bank.importAccount(name)
						or economies.bank.createAccount(name)
						
	-- cache the account in memory to avoid having to read it consecutively
	economies.bank.accounts[name] = account
	
	return account
end

-- remove the account from the cache, when the player leaves the game
-- (crashing will obviously empty it too \o/)
minetest.register_on_leaveplayer(function(player)
	economies.bank.accounts[player:get_player_name()] = nil
end)
