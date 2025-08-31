return {
    gemini = {
        llm = "gemini",
        api_key = os.getenv("GOOGLE_API_KEY"), -- Obtém a chave da API do .env
        model = "gemini-2.0-flash",
        temperature = 0.1 -- Temperatura baixa para reduzir alucinações
    },
    gemma = {
        llm = "gemma",
        base_url = "http://localhost:11434/v1/chat/completions",
        model = "gemma3:270m",
        temperature = 0.1 -- Temperatura baixa para reduzir alucinações
    }
}
