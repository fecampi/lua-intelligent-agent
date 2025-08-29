local http = require("socket.http")
local https = require("ssl.https")
local ltn12 = require("ltn12")

local M = {}

function M.request_json(opts)
  local cjson = require("cjson")
  -- opts: { url, method, headers, body }
  local resp_body = {}
  local req_body = opts.body or ""
  local is_https = opts.url:match("^https://")
  local driver = is_https and https or http

  local res, code, headers, status = driver.request{
    url = opts.url,
    method = opts.method or "GET",
    headers = opts.headers or {},
    source = req_body ~= "" and ltn12.source.string(req_body) or nil,
    sink = ltn12.sink.table(resp_body)
  }

  local ok, decoded = pcall(function()
    return cjson.decode(table.concat(resp_body))
  end)

  return {
    code = code,
    headers = headers,
    status = status,
    raw = table.concat(resp_body),
    json = ok and decoded or nil,
    json_error = not ok and decoded or nil
  }
end

return M
