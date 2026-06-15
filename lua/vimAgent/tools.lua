local M = {}

M.tools = {
    {
        type = "function",
        ["function"] = {
            name = "read_file",
            description = "Lê o conteúdo de um ficheiro do projeto",
            parameters = { -- era "input_schema", agora é "parameters"
                type = "object",
                properties = {
                    path = {
                        type = "string",
                        description = "Caminho do ficheiro relativo à raiz do projeto",
                    },
                },
                required = { "path" },
            },
        },
    },
}

function M.read_file(path)
    local f = io.open(path, "r")
    if not f then
        return "error ao ler o ficheiro"
    end
    local content = f:read("*a")
    f:close()
    return content
end

function M.tools_use(tools, arguments)
    local var = ""
    if tools == "read_file" then
        print("usar funsao", arguments.path)
        var = M.read_file(arguments.path)
    end
    return var
end

return M
