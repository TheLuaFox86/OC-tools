local tools = {
  paths={
    Lib = "/usr/lib/LF-DevKit-OC/",
    Data="/usr/LF-DevKit-OC/"
  }
}
function tools:getImgLib(name, ...)
  return (loadfile(self.paths.Lib .. "images/" .. name .. ".lua", "t") or loadfile(self.paths.Data .. "images/" .. name .. ".lua", "t"))(self, ...)
end
return tools