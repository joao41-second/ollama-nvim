local M = {}

M.temp_file = vim.fn.tempname()
M.temp_path = temp_file .. ".tmp"

function M.create_temp_file()

    local file = io.open(M.temp_path, "w")

    if not file then
        vim.notify("Erro ao criar arquivo", vim.log.levels.ERROR)
        return
    end

    file:write("teste\n")
    file:close()

    vim.notify(temp_path, vim.log.levels.INFO)

    vim.cmd("edit " .. temp_path)
end

function M.chat()
    local prompt = vim.fn.input("Chat > ")

    print("Você escreveu: " .. prompt)
    return( prompt)
end

function M.curl_lms( mens)

    local prompt = vim.fn.input("Chat > ")

    local json = vim.fn.json_encode({
        model = "qwen/qwen3-vl-4b",
        messages = {
            {
                role = "user",
                content = prompt
            }
        }
    })
    local result = vim.system({
        "curl",
        "-s",
        "http://localhost:1234/v1/chat/completions",
        "-H",
        "Content-Type: application/json",
        "-d",
        json
    }, { text = true }):wait()

    local files = io.open(M.temp_path or "/tmp/nvim_lms.txt", "w")

    print("Você escreveu: " ..  result.stdout)

    files:write("new\n")
    files:write(result.stdout or "", "\n")
    files:close()

    vim.notify(temp_path, vim.log.levels.INFO)

    vim.cmd("edit " .. temp_path)
end
function M.setup()
    vim.api.nvim_create_user_command("CreateTempFile", function()
        M.create_temp_file()
    end, {})
    vim.api.nvim_create_user_command("Chats", function()
         M.curl_lms()
    end, {})
end

return M
