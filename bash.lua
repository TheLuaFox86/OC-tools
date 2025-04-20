local shell = require("shell")
local mode, data = ...
if mode == "-c" then
for line in data:gmatch("[^\r\n]+") do
  line = line:match("^%s*(.-)%s*$") -- trim whitespace
  if line ~= "" then
    print("> " .. line)
    shell.execute(line)
  end
end
else
local data = ""
do
  local f = io.open(mode)
  data = f:read("*a")
  f:flush()
  f:close()
end
for line in data:gmatch("[^\r\n]+") do
  line = line:match("^%s*(.-)%s*$") -- trim whitespace
  if line ~= "" then
    print("> " .. line)
    shell.execute(line)
  end
end
end
