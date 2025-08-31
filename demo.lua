local dotenv = require("dotenv")
if dotenv.load then
    dotenv.load("/app/.env")
end

local LiaAgentInterface = require("lib/llm/agent_interface")
local terminal = require("lib.terminal")
local logs = require("demo/logs/tv")
local configs = require("configs")

-- Selecionar a configuração desejada
local selected_config = configs.gemma -- Altere para gemma  ou gemini


-- Criar uma instância da interface
local agent = LiaAgentInterface:new(selected_config)

-- Ler o prompt do sistema
local function read_file(path)
    local f = assert(io.open(path, "r"))
    local content = f:read("*a")
    f:close()
    return content
end

local SYSTEM_PROMPT = read_file("demo/prompts/chat_persona_memory_prompt.txt")
agent:set_system_prompt(SYSTEM_PROMPT)

terminal.output("Bem-vindo ao agente IA!")
terminal.output("Digite sua pergunta ou 'exit' para sair.")

while true do
    local user_input = terminal.input()
    if not user_input or user_input == "sair" or user_input == "exit" then
        break
    end
    local resposta = agent:ask(user_input)
    terminal.output(resposta)
end
