local shell = require("shell")
local data = ...
for line in data:gmatch("[^\r\n]+") do
  line = line:match("^%s*(.-)%s*$") -- trim whitespace
  if line ~= "" then
    print("> " .. line)
    shell.execute(line)
  end
end
