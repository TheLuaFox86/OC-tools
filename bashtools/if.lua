local a = table.pack(...)
local bool = load("a = table.pack(...)\n return a[1] " .. a[3] .. " a[2]")(a[2], a[4])
if bool then
    bash(a[5], a[6])
end