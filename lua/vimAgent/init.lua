local M = {}

M.url = "http://localhost:11434/api/generate"
local ui = require("vimAgent.ui")

function M.set_file()
    local buf = vim.api.nvim_get_current_buf()
    local name = vim.api.nvim_buf_get_name(buf)
    ui.append_status(name)
end

function M.simple_curl_p(prompt)
    local json = vim.fn.json_encode({
        model = "codegemma:7b",
        think = false,
        prompt = prompt,
    })

    vim.system({ "curl", "-N", M.url, "-H", "Content-Type: application/json", "-d", json }, {
        stdout = function(_, data)
            if not data then
                return
            end

            local ok, decode = pcall(vim.json.decode, data)
            if not ok then
                return
            end

            if decode.response then
                ui.append_message(decode.response)
            end
        end,
    })

    ui.append_message_line("")
end

function M.chat()
    local prompt = vim.fn.input("chat:")
    ui.open_file()
    M.simple_curl_p(prompt)
end

function M.setup()
    vim.api.nvim_create_user_command("OpenFile", function()
        ui.open_file()
    end, {})

    vim.api.nvim_create_user_command("CloseFile", function()
        ui.close_chat()
    end, {})

    vim.api.nvim_create_user_command("Chat", function()
        M.chat()
    end, {})
    vim.api.nvim_create_user_command("SetFile", function()
        M.set_file()
    end, {})
end

return M
