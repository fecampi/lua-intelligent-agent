local cjson = require("cjson")
local ToolService = {}
ToolService.__index = ToolService

function ToolService:new()
    local self = setmetatable({}, ToolService)
    self.tools = {} -- Array para armazenar as ferramentas
    self.callbacks = {} -- Array para armazenar os callbacks
    return self
end

function ToolService:add_tool(tool, callback)
    if not tool.name then
        error("[Tool Service] O campo 'name' é obrigatório para registrar uma ferramenta.")
    end

    print("[Tool Service] Adicionando nova ferramenta:", tool.name)
    table.insert(self.tools, {
        name = tool.name,
        description = tool.description,
        parameters = tool.parameters
    })
    -- Registra o callback 
    if type(callback) == "function" then
        self.callbacks[tool.name] = callback
    else
        print("[Tool Service] Erro: Callback não é uma função válida para a ferramenta:", tool.name)
    end
end

function ToolService:add_tools(tools)
    for _, tool in ipairs(tools) do
        if tool.name and type(tool.callback) == "function" then
            self:add_tool(tool, tool.callback)
        else
            print("[Tool Service] Erro: Ferramenta inválida ou callback ausente para:", tool.name or "(sem nome)")
        end
    end
end

function ToolService:execute_tool(name, args)
    local callback = self.callbacks[name]
    if callback then
        return callback(args)
    else
        error("[Tool Execution] Ferramenta não encontrada: " .. name)
    end
end

function ToolService:execute_tool_by_name(name, args)
    local callback = self.callbacks[name]
    if callback then
        return callback(args)
    else
        error("[Tool Execution] Callback não encontrado para a ferramenta: " .. name)
    end
end

function ToolService:get_tools()
    return self.tools
end

return ToolService
