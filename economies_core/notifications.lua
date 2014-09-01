economies = economies or {}

--
-- Player notification
--
function economies.notify(player, message, ...)
	local name = player:get_player_name()
	if arg.n > 0
		then message = message:format(unpack(arg))
	end
	minetest.chat_send_player(name, message)
end

function economies.notifyAll(message, ...)
	if arg.n > 0 then
		message = message:format(unpack(arg))
	end
	minetest.chat_send_all(message)
end

function economies.notifyAny(condition, message, ...)
	if arg.n > 0 then
		message = message:format(unpack(arg))
	end
	for _,player in ipairs(minetest.get_connected_players()) do
		if condition(player) then
			economies.notify(player, message)
		end
	end
end

--
-- Log notification
--

local logPrefix = ("[%s] "):format(minetest.get_current_modname())
function economies.logAction(message, ...)
	if arg.n > 0 then
		message = message:format(unpack(arg))
	end
	minetest.log("action", logPrefix .. message)
end
function economies.logDebug(message, ...)
	if arg.n > 0 then
		message = message:format(unpack(arg))
	end
	minetest.debug(logPrefix .. message)
end
