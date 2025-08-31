local request = require("lib.request")
local cjson = require("cjson")
local ConversationHistoryService = require("lib.llm.shared.services.conversationHistoryService")
local ToolService = require("lib.llm.shared.tool_service")

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
    self.toolService = ToolService:new(self)
    -- Tool 

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
        tools = {
            function_declarations = self.toolService:clean_tools()
        },
        generationConfig = {
            temperature = self.temperature,
            topP = 0.9,
            topK = 40,
            maxOutputTokens = 200
        }
    }

    -- Adiciona system prompt
    if self.system_prompt then
        table.insert(req_body.contents[1].parts, {
            text = self.system_prompt
        })
    end

    -- Adiciona histórico de conversa
    for _, entry in ipairs(self.conversationHistoryService:get()) do
        table.insert(req_body.contents[1].parts, {
            text = entry.content
        })
    end

    -- Adiciona dados adicionais em JSON
    if next(data) ~= nil then
        local json_data = cjson.encode(data)
        table.insert(req_body.contents[1].parts, {
            text = "### DATA (JSON)\n" .. json_data
        })
    end

    -- Debug
    print("[DEBUG] Mensagens enviadas:", cjson.encode(req_body.contents[1].parts))
    print("[DEBUG] Tools enviadas:", cjson.encode(req_body.tools))

    return req_body
end

function LiaAgentGemini:execute_tool(function_name, function_args)
    local tool = self.toolService:get_tool(function_name)
    if tool and tool.callback then
        return tool.callback(function_args)
    end
    error("[Tool Execution] Ferramenta não encontrada: " .. function_name)
end

-- Atualizar o método ask para usar execute_tool
function LiaAgentGemini:ask(question, data)
    data = data or {}
    self.conversationHistoryService:add("user", question)

    local req_body = self:prepare_payload(data)

    print("[Gemini] Payload ajustado enviado com generationConfig:", cjson.encode(req_body))

    local url = "https://generativelanguage.googleapis.com/v1beta/models/" .. self.model .. ":generateContent?key=" ..
                    self.api_key

    while true do
        local resp = request.post {
            url = url,
            headers = {
                ["Content-Type"] = "application/json"
            },
            body = cjson.encode(req_body)
        }

        print("[DEBUG] Resposta recebida:", resp.raw)
        if resp.json then
            print("[DEBUG] JSON recebido:", cjson.encode(resp.json))
        end

        if resp.code == 200 and resp.json then
            local candidate = resp.json.candidates and resp.json.candidates[1]

            if candidate and candidate.content and candidate.content.parts and candidate.content.parts[1] then
                local part = candidate.content.parts[1]

                if part.text then
                    -- Resposta de texto normal, como esperado.
                    self.conversationHistoryService:add("assistant", part.text)
                    return part.text, resp.json
                elseif part.functionCall then
                    -- Executar a ferramenta chamada
                    local function_name = part.functionCall.name
                    local function_args = part.functionCall.args or {}

                    -- Verificar se a ferramenta existe usando ToolService
                    local tool = self.toolService:get_tool(function_name)

                    if tool and tool.callback then
                        local tool_result = tool.callback(function_args)
                        local tool_message = "Ferramenta executada com sucesso: " .. function_name

                        -- Adicione esta resposta amigável ao histórico
                        self.conversationHistoryService:add("assistant", tool_message)

                        -- Adicione o resultado da ferramenta ao histórico para enviar de volta à IA
                        local result_message = cjson.encode(tool_result)
                        self.conversationHistoryService:add("assistant",
                            "### RESULTADO DA FERRAMENTA\n" .. result_message)

                        -- Atualize o payload com o resultado da ferramenta
                        req_body = self:prepare_payload({
                            tool_result = tool_result
                        })

                        -- Retornar o resultado da ferramenta diretamente ao usuário
                        local formatted_result = cjson.encode(tool_result)
                        print("[Tool Execution Result]", formatted_result)
                        return formatted_result, resp.json
                    else
                        error("[Tool Execution] Ferramenta não encontrada ou sem callback: " .. function_name)
                    end
                end
            end
        else
            -- Retorna a resposta crua ou nula em caso de erro
            return nil, resp.raw
        end
    end
end

return LiaAgentGemini
