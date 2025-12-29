local a = table.pack(...)
local bool = load("a = table.pack(...)\n return a[1] " .. a[2] .. " a[2]", "=bool", "t")(a[1], a[3])
if bool then
    loadfile("/bin/bash.lua", "t")(a[4], a[5])
end