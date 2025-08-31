local AgentInterface = {}
AgentInterface.__index = AgentInterface

local LiaAgentGemini = require("lib/llm/gemini/lia_agent_gemini")
local LiaAgentGemma = require("lib/llm/gemma/lia_agent_gemma")

function AgentInterface:new(opts)
    -- opts: { llm, api_key, model, base_url }
    local self = setmetatable({}, AgentInterface)

    if opts.llm == "gemini" then
        self.agent = LiaAgentGemini:new({
            api_key = opts.api_key,
            model = opts.model
        })
    elseif opts.llm == "gemma" then
        self.agent = LiaAgentGemma:new({
            base_url = opts.base_url,
            model = opts.model
        })
    else
        error("Unsupported LLM: " .. tostring(opts.llm))
    end

    return self
end

function AgentInterface:set_system_prompt(prompt)
    self.agent:set_system_prompt(prompt)
end

function AgentInterface:ask(question, data)
    return self.agent:ask(question, data)
end

return AgentInterface
