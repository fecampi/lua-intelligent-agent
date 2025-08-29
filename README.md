

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
git clone <url-do-seu-repo>
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
sudo docker run --rm -v $(pwd):/app -e GOOGLE_API_KEY=$(grep GOOGLE_API_KEY .env | cut -d '=' -f2-) lua-agent lua5.4 lia_agent.lua
```

## Project Structure
- `lia_agent.lua`: Main example of using the Gemini API.
- `lib/request.lua`: Module for HTTP/HTTPS requests and JSON handling.
- `lib/gemini.lua`: Module for Gemini API integration.
- `Dockerfile`: Ready-to-use environment with all dependencies.

## Notes
- Do not share your API key publicly.
- To install dependencies locally (outside Docker), use:
  ```sh
  luarocks install luasocket luasec lua-cjson dotenv
  ```

---

Questions? Open an issue or ask for help!
