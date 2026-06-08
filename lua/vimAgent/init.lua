local M = {}

M.url = "http://localhost:11434/api/chat"
local ui = require("vimAgent.ui")
local tools = require("vimAgent.tools")

function M.set_file()
    local buf = vim.api.nvim_get_current_buf()
    local name = vim.api.nvim_buf_get_name(buf)
    ui.append_status(name)
end

function M.simple_curl_p(prompt)
    local messages = {
        {
            role = "user",
            content = prompt,
        },
    }
    local json = vim.fn.json_encode({
        model = "qwen3:8b",
        think = false,
        messages = messages,
        tools = tools.tools,
    })

    vim.system({ "curl", "-N", M.url, "-H", "Content-Type: application/json", "-d", json }, {
        stdout = function(_, data)
            if not data then
                return
            end

            local ok, decode = pcall(vim.json.decode, data)

            if not ok then
                print(data)
                return
            end

            print(data)

            if decode.message and decode.message.content then
                ui.append_message(decode.message.content)

                if decode.message.tool_calls then
                    local tools = decode.message.tool_calls[1]
                    print(tools["function"].name)
                    if tools["function"].name == "readfile" then
                    end
                end
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
