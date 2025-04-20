local octoolsurl = "https://raw.githubusercontent.com/TheLuaFox86/OC-tools/main/"
local mainlistrepo = "https://raw.githubusercontent.com/TheLuaFox86/oc-music-list/main/"
local bash = loadfile("/bin/bash.lua", 't')
bash("-c", "wget " .. mainlistrepo ..  "list.lua -f /lib/ts-list.lua")
local files = require("ts-list")
bash('-c', [[
echo "Wellcome to opentapes"
echo "creating shortcut..."
]])
f = io.open('/bin/ts.lua', "w")
f:write("loadfile('/bin/bash.lua', 't')(" .. '"-c", ' .. "wget " .. octoolsurl .. "/tapestream.lua && " .. '"/home/tapestream.lua" && rm /home/tapestream.lua")')
f:flush()
f:close()
print("just type 'ts' to start tapestream\n dont worry tapestream is online")
local function playSong(url, name)
    bash("-c", 'wget ' .. url .. "/" .. name .. '.dfpwm -f ' .. "/tmp/song.dfpwm \n tape write /song.dfpwm -y \n tape play")
end
function cls()
    bash('-c', [[
cls
]])
end
function split_quoted(str)
    local result = {}
    for word in str:gmatch('%S+') do
        table.insert(result, word)
    end
    return result
end
local go = true
while go do
    local a = split_quoted(io.read("*Line"))
    local b = {}
    for i,v in ipairs(a) do
        b[i]=v
    end
    a = b
    if a[1] == "list" then
        for i, v in ipairs(files) do
            print(i, v)
        end
    elseif a[1] == 'play' then
        local b = a[2]
        if tonumber(a[2]) then
            for i,v in ipairs(files) do
                if tonumber(a[2]) == i then
                    b = v
                end
            end
        end
        playSong(mainlistrepo, b)
    elseif a[1] == "exit" then
        go = false
    else
        print([[
            --Commands--
            list: Lists all available songd
            play: play a song usage: play <song: number or string>
            exit: exit out of TapeStream
        ]])
    end
end