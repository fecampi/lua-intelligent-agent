local LogDataProvider = require("src/providers/log_data_provider")

local ToolService = {}
ToolService.__index = ToolService

function ToolService:new(agent)
    local self = setmetatable({}, ToolService)
    self.agent = agent -- Armazena a referência ao agente
    self.logProvider = LogDataProvider:new()
    self.tools = {{
        name = "get_temperature",
        description = "Retorna a temperatura atual configurada no agente.",
        parameters = {
            type = "OBJECT",
            properties = {}
        },
        callback = function()
            print("[Tool Execution] Obtendo a temperatura atual...")
            if not self.agent then
                error("[Tool Execution] O agente não foi definido corretamente no ToolService.")
            end
            return {
                temperature = self.agent.temperature 
            }
        end
    }, {
        name = "getLogs",
        description = "Busca os logs (erros, avisos, eventos) de uma sessão específica pelo ID da sessão. Caso não saiba o ID, utilize getAvailableSessions para obter um ID válido antes de chamar esta função.",
        parameters = {
            type = "OBJECT",
            properties = {
                sessionId = {
                    type = "INTEGER",
                    description = "ID da sessão (101, 102, ou 103)."
                }
            },
            required = {"sessionId"}
        },
        callback = function(args)
            return self.logProvider:getLogs(args.sessionId)
        end
    }, {
        name = "getAvailableSessions",
        description = "Retorna um array de IDs numéricos de todas as sessões disponíveis no sistema, em ordem crescente. Use esta função para obter o menor ID de sessão e, em seguida, caso precise utilize getLogs para buscar os logs dessa sessão.",
        parameters = {
            type = "OBJECT",
            properties = {}
        },
        callback = function()
            return self.logProvider:getAvailableSessions()
        end
    }, {
        name = "get_agent_info",
        description = "Retorna todas as informações disponíveis do agente.",
        parameters = {
            type = "OBJECT",
            properties = {}
        },
        callback = function()
            print("[Tool Execution] Obtendo informações do agente...")
            if not self.agent then
                error("[Tool Execution] O agente não foi definido corretamente no ToolService.")
            end

            local agent_info = {}
            for key, value in pairs(self.agent) do
                agent_info[key] = tostring(value) -- Converte valores para string para evitar erros de serialização
            end

            return agent_info
        end
    }}
    return self
end

function ToolService:get_tool(name)
    for _, tool in ipairs(self.tools) do
        if tool.name == name then
            return tool
        end
    end
    return nil
end

function ToolService:clean_tools()
    local cleaned_tools = {}
    for _, tool in ipairs(self.tools) do
        local cleaned_tool = {}
        for key, value in pairs(tool) do
            if key ~= "callback" then
                cleaned_tool[key] = value
            end
        end
        table.insert(cleaned_tools, cleaned_tool)
    end
    return cleaned_tools
end

return ToolService
