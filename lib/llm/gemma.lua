local http = require("socket.http")
local ltn12 = require("ltn12")
local cjson = require("cjson")

local request = require("lib.request")

local Gemma = {}
Gemma.__index = Gemma

function Gemma:new(base_url)
    local self = setmetatable({}, Gemma)
    self.base_url = "http://localhost:11434/v1/chat/completions"

    return self
end

function Gemma:send_prompt(prompt)
    local req_table = {
        model = "gemma3:270m",
        messages = {{
            role = "user",
            content = prompt
        }}
    }

    print("[Gemma] Sending request to " .. self.base_url)
    print("[Gemma] Request body: " .. cjson.encode(req_table))

    local resp = request.post {
        url = self.base_url,
        body = req_table
    }

    print("[Gemma] HTTP status: " .. tostring(resp.code))
    print("[Gemma] Raw response: " .. tostring(resp.raw))
    if resp.code == 200 and resp.json then
        if resp.json.choices and resp.json.choices[1] and resp.json.choices[1].message and
            resp.json.choices[1].message.content then
            print("[Gemma] Decoded content: " .. resp.json.choices[1].message.content)
            return resp.json.choices[1].message.content, resp.json
        else
            print("[Gemma] Could not decode content.")
            return resp.raw, nil
        end
    else
        print("[Gemma] Request failed.")
        return nil, resp.raw
    end
end

return Gemma
