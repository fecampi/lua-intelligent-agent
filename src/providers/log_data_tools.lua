local LogDataProvider = require("src/providers/log_data_provider")

local tools = {{
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
        return logProvider:getLogs(args.sessionId)
    end
}, {
    name = "getAvailableSessions",
    description = "Retorna um array de IDs numéricos de todas as sessões disponíveis no sistema, em ordem crescente. Use esta função para obter o menor ID de sessão e, em seguida, caso precise utilize getLogs para buscar os logs dessa sessão.",
    parameters = {
        type = "OBJECT",
        properties = {}
    },
    callback = function()
        return logProvider:getAvailableSessions()
    end
}}

return tools
