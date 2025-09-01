local cjson = require("cjson")
local ConversationHistoryService = {}
ConversationHistoryService.__index = ConversationHistoryService

function ConversationHistoryService:new(max_history)
    local self = setmetatable({}, ConversationHistoryService)
    self.max_history = max_history or 10
    self.history = {}
    return self
end

function ConversationHistoryService:add(role, content)
    table.insert(self.history, { role = role, content = content })
    while #self.history > self.max_history do     
        table.remove(self.history, 1)
    end
end

function ConversationHistoryService:get_messages()
    local messages = {}
    for _, entry in ipairs(self.history) do
        table.insert(messages, { role = entry.role, content = entry.content })
    end
    return messages
end

function ConversationHistoryService:get()
    return self.history 
end

return ConversationHistoryService
