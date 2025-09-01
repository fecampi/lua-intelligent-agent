local dotenv = require("dotenv")
if dotenv.load then
    dotenv.load("/app/.env")
end

local GeminiAgent = require("src/agents/lia_agent_gemini")
local terminal = require("src/utils/terminal")
local logs = require("src/providers/logs/tv")
local configs = require("configs")
local LogDataProvider = require("src/providers/log_data_provider")
local tools = require("src/providers/log_data_tools")

-- Criar uma instância do agente Gemini diretamente
local agent = GeminiAgent:new(configs.gemini)

-- Ler o prompt do sistema
local function read_file(path)
    local f = assert(io.open(path, "r"))
    local content = f:read("*a")
    f:close()
    return content
end

local SYSTEM_PROMPT = read_file("src/agents/prompts/chat_persona_prompt.txt")

terminal.output("Bem-vindo ao agente IA!")
terminal.output("Digite sua pergunta ou 'exit' para sair.")



-- Adiciona as ferramentas ao agente usando o método add_tools do ToolService
agent:add_tools(tools)

-- Ajustar o loop principal para evitar duplicação de prefixos
while true do
    local user_input = terminal.input("")
    if not user_input or user_input == "sair" or user_input == "exit" then
        break
    end
    local resposta = agent:ask(user_input)
    terminal.output(resposta) -- Apenas imprime a resposta diretamente
end

