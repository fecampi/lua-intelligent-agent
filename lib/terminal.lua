local terminal = {}

function terminal.input(prompt)
    io.write(prompt or "User: ")
    return io.read()
end

function terminal.output(message)
    if type(message) == "string" and message:match("^%s*$") then
        print("")
    else
        print("AI: " .. tostring(message))
    end
end

return terminal
