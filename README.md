# Lua Intelligent Agent (L.I.A)

## Introduction

The goal of this project is to build an intelligent agent called **L.I.A (Lua Intelligent Agent)**, written in Lua, capable of running on devices with low processing power and limited memory, such as embedded systems, IoT devices, routers, home automation, Smart TVs, set-top boxes, broadcast playout systems, digital signage players, media streamers, and other entertainment devices.

Lua is an extremely lightweight, fast, and easy-to-embed language. Therefore, it is ideal for scenarios where computational resources are limited, allowing the creation of intelligent agents, integrations, and automations without overloading the hardware.

Advantages of using Lua:

- Very low memory and CPU consumption
- Easy integration with C/C++ and other systems
- Widely used in games, IoT, automation, routers, embedded systems, Smart TVs (LG webOS, Samsung Tizen, Ginga Digital TV middleware), digital media players, and configuration scripts
- Portable to virtually any operating system and hardware platform

This project demonstrates how to consume the Gemini API (Google Generative AI) using Lua, with modular architecture and environment variable support via `.env`.

## Prerequisites

- Docker installed
- A valid Google Gemini API key

## Steps to run the project

### 1. Clone the repository

```sh
git clone https://github.com/fecampi/lua-intelligent-agent.git
cd lua-intelligent-agent
```

### 2. Create the `.env` file

In the project root, create a file called `.env` with the following content:

```
GOOGLE_API_KEY=your_key_here
```

### 3. Build the Docker image

```sh
sudo docker build -t lua-agent .
```

### 4. Run the main script

```sh
sudo docker run --rm -v $(pwd):/app -e GOOGLE_API_KEY=$(grep GOOGLE_API_KEY .env | cut -d '=' -f2-) lua-agent lua5.4 demo.lua
```

## Project Structure

- `demo.lua`: Main script demonstrating the use of the LIA agent abstraction.
- `lib/lia_agent.lua`: LIA agent class, which abstracts the usage of LLMs.
- `lib/llm/`: Directory for Large Language Model (LLM) classes.
  - `gemini/lia_agent_gemini.lua`: Integration with the Gemini API (Google Generative AI).
  - `gemma/lia_agent_gemma.lua`: Integration with the Gemma model.
  - `shared/`: Shared components between different LLMs.
- `lib/request.lua`: Module for HTTP/HTTPS requests and JSON handling.
- `Dockerfile`: Ready-to-use environment with all dependencies configured.


---

## Output Example

When analyzing device logs, the API returns a detailed analysis:

```
**1. Devices with issues:**

- device_1
- device_2

**2. Context grouping and problem description:**

- **player.buffering:** Device device_1 experienced playback stalling after 10 seconds. This indicates a buffering issue or insufficient download speed.

- **ws.connection:** Device device_2 had an unexpected WebSocket disconnection. This might indicate network issues, connection instability, or WebSocket server errors.

- **ads.loader:** Device device_1 failed to fetch a VAST ad. This could indicate issues with the ad server, VAST configuration, or network connectivity.

**3. Patterns and possible causes:**

- **device_1 shows issues in player.buffering and ads.loader.** This might indicate an unstable network or low bandwidth, affecting both content playback and ad loading. Specific issues with device_1's player might also be contributing to the stalling.

- **The unexpected WebSocket disconnection on device_2 (ws.connection)** suggests a network issue on the device or a WebSocket failure. It's important to check device_2's network connection stability and WebSocket server health.
```

---

## Interaction Example

Below is an example of an interaction with the Lua Intelligent Agent (L.I.A):

```plaintext
User: Para qual finalidade você foi criado e qual é a função ou papel que se espera que você desempenha?
AI: Fui criado para ser a L.I.A (Lua Intelligent Agent), um agente inteligente especializado em análise de logs técnicos de dispositivos como Smart TVs, IoT, set-top boxes e sistemas embarcados. Espera-se que eu analise logs, entregue diagnósticos detalhados, identifique problemas, aponte causas raiz e recomende ações, tudo com base nas informações contidas nos logs fornecidos.

User: Você poderia listar todas as seções de logs que estão armazenadas no sistema?
AI: [101,102,103]

User: Você poderia explicar se ocorreu algum erro na primeira seção de logs armazenada?
AI: ["warn: Playback stalled","error: WebSocket disconnected"]

User: Você poderia fornecer uma explicação técnica sobre o problema que ocorreu durante a reprodução?
AI: Com base nos logs da sessão 101, o problema identificado durante a reprodução é que o playback foi interrompido (stalled). Isso significa que a reprodução do conteúdo foi interrompida inesperadamente. A causa raiz para essa interrupção não pode ser determinada apenas com essa informação.
```

---

## Project Architecture

The project architecture is modular and designed to be extensible, allowing the integration of different Large Language Models (LLMs) and services. Below is a diagram illustrating the main components of the project:

```plaintext
+-------------------+       +-------------------+       +-------------------+
|                   |       |                   |       |                   |
|   demo.lua        +------>+   LIA Agent       +------>+   LLMs            |
|                   |       |                   |       |                   |
+-------------------+       +-------------------+       +-------------------+
        |                        |                           |
        |                        |                           |
        v                        v                           v
+-------------------+   +-------------------+       +-------------------+
|                   |   |                   |       |                   |
|   Tool Service    |   | Conversation      |       | HTTP Request      |
|                   |   | History Service   |       | Module           |
+-------------------+   +-------------------+       +-------------------+
```
