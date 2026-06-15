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
    M.request(messages)
end

function M.request(messages)
    local json = vim.json.encode({
        model = "qwen3:8b",
        think = false,
        messages = messages,
        tools = tools.tools,
    })
    local var = ""

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

            if decode.message and decode.message.content then
                ui.append_message(decode.message.content)

                table.insert(messages, decode.message)

                if decode.message.tool_calls then
                    local tool = decode.message.tool_calls[1]
                    var = tools.tools_use(tool["function"].name, tool["function"].arguments)
                    table.insert(messages, { role = "tool", tool_call_id = tools.id, content = var })
                    M.request(messages)
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
