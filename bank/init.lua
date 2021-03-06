--
-- Banking accounts for players
-- allows storing and transferring funds between players
--
bank = {
	version = 1.00,
	modpath = core.get_modpath("bank") .. DIR_DELIM
}

-- load configuration
dofile(bank.modpath .. "config.lua")

-- load classes and related api
dofile(bank.modpath .. "bankaccount.lua")
dofile(bank.modpath .. "journal.lua")
dofile(bank.modpath .. "transaction.lua")

dofile(bank.modpath .. "imports.lua")

-- add operational code
dofile(bank.modpath .. "wiretransfer.lua")
dofile(bank.modpath .. "directdebit.lua")
dofile(bank.modpath .. "control.lua")

-- craftitems
--dofile(bank.modpath .. "cards.lua")
--dofile(bank.modpath .. "components.lua")

-- extra items and nodes
dofile(bank.modpath .. "atm.lua")

economies.bank = bank
