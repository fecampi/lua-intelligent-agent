local Gemini = require("lib.gemini")

local LiaAgent = {}
LiaAgent.__index = LiaAgent

function LiaAgent:new(api_key, model)
    local self = setmetatable({}, LiaAgent)
    self.model = model or "gemini-2.0-flash"
    self.gemini = Gemini:new(api_key, self.model)
    self.system_prompt = nil
    return self
end

function LiaAgent:set_system_prompt(system_prompt)
    self.system_prompt = system_prompt
end

local function table_to_json(tbl)
    local ok, cjson = pcall(require, "cjson")
    if ok then
        return cjson.encode(tbl)
    else
        error("cjson not found")
    end
end

function LiaAgent:ask(data, question)
    local json_data = table_to_json(data)
    local final_system_prompt = self.system_prompt or ""
    final_system_prompt = final_system_prompt .. "\n### DATA (JSON)\n" .. json_data
    if question and question ~= "" then
        final_system_prompt = final_system_prompt .. "\n" .. question
    end
    local resposta, json = self.gemini:send_prompt(final_system_prompt)
    return resposta, json
end

return LiaAgent
