local octoolsurl = "https://raw.githubusercontent.com/TheLuaFox86/OC-tools/main/"
local mainlistrepo = "https://github.com/TheLuaFox86/oc-music-list/raw/refs/heads/main/"
local bash = loadfile("/usr/bin/bash.lua", 't')
local files = require("ts-list")
local function playSong(url, tb)
    bash("-c", 'rm /tmp/song.dfpwm\nwget ' .. url .. "/" .. tb.path .. '-f ' .. "/tmp/song.dfpwm \n tape write /tmp/song.dfpwm -y \n tape label " .. string.format("%q", "TapeStrean: " .. tb.name .. "(by " .. tb.author s.. ")\ntape play"))
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
        if a[2] == "-update" then
            bash("-c", "echo \"Updating List\"\nwget " .. mainlistrepo ..  "list.lua -f /lib/ts-list.lua")
        else
            for i, v in ipairs(files) do
                print(i, v.name .. " By " .. v.author)
            end
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
    elseif a[1] == "pause" then
        bash("-c", "tape stop")
    elseif a[1] == "reaume" then
        bash("-c", "tape play")
    else
        print([[
            --Commands--
            list: Lists all available songs (if you want to update the list add -upgrade next to list)
            play: play a song usage: play <song: number or string>
            pause: pauses the tape
            resume: resumes the tape
            exit: exit out of TapeStream
        ]])
    end
end