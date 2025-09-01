local dotenv = require("dotenv")
if dotenv.load then
    dotenv.load("/app/.env")
end

-- Ler o prompt do sistema
local function read_file(path)
    local f = assert(io.open(path, "r"))
    local content = f:read("*a")
    f:close()
    return content
end

local GeminiAgent = require("src/agents/lia_agent_gemini")
local terminal = require("src/utils/terminal")
local logs = require("src/providers/logs/tv")
local configs = require("configs")
local LogDataProvider = require("src/providers/log_data_provider")
local tools = require("src/providers/log_data_tools")
local SYSTEM_PROMPT = read_file("src/agents/prompts/analyze_logs_prompt.txt")

-- Criar uma instância do agente 
local agent = GeminiAgent:new(configs.gemini)
agent:set_system_prompt(SYSTEM_PROMPT)
agent:add_tools(tools)

terminal.output("Bem-vindo ao agente IA!")
terminal.output("Digite sua pergunta ou 'exit' para sair.")


while true do
    local user_input = terminal.input("")
    if not user_input or user_input == "sair" or user_input == "exit" then
        break
    end
    local resposta = agent:ask(user_input)
    terminal.output(resposta) 
end

