
local dotenv = require("dotenv")
if dotenv.load then
  dotenv.load("/app/.env")
end
print("GOOGLE_API_KEY:", os.getenv("GOOGLE_API_KEY"))
local Gemini = require("lib.gemini")
local API_KEY = os.getenv("GOOGLE_API_KEY")
local MODEL = "gemini-2.0-flash"
local gemini = Gemini:new(API_KEY, MODEL)

local logs = {
  {
    device_id = "device_1",
    level_name = "WARNING",
    message = "Playback stalled after 10s",
    context = "player.buffering",
    date_time = "2025-06-21T14:15:00Z"
  },
  {
    device_id = "device_2",
    level_name = "WARNING",
    message = "WebSocket disconnected unexpectedly",
    context = "ws.connection",
    date_time = "2025-06-21T14:16:00Z"
  },
  {
    device_id = "device_1",
    level_name = "WARNING",
    message = "Failed to fetch VAST ad",
    context = "ads.loader",
    date_time = "2025-06-21T14:17:00Z"
  }
}

local function table_to_json(tbl)
  local ok, cjson = pcall(require, "cjson")
  if ok then
    return cjson.encode(tbl)
  else
    error("cjson não encontrado")
  end
end

local prompt = string.format([[
### LOGS (JSON)
%s

### OBJETIVO
1. Liste os `device_id` que apresentaram problemas.
2. Agrupe por contexto e descreva os principais problemas.
3. Identifique qualquer padrão que sugira falha de rede, player ou anúncios.

Responda em português técnico, de forma objetiva.
]], table_to_json(logs))

local resposta, json = gemini:send_prompt(prompt)

print("Resposta da API Gemini:")
print(resposta)
