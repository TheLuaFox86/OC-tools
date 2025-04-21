local component = require("component")
local internet = component.internet
local fs = require("filesystem")
local shell = require("shell")

local M = {}

--- Uploads an MP3 file to remote.craftos-pc.cc and returns the DFPWM ID and URL
-- @param filepath Path to the .mp3 file on disk
-- @return id, url | nil, errorMessage
function M.upload(filepath)
  if not fs.exists(filepath) then
    return nil, "File not found: " .. filepath
  end

  local file, err = io.open(filepath, "rb")
  if not file then
    return nil, "Failed to open file: " .. err
  end

  local data = file:read("*a")
  file:close()

  local filename = fs.name(filepath)
  local boundary = "----OpenComputersBoundary" .. math.random(1000, 9999)
  local crlf = "\r\n"

  local body = table.concat({
    "--" .. boundary,
    'Content-Disposition: form-data; name="file"; filename="' .. filename .. '"',
    "Content-Type: audio/mpeg",
    "",
    data,
    "--" .. boundary .. "--",
    ""
  }, crlf)

  local headers = {
    ["Content-Type"] = "multipart/form-data; boundary=" .. boundary,
    ["Content-Length"] = tostring(#body)
  }

  local response = internet.request("https://remote.craftos-pc.cc/music/upload", body, headers)
  if not response then
    return nil, "HTTP request failed"
  end

  local result = ""
  for chunk in response do
    result = result .. chunk
  end

  -- Try to parse simple JSON manually since OpenOS doesn't include a parser
  local id = result:match('"id"%s*:%s*"([%w_-]+)"')
  if not id then
    return nil, "Failed to parse response or ID not found. Raw response: " .. result
  end

  local url = "https://remote.craftos-pc.cc/music/content/" .. id .. ".dfpwm"
  return id, url
end

return M
