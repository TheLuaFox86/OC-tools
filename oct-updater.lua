local bash = loadfile("/bin/bash.lua")
print("Updating...")
bash("-c", "wget https://raw.githubusercontent.com/TheLuaFox86/OC-tools/refs/heads/main/update-config.lua /lib/updc.lua -f")
local url, tb = require("updc")
os.setenv("UURL", url)
for _, v in ipairs(tb) do
    bash("-c", v)
end
print("done!")