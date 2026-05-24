local M = {}

function M.create_temp_file()
    local temp_file = vim.fn.tempname() -- gera um nome temporário
    local temp_path = temp_file .. ".tmp" -- ou qualquer extensão

    -- Cria o arquivo temporário
    local file = io.open(temp_path, "w")
    if not file then
        vim.notify("Erro ao criar arquivo temporário", vim.notify.ERROR)
        return nil
    end

    file:write("Este é um arquivo temporário gerado por Lua.\n")
    file:close()

    vim.notify("Arquivo temporário criado: " .. temp_path, vim.notify.INFO)
    return temp_path
end

return M
