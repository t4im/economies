economies = economies or {}

-- =============
-- Agent class
-- =============
 
economies.Agent = {
	name = nil
}

function economies.Agent:new(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	self.__tostring = function (self) return self.name end
	return object
end

function economies.Agent:getRef() return minetest.get_player_by_name(self.name) end
function economies.Agent:isOnline() return minetest.get_player_by_name(self.name) end

function economies.Agent:notify(message, ...)
	if arg.n > 0
		then message = message:format(unpack(arg))
	end
	minetest.chat_send_player(self.name, message)
end

function economies.Agent:assertMayInit(transaction)
	-- first check the amount is sane
	-- and that the accounts are not frozen
	-- before moving on to more consequential tests
	local good, feedback = transaction:check()
	if not good then
		self:notify(feedback or "Transaction failed")
		return false
	end

	-- only allow transactions with online players to avoid
	-- * creating unnecessary accounts
	-- * lost money during transaction due to typos
	-- * transfers to alternative accounts without getting noticed
	local targetPlayer = self:getRef()
	if (not targetPlayer) then
		self:notify(transaction.target .. " is currently offline.")
		return false
	end

	-- if both players are from the same ip it might be a possible cheating attempt
	-- since we only accept transfers to online players, this is bound to be noticed
	if minetest.get_player_ip(self.name) == minetest.get_player_ip(other) then
		transaction:from():freeze(string.format("attempt to transfer %s to %s, having the same ip address", economies.formatMoney(amount), to))
		transaction:to():freeze(string.format("target of an attempt to transfer %s from %s, having the same ip address", economies.formatMoney(amount), from))

		economies.notifyAny(economies.bank.isSupervisor,
			"%s tried to transfer %s to %s. Both clients are connected from the same IP address. The Accounts were preventively frozen.",
			from, economies.formatMoney(amount), to
		)
		self:notify(from,
			"You tried to transfer money to an account that originates from the same network as you.\n" ..
			"To prevent potential abuse the transfer was denied and admins were notified."
		)
		return false
	end

	return true
end
