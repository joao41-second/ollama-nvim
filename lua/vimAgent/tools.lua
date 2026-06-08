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
        return nil
    end
    local content = f:read("*a")
    f:close()
    return content
end

return M
