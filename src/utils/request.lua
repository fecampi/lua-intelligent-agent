local http = require("socket.http")
local https = require("ssl.https")
local ltn12 = require("ltn12")

local M = {}


---
-- Makes an HTTP request and parses the response as JSON.
-- @param opts table: { url, method, headers, body }
-- @return table: { code, headers, status, raw, json, json_error }

function M.request_json(opts)
    local cjson = require("cjson")
    -- opts: { url, method, headers, body }
    local resp_body = {}
    local req_body = opts.body or ""
    if type(req_body) == "table" then
        req_body = cjson.encode(req_body)
    end
    local is_https = opts.url:match("^https://")
    local driver = is_https and https or http

    local headers = opts.headers or {}
    if not headers["Content-Type"] then
        headers["Content-Type"] = "application/json"
    end

    local res, code, res_headers, status = driver.request {
        url = opts.url,
        method = opts.method or "GET",
        headers = headers,
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

function M.get(opts)
    ---
    -- Makes a GET request and parses the response as JSON.
    -- @param opts table: { url, headers }
    -- @return table: { code, headers, status, raw, json, json_error }
    opts = opts or {}
    opts.method = "GET"
    return M.request_json(opts)
end

function M.post(opts)
    ---
    -- Makes a POST request and parses the response as JSON.
    -- @param opts table: { url, headers, body }
    -- @return table: { code, headers, status, raw, json, json_error }
    opts = opts or {}
    opts.method = "POST"
    return M.request_json(opts)
end

function M.put(opts)
    ---
    -- Makes a PUT request and parses the response as JSON.
    -- @param opts table: { url, headers, body }
    -- @return table: { code, headers, status, raw, json, json_error }
    opts = opts or {}
    opts.method = "PUT"
    return M.request_json(opts)
end

function M.patch(opts)
    ---
    -- Makes a PATCH request and parses the response as JSON.
    -- @param opts table: { url, headers, body }
    -- @return table: { code, headers, status, raw, json, json_error }
    opts = opts or {}
    opts.method = "PATCH"
    return M.request_json(opts)
end

function M.delete(opts)
    ---
    -- Makes a DELETE request and parses the response as JSON.
    -- @param opts table: { url, headers }
    -- @return table: { code, headers, status, raw, json, json_error }
    opts = opts or {}
    opts.method = "DELETE"
    return M.request_json(opts)
end

return M
