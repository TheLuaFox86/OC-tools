local shell = require("shell")
local fs = require("filesystem")
local compressor = require("Compressor")

local args = {...}
local verbose = false

-- Parse and remove --verbose if present
for i = #args, 1, -1 do
  if args[i] == "--verbose" then
    verbose = true
    table.remove(args, i)
    break
  end
end

local function usage()
  print("Usage:")
  print("  unpack <archive_path> <target_directory> [--verbose]")
end

if #args < 2 then
  usage()
  return
end

local archivePath = shell.resolve(args[1])
local targetDir = shell.resolve(args[2])

if not fs.exists(archivePath) then
  print("Error: Archive file not found.")
  return
end

-- Override unpack method to include verbose printing
local original_unpack = compressor.unpack
compressor.unpack = function(path, target)
  local handle, reason = io.open(path, "rb")
  if not handle then return false, "Cannot open archive: " .. tostring(reason) end

  local function readBytes(n)
    local data = handle:read(n)
    if not data or #data < n then error("Unexpected end of archive") end
    return data
  end

  local signature = readBytes(4)
  if signature ~= "OCAF" then
    handle:close()
    return false, "Invalid archive format"
  end
  readBytes(1) -- Skip encoding

  while true do
    local t = handle:read(1)
    if not t then break end -- EOF
    local isDir = t:byte() == 1

    local pathLenSize = readBytes(1):byte()
    local pathLen = 0
    for i = 1, pathLenSize do
      pathLen = pathLen * 256 + readBytes(1):byte()
    end

    local relPath = readBytes(pathLen)
    local absPath = fs.concat(target, relPath)
    if verbose then
      print((isDir and "Creating dir:" or "Extracting file:"), absPath)
    end

    if isDir then
      fs.makeDirectory(absPath)
    else
      local sizeLen = readBytes(1):byte()
      local fileSize = 0
      for i = 1, sizeLen do
        fileSize = fileSize * 256 + readBytes(1):byte()
      end

      local dir = absPath:match("(.+)/[^/]+$")
      if dir then fs.makeDirectory(dir) end

      local out = io.open(absPath, "wb")
      local remaining = fileSize
      while remaining > 0 do
        local chunk = handle:read(math.min(remaining, 8192))
        if not chunk then break end
        out:write(chunk)
        remaining = remaining - #chunk
      end
      out:close()
    end
  end

  handle:close()
  return true
end

-- Run unpack
local success, err = compressor.unpack(archivePath, targetDir)
if success then
  print("Unpacking complete to: " .. targetDir)
else
  print("Error unpacking: " .. tostring(err))
end
