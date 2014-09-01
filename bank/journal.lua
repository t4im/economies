economies = economies or {}
economies.bank = economies.bank or {}

-- =============
-- Journal class
-- =============

local maxJournalSize = tonumber(economies.config:get("max_journal_size"))

economies.bank.Journal = {
	entries = {}
}

function economies.bank.Journal:new(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	return object
end

function economies.bank.Journal:reset() self.entries = {} end

function economies.bank.Journal:record(transaction)
	table.insert(self.entries, transaction)
	if #self.entries > maxJournalSize then
		table.remove(self.entries, 1) -- remove the oldest entry
	end
end

