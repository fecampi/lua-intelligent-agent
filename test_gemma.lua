local Gemma = require("lib.llm.gemma")
local gemma = Gemma:new() -- usa o endpoint padrão do Ollama

local resposta, json = gemma:send_prompt("What is Lua and why is it used in embedded systems?")
print("Resposta da Gemma:")
print(resposta)