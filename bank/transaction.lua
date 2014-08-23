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

function Transaction:from() return economy.bank.getAccount(source) end
function Transaction:to() return economy.bank.getAccount(target) end

-- a different question as to from whome the transaction debits is:
-- who initated the transaction? might have been some admin enforcing it, or some process/mod/machine
-- if nil, the initiator is assumed to be the source
function Transaction:initiator() return initiator or source end

function Transaction:describe()
	local initiator_prefix = ""
	if initiator then initiator_prefix = initiator .. ": " end

	return string.format("transfer %d (%s%s -> %s) %s", amount, initiator_prefix, source, target, subject or "-")
end

