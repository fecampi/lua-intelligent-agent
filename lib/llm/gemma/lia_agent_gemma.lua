local request = require("lib.request")
local cjson = require("cjson")
local ConversationHistoryService = require("lib.llm.shared.services.conversationHistoryService")

local LiaAgentGemma = {}
LiaAgentGemma.__index = LiaAgentGemma

function LiaAgentGemma:new(opts)
    -- opts: { base_url, model, temperature }
    local self = setmetatable({}, LiaAgentGemma)
    self.base_url = opts.base_url or "http://localhost:11434/v1/chat/completions"
    self.model = opts.model or "gemma3:270m"
    self.temperature = opts.temperature or 0.7 -- Define a temperatura padrão
    self.system_prompt = nil
    self.conversationHistoryService = ConversationHistoryService:new()
    return self
end

function LiaAgentGemma:set_system_prompt(system_prompt)
    self.system_prompt = system_prompt
end

local function prepare_payload_gemma(data, system_prompt, conversation_history, model, temperature)
    local req_table = {
        model = model,
        temperature = temperature,
        messages = {}
    }

    -- Adicionar o system_prompt como a primeira mensagem, se definido
    if system_prompt then
        table.insert(req_table.messages, { role = "system", content = system_prompt })
    end

    -- Adicionar o histórico às mensagens diretamente no payload
    for _, entry in ipairs(conversation_history) do
        table.insert(req_table.messages, { role = entry.role, content = entry.content })
    end

    -- Adicionar dados adicionais, se fornecidos
    if next(data) ~= nil then
        table.insert(req_table.messages, { role = "system", content = "### DATA (JSON)\n" .. cjson.encode(data) })
    end

    -- Antes de enviar o histórico para a LLM
    print("[DEBUG] Mensagens enviadas:", cjson.encode(req_table.messages))

    return req_table
end

function LiaAgentGemma:ask(question, data)
    data = data or {}
    self.conversationHistoryService:add("user", question)

    -- Preparar o payload usando a função independente
    local req_table = prepare_payload_gemma(data, self.system_prompt, self.conversationHistoryService:get(), self.model, self.temperature)

    print("[DEBUG] Payload enviado:", cjson.encode(req_table))

    local resp = request.post {
        url = self.base_url,
        body = req_table
    }

    -- Após receber a resposta da LLM
    print("[DEBUG] Resposta recebida:", resp.raw)
    if resp.json then
        print("[DEBUG] JSON recebido:", cjson.encode(resp.json))
    end

    if resp.code == 200 and resp.json then
        local text = nil
        if resp.json.choices and resp.json.choices[1] and resp.json.choices[1].message and
            resp.json.choices[1].message.content then
            text = resp.json.choices[1].message.content
        end
        self.conversationHistoryService:add("assistant", text)
        return text or resp.raw, resp.json
    else
        return nil, resp.raw
    end
end

return LiaAgentGemma
