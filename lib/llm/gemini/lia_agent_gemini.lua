local request = require("lib.request")
local cjson = require("cjson")
local ConversationHistoryService = require("lib.llm.shared.services.conversationHistoryService")

local LiaAgentGemini = {}
LiaAgentGemini.__index = LiaAgentGemini

function LiaAgentGemini:new(opts)
    -- opts: { api_key, model, temperature }
    local self = setmetatable({}, LiaAgentGemini)
    self.api_key = opts.api_key or ""
    self.model = opts.model or "gemini-2.0-flash"
    self.temperature = opts.temperature or 0.7 -- Define a temperatura padrão
    self.system_prompt = nil
    self.conversationHistoryService = ConversationHistoryService:new(10)
    return self
end

function LiaAgentGemini:set_system_prompt(system_prompt)
    self.system_prompt = system_prompt
end

function LiaAgentGemini:prepare_payload(data)
    local req_body = {
        contents = {{
            parts = {}
        }},
        generationConfig = {
            temperature = self.temperature or 0.7, -- Controla a aleatoriedade das respostas (0.0 = determinístico, 1.0 = mais criativo)
            topP = 0.9, -- Núcleo de amostragem: considera palavras até atingir 90% da probabilidade cumulativa
            topK = 40, -- Limita a escolha às 40 palavras mais prováveis
            maxOutputTokens = 200 -- Define o número máximo de tokens na resposta gerada
        }
    }

    -- Adicionar o system_prompt como a primeira mensagem, se definido
    if self.system_prompt then
        table.insert(req_body.contents[1].parts, { text = self.system_prompt })
    end

    -- Adicionar o histórico às mensagens diretamente no payload
    for _, entry in ipairs(self.conversationHistoryService:get()) do
        table.insert(req_body.contents[1].parts, { text = entry.content })
    end

    if next(data) ~= nil then
        local json_data = cjson.encode(data)
        table.insert(req_body.contents[1].parts, { text = "### DATA (JSON)\n" .. json_data })
    end

    -- Antes de enviar o histórico para a LLM
    print("[DEBUG] Mensagens enviadas:", cjson.encode(req_body.contents[1].parts))

    return req_body
end

function LiaAgentGemini:ask(question, data)
    data = data or {}
    self.conversationHistoryService:add("user", question)

    -- Preparar o payload usando a nova função
    local req_body = self:prepare_payload(data)

    -- Adicionando log para depuração
    print("[Gemini] Payload ajustado enviado com generationConfig:", cjson.encode(req_body))

    local url = "https://generativelanguage.googleapis.com/v1beta/models/" .. self.model .. ":generateContent?key=" .. self.api_key
    local resp = request.post {
        url = url,
        body = req_body
    }

    -- Após receber a resposta da LLM
    print("[DEBUG] Resposta recebida:", resp.raw)
    if resp.json then
        print("[DEBUG] JSON recebido:", cjson.encode(resp.json))
    end

    if resp.code == 200 and resp.json then
        local text = nil
        if resp.json.candidates and resp.json.candidates[1] and resp.json.candidates[1].content and
            resp.json.candidates[1].content.parts and resp.json.candidates[1].content.parts[1] then
            text = resp.json.candidates[1].content.parts[1].text
        end
        self.conversationHistoryService:add("assistant", text)
        return text or resp.raw, resp.json
    else
        return nil, resp.raw
    end
end

return LiaAgentGemini
