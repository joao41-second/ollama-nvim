local M = {}

M.temp_file = vim.fn.tempname()
M.temp_path = M.temp_file .. ".tmp.md"

local function open_file()
    local file = io.open(M.temp_path, "w")

    if not file then
        vim.notify("error in create file", vim.log.levels.ERROR)
        return
    end

    file:write("start the game\n")
    file:close()

    vim.notify("open.file", vim.log.levels.INFO)

    vim.cmd("edit" .. M.temp_path)

    local bufnr = vim.fn.bufnr(M.temp_path)
    vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
    vim.api.nvim_set_option_value("readonly", true, { buf = bufnr })
end

function M.setup()
    vim.api.nvim_create_user_command("OpenFile", function()
        open_file()
    end, {})
end
return M
