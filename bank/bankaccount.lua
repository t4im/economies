local economies, bank, core = economies, bank, core

local accounts = {}
bank.accounts = accounts

local bankPath = core.get_worldpath() .. DIR_DELIM .. economies.config:get("bank_path") .. DIR_DELIM
local accountFile = function(name) return bankPath .. name .. ".account" end

-- =============
-- Account class
-- =============
bank.Account = {
	name = nil, -- account id
	owner = nil,  -- account holder/owner
	getOwner = function(self) return economies.Agent:new{name=self.owner or self.name} end,

	new = function(self, object)
		object = object or {}
		setmetatable(object, self)
		self.__index = self
		self.name = object.name or object.owner
		return object
	end,
	__tostring = function (self) return self.name end,
	describe = function(self)
		return string.format("'%s' with %s. Frozen: %s", self.name, self:printBalance(), self.frozen or "no")
	end,

	-- ===== Account balance/modification =====
	balance = 0,
	printBalance = function(self) return economies.formatMoney(self.balance) end,

	assertSolvency = function(self, amount)
		if amount > self.balance then
			return false, string.format("Not enough funds. There is only %s available.", self:printBalance())
		end
		return true
	end,
	set = function(self, amount)
		if not self:exists() then return false, "neither account nor player exist" end

		local amount, feedback = economies.sanitizeAmount(amount)
		if not amount then return false, feedback end

		self.balance = amount
		return self:save()
	end,
	deposit = function(self, amount)
		if not self:exists() then return false, "neither account nor player exist" end

		local amount, feedback = economies.sanitizeAmount(amount)
		if not amount then return false, feedback end
	
		self.balance = self.balance + amount
		return self:save()
	end,
	withdraw = function(self, amount)
		if not self:exists() then return false, "neither account nor player exist" end

		local amount, feedback = economies.sanitizeAmount(amount)
		if not amount then return false, feedback end

		local solvent, feedback = self:assertSolvency(amount)
		if not solvent then return solvent, feedback end

		self.balance = self.balance - amount
		return self:save()
	end,

	-- ===== Account freezing =====
	-- reason of freezing or nil if active
	frozen = nil,
	-- return false if frozen with reason or true with 'nil' as reason
	assertActive = function(self) return not self.frozen, self.frozen end,

	freeze = function(self, reason)
		if not self:exists() then return false, "neither account nor player exist" end

		economies.logAction("freezing account %s for %s", self.name, reason)
		self.frozen = reason
		self:getOwner():notify("Your bankaccount has been frozen: " .. reason)
		return self:save()
	end,
	unfreeze = function(self)
		if not self:exists() then return false, "neither account nor player exist" end
		economies.logAction("unfreezing account: " .. self.name)
		self.frozen = nil
		self:getOwner():notify("Your bankaccount has been unfrozen.")
		return self:save()
	end,

	-- ===== Account saving =====
	-- time of account creation (or import)
	created = nil,
	-- either account or playerfile with money privilege must exist
	transient = nil,
	exists = function(self) return (not self.transient) or core.get_player_privs(self.owner or self.name).money end,

	save = function(self)
		local path = accountFile(self.name)
		economies.logDebug("saving account %s to %s ", self.name, path)
	
		local output = io.open(path, "w")
		-- remove transient flag direclty before serializing
		self.transient = nil
		output:write(core.serialize(self))
		io.close(output)
	
		-- update cache
		accounts[self.name] = self
		return true
	end,
}

-- ==================
-- Account management
-- ==================

-- initial run to load indexed information and check our bank path exists at all during startup
function bank.initBankPath()
	local input = io.open(bankPath .. ".index", "w")
	if not input then return false end
	io.close(input)
	return true
end
assert(bank.initBankPath(), "Could not access the account location. Make sure you created the directory " .. bankPath)

function bank.createAccount(name)
	local initialAmount = math.floor(economies.config:get("initial_amount"))
	economies.logDebug("creating account %s with %s", name, economies.formatMoney(initialAmount))
	return bank.Account:new{name=name, balance=initialAmount, created=os.time(), transient=true, }
end

function bank.loadAccount(name)
	local path = accountFile(name)

	local input = io.open(path, "r")
	if not input then return nil end

	economies.logDebug("loading account %s from %s", name, path)
	local account = core.deserialize(input:read("*all"))
	io.close(input)

	-- wrap it into a class
	account = bank.Account:new(account)

	return account
end

function bank.getAccount(name)
	if not name or name == "" then error("You must not pass nil or the empty string to getAccount.", 2) end
	local account = accounts[name]
			or bank.loadAccount(name)
			or bank.importAccount(name)
			or bank.createAccount(name)
						
	-- cache the account in memory to avoid having to read it consecutively
	accounts[name] = account
	
	return account
end

-- remove the account from the cache, when the player leaves the game
-- (crashing will obviously empty it too \o/)
core.register_on_leaveplayer(function(player)
	accounts[player:get_player_name()] = nil
end)
