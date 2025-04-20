local eeprom = require("component").eeprom
f = io.open("bios.lua", "w")
f:write(eeprom.get())
f:flush()
f:close()