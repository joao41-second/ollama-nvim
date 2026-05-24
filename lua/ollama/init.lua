local M = {}

function M.create_temp_file()
    local temp_file = vim.fn.tempname()
    local temp_path = temp_file .. ".tmp"

    local file = io.open(temp_path, "w")

    if not file then
        vim.notify(
            "Erro ao criar arquivo temporário",
            vim.log.levels.ERROR
        )
        return nil
    end

    file:write("Este é um arquivo temporário gerado por Lua.\n")
    file:close()

    vim.notify(
        "Arquivo temporário criado: " .. temp_path,
        vim.log.levels.INFO
    )

    return temp_path
end

vim.api.nvim_create_user_command("GenUnloadModel", function()
    create_temp_file();

end, {})

return M
