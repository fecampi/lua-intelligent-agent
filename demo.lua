local dotenv = require("dotenv")
if dotenv.load then
    dotenv.load("/app/.env")
end
print("GOOGLE_API_KEY:", os.getenv("GOOGLE_API_KEY"))

local LiaAgent = require("lib.lia_agent")
local terminal = require("lib.terminal")
local API_KEY = os.getenv("GOOGLE_API_KEY")
local MODEL = "gemini-2.0-flash"
local LLM = "gemma"

local lia
if LLM == "gemini" then
    lia = LiaAgent:new({
        llm = "gemini",
        api_key = API_KEY,
        model = MODEL
    })
elseif LLM == "gemma" then
    lia = LiaAgent:new({
        llm = "gemma"
    })
else
    error("Unsupported LLM: " .. tostring(LLM))
end

local logs = {{
    device_id = "tv_03",
    level_name = "ERROR",
    message = "Audio/video sync lost during playback",
    context = "playback",
    date_time = "2025-06-21T15:04:00Z"
}, {
    device_id = "tv_01",
    level_name = "ERROR",
    message = "Ethernet link down",
    context = "infra",
    date_time = "2025-06-21T15:05:00Z"
}, {
    device_id = "tv_02",
    level_name = "WARNING",
    message = "Wi-Fi signal weak (-80 dBm)",
    context = "infra",
    date_time = "2025-06-21T15:06:00Z"
}, {
    device_id = "tv_01",
    level_name = "INFO",
    message = "Playback started successfully",
    context = "playback",
    date_time = "2025-06-21T15:09:00Z"
}, {
    device_id = "tv_02",
    level_name = "DEBUG",
    message = "Buffer preloaded: 5 seconds of video",
    context = "playback",
    date_time = "2025-06-21T15:10:00Z"
}}

local function read_file(path)
    local f = assert(io.open(path, "r"))
    local content = f:read("*a")
    f:close()
    return content
end

local SYSTEM_PROMPT = read_file("demo/prompts/chat_persona_prompt.txt")
lia:set_system_prompt(SYSTEM_PROMPT)

terminal.output("Bem-vindo ao agente IA!")
terminal.output("Digite sua pergunta ou 'exit' para sair.")

while true do
    local user_input = terminal.input()
    if not user_input or user_input == "sair" or user_input == "exit" then
        break
    end
    local resposta = lia:ask(user_input)
    terminal.output(resposta)
end
