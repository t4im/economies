economy = economy or {}
economy.bank = economy.bank or {}

-- =================
-- Transaction class
-- =================

Transaction = {
	time = nil,
	subject = nil,
	location = nil,
	source = nil,
	target = nil,
	amount = nil,
	initiator = nil
}

function Transaction:new(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	self.time = object.time or os.time()
	-- make sure we only save the names, not the objectref's, to avoid cycles during serialization
	self.source = tostring(object.source)
	self.target = tostring(object.target)
	return object
end

function Transaction:printDate(format) return os.date(format or "%Y-%m-%d %H:%M:%S", self.time) end
function Transaction:printAmount() return economy.formatMoney(self.amount) end

function Transaction:from() return economy.bank.getAccount(self.source) end
function Transaction:to() return economy.bank.getAccount(self.target) end

-- a different question as to from whome the transaction debits is:
-- who initated the transaction? might have been some admin enforcing it, or some process/mod/machine
-- if nil, the initiator is assumed to be the source
function Transaction:initiator() return self.initiator or self.source end

function Transaction:describe()
	local initiator_prefix = ""
	if self.initiator then initiator_prefix = self.initiator .. ": " end

	return string.format("transfer %d (%s%s -> %s) %s", self.amount, initiator_prefix, self.source, self.target, self.subject or "-")
end

function Transaction:isPointless()
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

function Transaction:isValid()
	local from, to = self:from(), self:to()
	if not from:exists() then return false, "source: neither account nor player exist" end
	if not to:exists() then return false, "target: neither account nor player exist" end

	local saneAmount, feedback = economy.sanitizeAmount(self.amount)
	if not saneAmount then return false, feedback end

	self.amount = saneAmount

	local solvent, feedback = from:assertSolvency(self.amount)
	if not solvent then return false, feedback end

	return true
end

function Transaction:isLegit()
	local from, to = self:from(), self:to()

	-- check if source is frozen
	if (from.frozen) then
		return false, "The originating account is currently frozen."
	-- check if target is frozen
	elseif (to.frozen) then
		return false, "The target account is currently frozen."
	end

	return true
end

function Transaction:check()
	local pointless, feedback = self:isPointless()
	if pointless then return false, feedback end

	local valid, feedback = self:isValid()
	if not valid then return false, feedback end

	local legit, feedback = self:isLegit()
	if not legit then return false, feedback end

	return true
end

function Transaction:commit()
	local good, feedback = self:check()
	if not good then
		return false, feedback
	end

	local from, to  = self:from(), self:to()
	minetest.log("action", "[Bank] " .. self:describe())

	from.balance = from.balance - self.amount
	to.balance = to.balance + self.amount

	local amountString = economy.formatMoney(self.amount)
	minetest.chat_send_player(from.owner, string.format("You paid %s to %s", amountString, to.owner))
	minetest.chat_send_player(to.owner, string.format("%s paid you %s", from.owner, amountString))
	if self.subject then
		minetest.chat_send_player(to.owner, "Subject: " .. self.subject)
	end

	return from:save() and to:save()
end

function Transaction:checkAndCommit()
	local good, feedback = self:check()
	if not good then return false, feedback end
	return self:commit()
end
