# Dockerfile para rodar scripts Lua com LuaSocket
FROM alpine:latest

# Instala dependências, Lua, LuaRocks e luasocket
RUN apk add --no-cache lua5.4 lua5.4-dev luarocks build-base openssl-dev && \
    ln -s /usr/bin/luarocks-5.4 /usr/bin/luarocks && \
    luarocks install luasocket && \
    luarocks install luasec && \
    luarocks install lua-cjson && \
    luarocks install dotenv

# Define o diretório de trabalho
WORKDIR /app

# Copia os arquivos do projeto para o container
COPY . /app

# Comando padrão: abre um shell interativo
CMD ["lua5.4"]
