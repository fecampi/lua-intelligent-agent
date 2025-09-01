local LogDataProvider = {}
LogDataProvider.__index = LogDataProvider

function LogDataProvider:new()
    local self = setmetatable({}, LogDataProvider)
    self.sessionLogs = {
        [101] = {"warn: Playback stalled", "error: WebSocket disconnected"},
        [102] = {"debug: starting process", "warn: Failed to fetch VAST ad"},
        [103] = {"info: system healthy", "warn: Buffer underrun detected"}
    }
    return self
end

function LogDataProvider:getLogs(sessionId)
    print("LogDataProvider: Buscando logs da sessão", sessionId)
    return self.sessionLogs[sessionId] or {"error: session not found"}
end

function LogDataProvider:getAvailableSessions()
    print("LogDataProvider: Listando sessões disponíveis")
    local sessions = {}
    for sessionId, _ in pairs(self.sessionLogs) do
        table.insert(sessions, sessionId)
    end
    table.sort(sessions)
    return sessions
end

return LogDataProvider
