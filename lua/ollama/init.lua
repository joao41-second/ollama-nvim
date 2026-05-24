local M = {}

function M.create_temp_file()
    local temp_file = vim.fn.tempname()
    local temp_path = temp_file .. ".tmp"

    local file = io.open(temp_path, "w")

    if not file then
        vim.notify("Erro ao criar arquivo", vim.log.levels.ERROR)
        return
    end

    file:write("teste\n")
    file:close()

    vim.notify(temp_path, vim.log.levels.INFO)

    vim.cmd("edit " .. temp_path)
end

function M.setup()
    vim.api.nvim_create_user_command("CreateTempFile", function()
        M.create_temp_file()
    end, {})
end

return M
