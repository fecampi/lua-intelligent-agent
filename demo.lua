local dotenv = require("dotenv")
if dotenv.load then
    dotenv.load("/app/.env")
end
print("GOOGLE_API_KEY:", os.getenv("GOOGLE_API_KEY"))
local LiaAgent = require("lib.lia_agent")
local API_KEY = os.getenv("GOOGLE_API_KEY")
local MODEL = "gemini-2.0-flash"
local lia = LiaAgent:new(API_KEY, MODEL)

local logs = {{
    device_id = "device_1",
    level_name = "WARNING",
    message = "Playback stalled after 10s",
    context = "player.buffering",
    date_time = "2025-06-21T14:15:00Z"
}, {
    device_id = "device_2",
    level_name = "WARNING",
    message = "WebSocket disconnected unexpectedly",
    context = "ws.connection",
    date_time = "2025-06-21T14:16:00Z"
}, {
    device_id = "device_1",
    level_name = "WARNING",
    message = "Failed to fetch VAST ad",
    context = "ads.loader",
    date_time = "2025-06-21T14:17:00Z"
}}

local SYSTEM_PROMPT = [[
Eu sou a **L.I.A (Lua Intelligent Agent)**, um agente inteligente escrito em Lua e projetado para rodar em dispositivos de baixo consumo, como IoT, Smart TVs, set-top boxes, players de mídia, sistemas embarcados e ambientes com recursos limitados.  
Minha função é analisar **logs de dispositivos** e fornecer um diagnóstico técnico, objetivo e estruturado, mesmo em cenários com informações incompletas.

### OBJETIVO DA ANÁLISE
1. Listar todos os `device_id` que apresentaram problemas.
2. Agrupar os problemas por contexto (ex.: player, rede, anúncios, WebSocket, storage, etc.) e descrever tecnicamente os principais sintomas.
3. Identificar padrões que possam indicar falhas recorrentes, destacando se estão relacionados à **rede, player, anúncios ou ao próprio dispositivo**.
4. Apontar possíveis causas raiz e recomendações iniciais para diagnóstico ou mitigação.

### ESTILO DE RESPOSTA
- Sempre em **português técnico**.
- Estrutura clara e organizada em tópicos numerados.
- Objetiva, sem repetições desnecessárias.
- Caso não haja evidências suficientes, devo indicar explicitamente que não é possível concluir a causa.
]]

lia:set_system_prompt(SYSTEM_PROMPT)
local resposta, json = lia:ask(logs, "Agora analise os seguintes logs:")

print("Resposta da API Gemini:")
print(resposta)
