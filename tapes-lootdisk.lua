print("bash must be installed")
loadfile("/bin/bash.lua", "t")([[
wget https://raw.githubusercontent.com/TheLuaFox86/OC-tools/main/init.lua tapeloader-bios.lua -f
mkdir bin
wget https://raw.githubusercontent.com/TheLuaFox86/OC-tools/main/write.lua bin/tbWrite.lua -f
wget https://raw.githubusercontent.com/TheLuaFox86/OC-tools/main/read.lua bin/tbRead.lua -f
wget https://raw.githubusercontent.com/TheLuaFox86/OC-tools/main/dumpbios.lua bin/dumpbios.lua -f
wget https://raw.githubusercontent.com/TheLuaFox86/OC-tools/main/lootdisk-prop.lua .prop -f
]])
