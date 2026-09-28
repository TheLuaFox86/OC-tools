--[[
This Tape Program allows you to play dfpwm files in the style of the legacy
Computronics Tape Drive
using the opencomputers rebooted Audio Card
VAC stands for Virtualized (by) Audio Card

--]]
local args = {...}
local shell = require("shell")
local decompress = require("libcodec-dfpwm")()
local audio = require("component").audio
local fs = require("filesystem")
if args[1] == "write" then
   os.setenv("TAPE_HANDLE", audio.open(0, tonumber(args[3]) or 48000, "mono8"))
   local file, err = fs.open(shell.resolve(args[2]), "rb")
	if not file then
   	 io.stderr:write("Failed to open file: " .. tostring(err) .. "\n")
  	    return
	end
	local handle = tonumber(os.getenv("TAPE_HANDLE"))
   local CHUNK = 512
	-- START playback immediately BEFORE sending blocks so the hardware buffer can drain correctly
	
	-- 1. Read and send the very first chunk to prime the hardware buffer
	local first_chunk = file:read(CHUNK)
	if first_chunk then
	    local ok, pcm = xpcall(decompress, debug.traceback, first_chunk)
	    if ok then
		audio.send(handle, pcm)
	    end
	end

	while true do
	    local chunk = file:read(CHUNK)
	    if not chunk then break end

	    local ok, pcm = xpcall(decompress, debug.traceback, chunk)
	    if not ok then
		io.stderr:write("Failed to decompress DFPWM: " .. tostring(pcm or "Unknown Error") .. "\n")
		file:close()
		return
	    end

	    -- Loop to safely throttle data backpressure so you don't slam the hardware buffer
	    while audio.send(handle, pcm) == false do
		os.sleep(0.05) -- Yield thread safely; gives card time to clear audio cycles
	    end
	end

	file:close()
elseif args[1] == "play" then
   print(tonumber(os.getenv("TAPE_HANDLE")))
	audio.play(tonumber(os.getenv("TAPE_HANDLE")))
	print("Tape Started")
elseif args[1] == "stop" then
   audio.stop(tonumber(os.getenv("TAPE_HANDLE")))
   print("taoe stopped")
end
