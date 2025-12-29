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
  print("  pack <source_directory> <archive_path> [--verbose]")
  print("  pack -f <file1> [file2 ...] <archive_path> [--verbose]")
end

if #args < 2 then
  usage()
  return
end

local fileList = {}
local archivePath

if args[1] == "-f" then
  if #args < 3 then
    usage()
    return
  end
  for i = 2, #args - 1 do
    local path = shell.resolve(args[i])
    if not fs.exists(path) then
      print("Error: " .. args[i] .. " does not exist")
      return
    end
    if verbose then print("Adding:", path) end
    table.insert(fileList, path)
  end
  archivePath = shell.resolve(args[#args])
else
  local sourceDir = shell.resolve(args[1])
  archivePath = shell.resolve(args[2])

  if not fs.exists(sourceDir) or not fs.isDirectory(sourceDir) then
    print("Error: Source must be an existing directory.")
    return
  end

  local function getFileList(path)
    local list = {}
    for item in fs.list(path) do
      local fullPath = fs.concat(path, item)
      if verbose then print("Adding:", fullPath) end
      table.insert(list, fullPath)
      if fs.isDirectory(fullPath) then
        local sublist = getFileList(fullPath)
        for _, v in ipairs(sublist) do
          table.insert(list, v)
        end
      end
    end
    return list
  end

  fileList = getFileList(sourceDir)
end

local success, err = compressor.pack(archivePath, fileList)
if success then
  print("Packing complete: " .. archivePath)
else
  print("Error packing files: " .. tostring(err))
end
