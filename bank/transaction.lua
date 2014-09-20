economies = economies or {}
economies.bank = economies.bank or {}

-- =================
-- economies.bank.Transaction class
-- =================

economies.bank.Transaction = {
	time = nil,
	subject = nil,
	location = nil,
	source = nil,
	target = nil,
	amount = nil,
	type = nil,
	initiator = nil
}

function economies.bank.Transaction:new(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	self.time = object.time or os.time()
	-- make sure we only save the names, not the objectref's, to avoid cycles during serialization
	self.source = tostring(object.source)
	self.target = tostring(object.target)
	return object
end

function economies.bank.Transaction:printDate(format) return os.date(format or "%Y-%m-%d %H:%M:%S", self.time) end
function economies.bank.Transaction:printAmount() return economies.formatMoney(self.amount) end

function economies.bank.Transaction:from() return economies.bank.getAccount(self.source) end
function economies.bank.Transaction:to() return economies.bank.getAccount(self.target) end

-- a different question as to from whome the transaction debits is:
-- who initated the transaction? might have been some admin enforcing it, or some process/mod/machine
-- if nil, the initiator is assumed to be the source
function economies.bank.Transaction:initiator() return self.initiator or self.source end

function economies.bank.Transaction:describe() return ("%s transfers %d (%s -> %s) %s"):format(self.initiator or "player", self.amount, self.source, self.target, self.subject or "-") end

function economies.bank.Transaction:type()
	if type then
		return type
	elseif not self.initiator or self.initiator == self.source then
		return "wire"
	elseif self.initiator == self.target then
		return "debit"
	end
	local privs = minetest.get_player_privs(self.initiator)
	if privs.money then
		if privs.bank_teller or privs.bank_admin then
			return "admin"
		end
		assert(not privs.money, "it appears " .. self.initiator .. " has managed to get a hold on money admin functionality without having the necessary privs")
	end
	return "unknown"
end

function economies.bank.Transaction:isPointless()
	if	-- transferring from noone
		not self.source or self.source == ""
		-- or transferring to noone
		or not self.target or self.target == ""
		-- or transferring to oneself
		or (self.source == self.target)
		-- or transferring nothing
		or self.amount == 0
	then -- it's indeed pretty pointless
		return true, "Successfully done nothing."
	end

	--else
	return false
end

function economies.bank.Transaction:isValid()
	local from, to = self:from(), self:to()
	if not from:exists() then return false, "source: neither account nor player exist" end
	if not to:exists() then return false, "target: neither account nor player exist" end

	local saneAmount, feedback = economies.sanitizeAmount(self.amount)
	if not saneAmount then return false, feedback end

	self.amount = saneAmount

	local solvent, feedback = from:assertSolvency(self.amount)
	if not solvent then return false, feedback end

	return true
end

function economies.bank.Transaction:isLegit()
	local from, to = self:from(), self:to()

	if self:type() == "admin" then
		return true
	end

	-- check if source is frozen
	if (from.frozen) then
		return false, "The originating account is currently frozen."
	-- check if target is frozen
	elseif (to.frozen) then
		return false, "The target account is currently frozen."
	end

	return true
end

function economies.bank.Transaction:check()
	local pointless, feedback = self:isPointless()
	if pointless then return false, feedback end

	local valid, feedback = self:isValid()
	if not valid then return false, feedback end

	local legit, feedback = self:isLegit()
	if not legit then return false, feedback end

	return true
end

function economies.bank.Transaction:commit()
	local good, feedback = self:check()
	if not good then
		return false, feedback
	end

	local from, to  = self:from(), self:to()
	local fromOwner, toOwner = from:getOwner(), to:getOwner()

	economies.logAction(self:describe())

	from.balance = from.balance - self.amount
	to.balance = to.balance + self.amount

	local amountString = economies.formatMoney(self.amount)
	local transactionType = self:type()
	fromOwner:notify("You paid %s to %s via %s transfer", amountString, toOwner.name, transactionType)

	if self.subject then
		toOwner:notify("%s paid you %s via %s transfer.\n" ..
				"Subject: %s", fromOwner.name, amountString, transactionType, self.subject)
	else
		toOwner:notify("%s paid you %s via %s transfer", fromOwner.name, amountString, transactionType)
	end

	return from:save() and to:save()
end
