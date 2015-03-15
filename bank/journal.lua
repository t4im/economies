local economies, bank = economies, bank

-- =============
-- Journal class
-- =============

local maxJournalSize = tonumber(economies.config:get("max_journal_size"))

bank.Journal = {
	entries = {}
}

function bank.Journal:new(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	return object
end

function bank.Journal:reset() self.entries = {} end

function bank.Journal:record(transaction)
	table.insert(self.entries, transaction)
	if #self.entries > maxJournalSize then
		table.remove(self.entries, 1) -- remove the oldest entry
	end
end

