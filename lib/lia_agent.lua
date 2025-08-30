local Gemini = require("lib.llm.gemini")
local Gemma = require("lib.llm.gemma")

local LiaAgent = {}
LiaAgent.__index = LiaAgent

function LiaAgent:new(opts)
    -- opts: { llm = "gemini" | "gemma", api_key, model, base_url }
    local self = setmetatable({}, LiaAgent)
    self.llm = opts.llm or "gemini"
    self.model = opts.model or "gemini-2.0-flash"
    self.system_prompt = nil
    if self.llm == "gemini" then
        self.llm_instance = Gemini:new(opts.api_key, self.model)
    elseif self.llm == "gemma" then
        self.llm_instance = Gemma:new(opts.base_url)
    else
        error("Unsupported LLM: " .. tostring(self.llm))
    end
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

function LiaAgent:ask(question, data)
    data = data or {}
    local final_system_prompt = self.system_prompt or ""
    if next(data) ~= nil then
        local json_data = table_to_json(data)
        final_system_prompt = final_system_prompt .. "\n### DATA (JSON)\n" .. json_data
    end
    if question and question ~= "" then
        final_system_prompt = final_system_prompt .. "\n" .. question
    end
    local resposta, json = self.llm_instance:send_prompt(final_system_prompt)
    return resposta, json
end

return LiaAgent
