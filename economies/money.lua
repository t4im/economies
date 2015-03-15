local economies = economies

function economies.formatMoney(amount)
	return economies.config:get("currency_format"):format(amount)
end

-- processes and cleans a passed amount value with basic sanity checks
-- returns the resulting amount or nil if unsuccessful
function economies.sanitizeAmount(amount)
	-- first lets make sure we really have a number
	amount = tonumber(amount)
	if not amount then return nil, "Not a number" end

	-- make sure no one tries to set Pi amount of credits, or similar annoyances
	amount = math.ceil(amount)

	-- we generally don't allow operations on negative values
	if amount < 0 then
		return nil, "You must not pass a negative amount."
	end

	return amount
end
