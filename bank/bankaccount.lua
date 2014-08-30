economy = economy or {}
economy.bank = economy.bank or {}

-- =============
-- Account class
-- =============
 
economy.bank.Account = {
	name = nil, -- account id
	owner = nil,  -- account holder/owner
	balance = 0,
	-- reason of freezing or nil if not frozen
	frozen = nil,
	-- time of account creation (or import)
	created = nil,
	transient = nil,
}

function economy.bank.Account:new(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	self.__tostring = function (self) return self.name end
	self.name = object.name or object.owner
	return object
end

-- at this time owner and name are identical, but this might be changed in the future
function economy.bank.Account:getOwner() return self.owner or name end

function economy.bank.Account:printBalance() return economy.formatMoney(self.balance) end
-- return false if frozen with reason or true with 'nil' as reason
function economy.bank.Account:assertActive()	return not self.frozen, self.frozen end
-- either account or playerfile with money privilege must exist
function economy.bank.Account:exists() return (not self.transient) or minetest.get_player_privs(self:getOwner()).money end

function economy.bank.Account:describe()
	return string.format("'%s' with %s. Frozen: %s", self.name, self:printBalance(), self.frozen or "no")
end

function economy.bank.Account:assertSolvency(amount)
	if(amount > self.balance) then
		return false, string.format("Not enough funds. There is only %s available.", self:printBalance())
	end
	return true
end

function economy.bank.Account:set(amount)
	if not self:exists() then return false, "neither account nor player exist" end

	local amount, feedback = economy.sanitizeAmount(amount)
	if not amount then return false, feedback end

	self.balance = amount
	return self:save()
end

function economy.bank.Account:deposit(amount)
	if not self:exists() then return false, "neither account nor player exist" end

	local amount, feedback = economy.sanitizeAmount(amount)
	if not amount then return false, feedback end
	
	self.balance = self.balance + amount
	return self:save()
end

function economy.bank.Account:withdraw(amount)
	if not self:exists() then return false, "neither account nor player exist" end

	local amount, feedback = economy.sanitizeAmount(amount)
	if not amount then return false, feedback end

	local solvent, feedback = self:assertSolvency(amount)
	if not solvent then return solvent, feedback end

	self.balance = self.balance - amount
	return self:save()
end

function economy.bank.Account:freeze(reason)
	if not self:exists() then return false, "neither account nor player exist" end

	economy.logAction("freezing account %s for %s", self.name, reason)
	self.frozen = reason
	minetest.chat_send_player(self:getOwner(), "Your bankaccount has been frozen: " .. reason)
	return self:save()
end

function economy.bank.Account:unfreeze()
	if not self:exists() then return false, "neither account nor player exist" end
	economy.logAction("unfreezing account: " .. self.name)
	self.frozen = nil
	minetest.chat_send_player(self:getOwner(), "Your bankaccount has been unfrozen.")
	return self:save()
end

function economy.bank.Account:save()
	local path = accountFile(self.name)
	economy.logDebug("saving account %s to %s ", self.name, path)
	
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

local bankPath = minetest.get_worldpath() .. economy.config:get("bank_path") .. "/"
local accountFile = function(name) return bankPath .. name .. ".account" end

-- initial run to load indexed information and check our bank path exists at all during startup
function economy.bank.initBankPath()
	local input = io.open(bankPath .. ".index", "w")
	if(not input) then return false end
	io.close(input)
	return true
end
assert(economy.bank.initBankPath(), "Could not access the account location. Make sure you created the directory " .. bankPath)

function economy.bank.createAccount(name)
	local initialAmount = math.floor(economy.config:get("initial_amount"))
	economy.logDebug("creating account %s with %s", name, economy.formatMoney(initialAmount))
	return economy.bank.Account:new{name=name, balance=initialAmount, created=os.time(), transient=true, }
end

function economy.bank.loadAccount(name)
	local path = accountFile(name)

	local input = io.open(path, "r")
	if(not input) then return nil end

	economy.logDebug("loading account %s from %s", name, path)
	local account = minetest.deserialize(input:read("*all"))
	io.close(input)

	-- wrap it into a class
	account = economy.bank.Account:new(account)

	return account
end

function economy.bank.getAccount(name)
	if not name or name == "" then error("You must not pass nil or the empty string to getAccount.", 2) end
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
