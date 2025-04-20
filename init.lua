computer.beep(200, 1)
local tape = component.proxy(component.list('tape_drive')())
local data = ''
tape.stop()
tape.seek(-tape.getPosition())
do
  local dat = tape.read(4096)
  data = dat:gsub('\0+$', '')
  data = data:sub(1, #data)
end
local ok, err = load(data, '=tapeBios')
if not ok then
  error("Failed To Load Tape Script: " .. tostring(err))
end
return ok()