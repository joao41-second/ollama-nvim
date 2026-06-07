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

return M
