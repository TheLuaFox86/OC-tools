local sz = require("serialization")
local img = {
  type="OCEI (OpenComputers Virtual EEPROM Image V1)",
  bios = "",
  data = "",
  label = "Untitled Bios",
  generate = function(self)
    local buffer = sz.serialize({bios=self.bios, data=self.data, label=self.label})
    return buffer
  end,
  parse = function(self, txt)
    local tb = load("return " .. txt, "t")()
    self.bios = tb.bios
    self.data = tb.data
    self.label = tb.label
  end
  createProxy = function(self, _tb)
    local tb = _tb
    tb.set = function(data)
      self.bios = data
    end
    tb.setData = function(data)
      self.data = data
    end
    tb.setLabel = function(data)
      self.label = data
    end
    tb.get = function()
      return self.bios
    end
    tb.getData = function()
      return self.data
    end
    tb.getLabel = function()
      return self.label
    end
    return tb
  end
