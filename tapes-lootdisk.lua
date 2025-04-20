print("bash must be installed")
loadfile("/bin/bash.lua", "t")([[
wget https://raw.githubusercontent.com/TheLuFox86/OC-tools/main/init.lua tapeloader-bios.lua
mkdir bin
wget https://raw.githubusercontent.com/TheLuFox86/OC-tools/main/write.lua bin/tbWrite.lua
wget https://raw.githubusercontent.com/TheLuFox86/OC-tools/main/read.lua bin/tbRead.lua
wget https://raw.githubusercontent.com/TheLuFox86/OC-tools/main/dumpbios.lua bin/dumpbios.lua
wget https://raw.githubusercontent.com/TheLuFox86/OC-tools/main/lootdisk-prop.lua .prop
]])
