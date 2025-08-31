local request = require("lib.request")
local cjson = require("cjson")
local ConversationHistoryService = require("lib.llm.shared.services.conversationHistoryService")
local prepare_payload_gemma = require("lib.llm.gemma.services.prepare_payload")

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

function LiaAgentGemma:ask(question, data)
    data = data or {}
    self.conversationHistoryService:add("user", question)

    local req_table = prepare_payload_gemma(data, self.system_prompt, self.conversationHistoryService:get(), self.model, self.temperature)

    print("[DEBUG] Payload enviado:", cjson.encode(req_table))

    local resp = request.post {
        url = self.base_url,
        body = req_table
    }

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
