local fs = require("filesystem")
local io = require("io")
local compressor = {
  readBufferSize = 1024,
  ignoredFiles = {
    [".DS_Store"] = true
  }
}
local OCAFSignature = "OCAF"

local function numberToByteArray(number)
  local byteArray = {}
  repeat
    table.insert(byteArray, 1, number % 256)
    number = math.floor(number / 256)
  until number == 0
  return byteArray
end

local function byteArrayToNumber(byteArray)
  local number = 0
  for i = 1, #byteArray do
    number = number * 256 + byteArray[i]
  end
  return number
end

function compressor.pack(archivePath, fileList)
  if type(fileList) == "string" then
    fileList = {fileList}
  end
  local handle, reason = io.open(archivePath, "wb")
  if not handle then
    return false, "Failed to open archive file for writing: " .. tostring(reason)
  end

  handle:write(OCAFSignature)
  handle:write(string.char(0)) -- Encoding method placeholder

  local function doPack(list, localPath)
    for _, path in ipairs(list) do
      local name = fs.name(path)
      local currentLocalPath = localPath .. name
      if not compressor.ignoredFiles[name] then
        local isDir = fs.isDirectory(path)
        handle:write(string.char(isDir and 1 or 0))
        local pathBytes = {string.byte(currentLocalPath, 1, #currentLocalPath)}
        local pathLengthBytes = numberToByteArray(#pathBytes)
        handle:write(string.char(#pathLengthBytes))
        for _, b in ipairs(pathLengthBytes) do
          handle:write(string.char(b))
        end
        handle:write(currentLocalPath)
        if isDir then
          local newList = {}
          for file in fs.list(path) do
            table.insert(newList, fs.concat(path, file))
          end
          local success, err = doPack(newList, currentLocalPath)
          if not success then
            return false, err
          end
        else
          local fileHandle, err = io.open(path, "rb")
          if not fileHandle then
            return false, "Failed to open file for reading: " .. tostring(err)
          end
          local size = fs.size(path)
          local sizeBytes = numberToByteArray(size)
          handle:write(string.char(#sizeBytes))
          for _, b in ipairs(sizeBytes) do
            handle:write(string.char(b))
          end
          while true do
            local data = fileHandle:read(compressor.readBufferSize)
            if not data then break end
            handle:write(data)
          end
          fileHandle:close()
        end
      end
    end
    return true
  end

  local success, err = doPack(fileList, "")
  handle:close()
  return success, err
end

function compressor.unpack(archivePath, unpackPath)
  local handle, reason = io.open(archivePath, "rb")
  if not handle then
    return false, "Failed to open archive: " .. tostring(reason)
  end

  local function readBytes(n)
    local data = handle:read(n)
    if not data or #data < n then
      error("Unexpected end of archive or read error")
    end
    return data
  end

  -- Verify header
  local signature = readBytes(#OCAFSignature)
  if signature ~= OCAFSignature then
    handle:close()
    return false, "Invalid archive format"
  end

  readBytes(1) -- Skip encoding byte (not used)

  while true do
    local t = handle:read(1)
    if not t then break end -- EOF

    local isDir = t:byte() == 1

    local pathLenSize = readBytes(1):byte()
    local pathLen = byteArrayToNumber({string.byte(readBytes(pathLenSize), 1, pathLenSize)})
    local relPath = readBytes(pathLen)
    local absPath = fs.concat(unpackPath, relPath)

    if isDir then
      fs.makeDirectory(absPath)
    else
      local sizeLenSize = readBytes(1):byte()
      local size = byteArrayToNumber({string.byte(readBytes(sizeLenSize), 1, sizeLenSize)})

      -- Ensure parent directories exist
      local dir = absPath:match("(.+)/[^/]+$")
      if dir then fs.makeDirectory(dir) end

      local out, err = io.open(absPath, "wb")
      if not out then
        handle:close()
        return false, "Failed to create file: " .. tostring(err)
      end

      local remaining = size
      while remaining > 0 do
        local chunk = handle:read(math.min(remaining, compressor.readBufferSize))
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


return compressor
