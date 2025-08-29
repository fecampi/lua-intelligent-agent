local request = require("lib.request")

local Gemini = {}
Gemini.__index = Gemini

function Gemini:new(api_key, model)
  local self = setmetatable({}, Gemini)
  self.api_key = api_key or ""
  self.model = model or "gemini-2.0-flash"
  return self
end

function Gemini:send_prompt(prompt)
  local function table_to_json(tbl)
    local ok, cjson = pcall(require, "cjson")
    if ok then
      return cjson.encode(tbl)
    else
      error("cjson não encontrado")
    end
  end

  local url = "https://generativelanguage.googleapis.com/v1beta/models/" .. self.model .. ":generateContent?key=" .. self.api_key
  local req_body = table_to_json({ contents = { { parts = { { text = prompt } } } } })

  local resp = request.request_json {
    url = url,
    method = "POST",
    headers = {
      ["Content-Type"] = "application/json",
      ["Content-Length"] = tostring(#req_body)
    },
    body = req_body
  }

  if resp.code == 200 and resp.json then
    -- Tenta extrair o texto da resposta Gemini
    local text = nil
    if resp.json.candidates and resp.json.candidates[1] and resp.json.candidates[1].content and resp.json.candidates[1].content.parts and resp.json.candidates[1].content.parts[1] then
      text = resp.json.candidates[1].content.parts[1].text
    end
    return text or resp.raw, resp.json
  else
    return nil, resp.raw
  end
end

return Gemini
