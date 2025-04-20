local tape = require('component').tape_drive
tape.stop()
tape.seek(-tape.getPosition())
tape.write(("\0"):rep(tape.getSize()))
tape.stop()
tape.seek(-tape.getSize())
local fn, label = ...
local f = io.open(fn, "r")
tape.write(f:read('*a'))
tape.setLabel("Tape Bios: " .. label)
f:flush()
f:close()