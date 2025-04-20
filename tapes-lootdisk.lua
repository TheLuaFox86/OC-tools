print("bash must be installed")
loadfile("/bin/bash.lua", "t")([[
wget raw.githubusercontent.com/TheLuFox86/OC-tools/main/init.lua tapeloader-bios.lua
mkdir bin
wget raw.githubusercontent.com/TheLuFox86/OC-tools/main/write.lua bin/tbWrite.lua
wget raw.githubusercontent.com/TheLuFox86/OC-tools/main/read.lua bin/tbRead.lua
wget raw.githubusercontent.com/TheLuFox86/OC-tools/main/dumpbios.lua bin/dumpbios.lua
wget raw.githubusercontent.com/TheLuFox86/OC-tools/main/lootdisk-prop.lua .prop
]])
