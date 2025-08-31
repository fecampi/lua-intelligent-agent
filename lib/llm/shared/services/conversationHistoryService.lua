local ConversationHistoryService = {}
ConversationHistoryService.__index = ConversationHistoryService

function ConversationHistoryService:new(max_history)
    local self = setmetatable({}, ConversationHistoryService)
    self.max_history = max_history or 10
    self.history = {}
    return self
end

function ConversationHistoryService:add(role, content)
    print("[DEBUG - Histórico de Conversa] Adicionando ao histórico:", string.format("{ role = '%s', content = '%s' }", role, content))
    table.insert(self.history, { role = role, content = content })
    while #self.history > self.max_history do
        print("[DEBUG - Histórico de Conversa] Removendo do histórico:", string.format("{ role = '%s', content = '%s' }", self.history[1].role, self.history[1].content))
        table.remove(self.history, 1)
    end
end

function ConversationHistoryService:get_messages()
    print("[DEBUG - Histórico de Conversa] Recuperando mensagens do histórico:")
    for _, entry in ipairs(self.history) do
        print(string.format("{ role = '%s', content = '%s' }", entry.role, entry.content))
    end
    local messages = {}
    for _, entry in ipairs(self.history) do
        table.insert(messages, { role = entry.role, content = entry.content })
    end
    return messages
end

function ConversationHistoryService:get()
    print("[DEBUG - Histórico de Conversa] Recuperando histórico completo:")
    for _, entry in ipairs(self.history) do
        print(string.format("{ role = '%s', content = '%s' }", entry.role, entry.content))
    end
    return self.history
end

return ConversationHistoryService
