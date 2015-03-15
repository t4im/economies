local economies, core = economies, core

-- this privilege seem to be consistent over most other economic mods, so lets reuse them as well
core.register_privilege("money", "Can interact with money (e.g. buy/sell things, wire transfer)")
core.register_privilege("multiaccount_trading", "exempted from multiaccount trading preventions")

-- used for notifications of malicious behavior
function economies.isSupervisor(player)
	local name = player:get_player_name()
	local privs = core.get_player_privs(name)
	return privs.kick or privs.ban or privs.bank_teller
end

-- =============
-- Agent class
-- =============
 
economies.Agent = {
	name = nil,
	type = "player"
}

function economies.Agent:new(object)
	object = object or {}
	setmetatable(object, self)
	self.__index = self
	self.__tostring = function (self) return self.name end
	return object
end

function economies.Agent:asOnlinePlayer() return core.get_player_by_name(self.name) end
function economies.Agent:isAvailable() return self.type ~= "player" or core.get_player_by_name(self.name) end

function economies.Agent:notify(message, ...)
	if (...) then message = message:format(...) end
	if self.type == "player" then
		local player = self:asOnlinePlayer()
		if player then
			core.chat_send_player(self.name, message)
		else
			-- TODO support mod's that allow for offline messages
		end
	else
		economies.notifyAny(economies.isSupervisor, "@%s: %s", self.name, message)
	end
end

function economies.Agent:assertMayInit(transaction)
	-- only allow transactions with online players or other available agents to avoid
	-- * creating unnecessary accounts
	-- * lost money during transaction due to typos
	-- * transfers to alternative accounts without getting noticed
	-- * unnecessary disk i/o
	local toAgent = transaction:toAgent()
	if not toAgent:isAvailable() then
		self:notify("The target %s is currently unavailable.", toAgent.name)
		return false
	end

	-- check the amount is sane
	-- and that the accounts are not frozen
	-- before moving on to more consequential tests
	local good, feedback = transaction:check()
	if not good then
		self:notify(feedback or "Transaction failed")
		return false
	end

	-- if both players are from the same ip it might be a possible cheating attempt
	-- since we only accept transfers to online players, this is bound to be noticed
	if toAgent.type == "player"
			and core.get_player_ip(self.name) == core.get_player_ip(toAgent.name)
			and not (core.get_player_privs(self.name).multiaccount_trading
				and core.get_player_privs(toAgent.name).multiaccount_trading) then

		local type = transaction.getType()
		local formatedMoney = economies.formatMoney(amount)
		transaction:from():freeze(string.format("attempt of %s-transaction %s to %s, having the same ip address", type, formatedMoney, toAgent.name))
		transaction:to():freeze(string.format("target of %s-transaction attempt %s from %s, having the same ip address", type, formatedMoney, self.name))

		economies.notifyAny(economies.isSupervisor,
			"%s attempted %s-transaction with player of same ip-address: %s from %s to %s. The accounts were preventively frozen.",
			self.name, type, formatedMoney, transaction.source, transaction.target
		)
		self:notify("You tried to start a transaction with an accountholder that originates from the same network as you.\n" ..
			"To prevent potential abuse the transfer was denied and admins were notified."
		)
		return false
	end

	return true
end
