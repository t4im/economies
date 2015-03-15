local economies, bank = economies, bank

local maxJournalSize = tonumber(economies.config:get("max_journal_size"))

-- =============
-- Journal class
-- =============
bank.Journal = {
	entries = nil,
	reset = function(self) self.entries = {} end,
	record = function(self, transaction)
		table.insert(self.entries, transaction)
		if #self.entries > maxJournalSize then
			table.remove(self.entries, 1) -- remove the oldest entry
		end
	end,
	new = function(self, object)
		object = object or {}
		setmetatable(object, self)
		self.__index = self
		self.entries = {}
		return object
	end,
}




