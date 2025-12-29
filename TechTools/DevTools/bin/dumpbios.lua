local eeprom = require("component").eeprom
local img = require("LF-DevTools-OC"):getImgLib("oc-EEPROM1")
local f = io.open("./Bios.ocei", "w+")
img.bios = eeprom.get(),
img.data = eeprom.getData()
img.label = "[Dump]: " .. eeprom.getLabel()
f:write(img:generate())
f:flush()
f:close()