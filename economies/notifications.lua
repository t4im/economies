local economies, core = economies, core

--
-- Player notification
--
function economies.notify(player, message, ...)
	local name = player:get_player_name()
	if (...) then message = message:format(...) end
	core.chat_send_player(name, message)
end

function economies.notifyAll(message, ...)
	if (...) then message = message:format(...) end
	core.chat_send_all(message)
end

function economies.notifyAny(condition, message, ...)
	if (...) then message = message:format(...) end
	for _, player in pairs(core.get_connected_players()) do
		if condition(player) then
			economies.notify(player, message)
		end
	end
end

--
-- Log notification
--

local logPrefix = ("[%s] "):format(core.get_current_modname())
function economies.logAction(message, ...)
	if (...) then message = message:format(...) end
	core.log("action", logPrefix .. message)
end
function economies.logDebug(message, ...)
	if (...) then message = message:format(...) end
	core.debug(logPrefix .. message)
end

--
-- Function feedback notification
--
-- takes the function call and sends any contained feedback (second result) to the named player
-- then returns the first result
--
function economies.feedbackTo(name, result, feedback)
	if feedback then core.chat_send_player(name, feedback) end
	return result
end

