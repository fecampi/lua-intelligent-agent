local request = require("src/utils/request")
local cjson = require("cjson")
local ConversationHistoryService = require("src/agents/services/conversationHistoryService")
local ToolService = require("src/agents/services/tool_service")

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
            function_declarations = self.toolService:get_tools()
        },
        generationConfig = {
            temperature = self.temperature,
            topP = 0.9,
            topK = 40,
            maxOutputTokens = 200
        }
    }

   
    if self.system_prompt and #self.system_prompt > 0 then
        table.insert(req_body.contents[1].parts, {
            text = "### SYSTEM PROMPT\n" .. self.system_prompt
        })
    end

    for _, entry in ipairs(self.conversationHistoryService:get()) do
        table.insert(req_body.contents[1].parts, {
            text = entry.content
        })
    end

    if next(data) ~= nil then
        local json_data = cjson.encode(data)
        table.insert(req_body.contents[1].parts, {
            text = "### DATA (JSON)\n" .. json_data
        })
    end

    return req_body
end

function LiaAgentGemini:execute_tool(function_name, function_args)
    local tool_data = self.toolService:get_tool(function_name)
    if tool_data and tool_data.callback then
        return tool_data.callback(function_args)
    end
    error("[Tool Execution] Ferramenta não encontrada ou sem callback: " .. function_name)
end

function LiaAgentGemini:add_tool(tool, callback)
    self.toolService:add_tool(tool, callback)
end

function LiaAgentGemini:add_tools(tools)
    self.toolService:add_tools(tools)
end

-- Atualizar o método ask para usar execute_tool
function LiaAgentGemini:ask(question, data)
    data = data or {}
    self.conversationHistoryService:add("user", question)

    local req_body = self:prepare_payload(data)

    local url = "https://generativelanguage.googleapis.com/v1beta/models/" .. self.model .. ":generateContent?key=" ..
                    self.api_key

    while true do
        local encoded_body = cjson.encode(req_body)

        local resp = request.post {
            url = url,
            headers = {
                ["Content-Type"] = "application/json"
            },
            body = encoded_body
        }

        if resp.code == 200 and resp.json then
            local candidate = resp.json.candidates and resp.json.candidates[1]

            if candidate and candidate.content and candidate.content.parts and candidate.content.parts[1] then
                local part = candidate.content.parts[1]

                if part.text then
                    self.conversationHistoryService:add("assistant", part.text)
                    return part.text, resp.json
                elseif part.functionCall then
                    local function_name = part.functionCall.name
                    local function_args = part.functionCall.args or {}

                    -- Executa a ferramenta diretamente pelo ToolService
                    local tool_result = self.toolService:execute_tool_by_name(function_name, function_args)
                    local tool_message = "Ferramenta executada com sucesso: " .. function_name

                  

                    self.conversationHistoryService:add("assistant", tool_message)

        
                    local result_message = cjson.encode(tool_result)
                    self.conversationHistoryService:add("assistant", "### RESULTADO DA FERRAMENTA\n" .. result_message)

                    -- Atualize o payload com o resultado da ferramenta
                    req_body = self:prepare_payload({
                        tool_result = tool_result
                    })

                    -- Retornar o resultado da ferramenta diretamente ao usuário
                    local formatted_result = cjson.encode(tool_result)
        
                    return formatted_result, resp.json
                end
            end
        else
            print("[DEBUG] Erro na resposta da API:", resp.raw) -- Log do erro na resposta
            return nil, resp.raw
        end
    end
end

return LiaAgentGemini
