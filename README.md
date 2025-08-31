## Testing Gemma Integration with Docker

To test the integration with Gemma running locally via Ollama, follow these steps:

1. **Start Ollama and the Gemma model on your host (outside Docker):**

   ```sh
   ollama run gemma:2.7b
   ```

   ```

   ```

2. **Run the test inside the Docker container:**
   ```sh
   sudo docker run --rm -v $(pwd):/app lua-agent lua5.4 test_gemma.lua
   ```

> Make sure your Docker container can access `http://localhost:11434` on the host. If you have issues, you may need to adjust Docker network settings or run the Lua script outside Docker for local testing.

---

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

- `demo.lua`: Main example using the LIA agent abstraction.
- `lib/lia_agent.lua`: LIA agent class, which abstracts LLM usage.
- `lib/llm/`: Directory for LLM (Large Language Model) classes.
  - `gemini.lua`: Gemini API integration (Google Generative AI).
  - (future) `gemma.lua`, `chatgpt.lua`, etc.
- `lib/request.lua`: Module for HTTP/HTTPS requests and JSON handling.
- `Dockerfile`: Ready-to-use environment with all dependencies.

## Supported LLMs

This project is designed to support multiple LLMs (Large Language Models) via the `lib/llm/` directory. Currently, it includes:

- **Gemini** (Google Generative AI): Cloud-based, requires API key.

You can easily add new LLM classes (e.g., for Gemma, ChatGPT, etc.) in the `lib/llm/` folder and use them via the LIA agent abstraction.

## Running Gemma Locally with Ollama (Ubuntu)

To experiment with open-source LLMs like Gemma, you can use [Ollama](https://ollama.com/) to run models locally:

1. **Install Ollama:**

   ```sh
   curl -fsSL https://ollama.com/install.sh | sh
   sudo systemctl start ollama
   sudo systemctl enable ollama
   ```

2. **Download and run the Gemma 3B 270M model:**

   ```sh
   ollama run gemma:2.7b
   ```

   > You can replace `2.7b` with another available Gemma model tag if needed.

3. **Test the API:**

```sh
sudo docker run -it --rm --network=host -v $(pwd):/app -e GOOGLE_API_KEY=$(grep GOOGLE_API_KEY .env | cut -d '=' -f2-) lua-agent lua5.4 demo.lua
```

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
