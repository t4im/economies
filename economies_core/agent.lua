economies = economies or {}

-- this privilege seem to be consistent over most other economic mods, so lets reuse them as well
minetest.register_privilege("money", "Can interact with money (e.g. buy/sell things, wire transfer)")

minetest.register_privilege("multiaccount_trading", "exempted from multiaccount trading preventions")

-- used for notifications of malicious behavior
function economies.isSupervisor(player)
	local name = player:get_player_name()
	local privs = minetest.get_player_privs(name)
	return privs.kick or privs.ban or privs.bank_teller
end

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
	local targetPlayer = transaction:to():getOwner()
	if (not targetPlayer:isOnline()) then
		self:notify(targetPlayer.name .. " is currently offline.")
		return false
	end

	-- if both players are from the same ip it might be a possible cheating attempt
	-- since we only accept transfers to online players, this is bound to be noticed
	if minetest.get_player_ip(self.name) == minetest.get_player_ip(targetPlayer.name) and
			not (minetest.get_player_privs(self.name).multiaccount_trading
			and minetest.get_player_privs(targetPlayer.name).multiaccount_trading) then

		local type = transaction.getType()
		transaction:from():freeze(string.format("attempt of %s-transaction %s to %s, having the same ip address", type, economies.formatMoney(amount), to))
		transaction:to():freeze(string.format("target of %s-transaction attempt %s from %s, having the same ip address", type, economies.formatMoney(amount), from))

		economies.notifyAny(economies.isSupervisor,
			"%s attempted %s-transaction with player of same ip-address: %s from %s to %s. The accounts were preventively frozen.",
			self.name, type, economies.formatMoney(amount), from, to
		)
		self:notify("You tried to start a transaction with an accountholder that originates from the same network as you.\n" ..
			"To prevent potential abuse the transfer was denied and admins were notified."
		)
		return false
	end

	return true
end
