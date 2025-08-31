local cjson = require("cjson")

local function prepare_payload(data, system_prompt, conversation_history, temperature)
    local req_body = {
        contents = {{
            parts = {}
        }},
        generationConfig = {
            temperature = temperature or 0.7, -- Controla a aleatoriedade das respostas (0.0 = determinístico, 1.0 = mais criativo)
            topP = 0.9, -- Núcleo de amostragem: considera palavras até atingir 90% da probabilidade cumulativa
            topK = 40, -- Limita a escolha às 40 palavras mais prováveis
            maxOutputTokens = 200 -- Define o número máximo de tokens na resposta gerada
        }
    }

    if system_prompt then
        table.insert(req_body.contents[1].parts, { text = system_prompt })
    end

    for _, entry in ipairs(conversation_history) do
        table.insert(req_body.contents[1].parts, { text = entry.content })
    end

    if next(data) ~= nil then
        local json_data = cjson.encode(data)
        table.insert(req_body.contents[1].parts, { text = "### DATA (JSON)\n" .. json_data })
    end

    print("[DEBUG] Mensagens enviadas:", cjson.encode(req_body.contents[1].parts))

    return req_body
end

return prepare_payload
