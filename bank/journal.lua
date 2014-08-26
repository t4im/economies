economy = economy or {}
economy.bank = economy.bank or {}

-- =============
-- Journal class
-- =============

local maxJournalSize = tonumber(economy.config:get("max_journal_size"))

economy.bank.Journal = {
	entries = {}
}

function economy.bank.Journal:new(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	return object
end

function economy.bank.Journal:reset() self.entries = {} end

function economy.bank.Journal:record(transaction)
	table.insert(self.entries, transaction)
	if #self.entries > maxJournalSize then
		table.remove(self.entries, 1) -- remove the oldest entry
	end
end

