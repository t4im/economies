--
-- Banking accounts for players
-- allows storing and transferring funds between players
--
DIR_DELIM = DIR_DELIM or "/"
economies = economies or {}
bank = bank or economies.bank or {}
bank.version = 1.00
bank.modpath = minetest.get_modpath("bank") .. DIR_DELIM

-- load configuration
dofile(bank.modpath .. "config.lua")
-- common helper functions
dofile(bank.modpath .. "common.lua")

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
