local cjson = require("cjson")

local function prepare_payload_gemma(data, system_prompt, conversation_history, model, temperature)
    local req_table = {
        model = model,
        temperature = temperature,
        messages = {}
    }

    if system_prompt then
        table.insert(req_table.messages, { role = "system", content = system_prompt })
    end

    for _, entry in ipairs(conversation_history) do
        table.insert(req_table.messages, { role = entry.role, content = entry.content })
    end

    if next(data) ~= nil then
        table.insert(req_table.messages, { role = "system", content = "### DATA (JSON)\n" .. cjson.encode(data) })
    end

    print("[DEBUG] Mensagens enviadas:", cjson.encode(req_table.messages))

    return req_table
end

return prepare_payload_gemma
