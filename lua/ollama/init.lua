M.temp_path = M.temp_file .. ".tmp.md"




function M.create_temp_file()


    local file = io.open(M.temp_path, "w")

    if not file then
        vim.notify("Erro ao criar arquivo", vim.log.levels.ERROR)
        return
    end

    file:write("teste\n")
    file:close()

    vim.notify(M.temp_path, vim.log.levels.INFO)

    vim.cmd("edit " .. M.temp_path)
end

function M.chat()
    local prompt = vim.fn.input("Chat > ")

    print("Você escreveu: " .. prompt)
end

function M.curl_lms()
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

    vim.system({
        "curl",
        "-s",
        "http://localhost:1234/v1/chat/completions",
        "-H",
        "Content-Type: application/json",
        "-d",
        json
    }, { text = true }, function(result)
        -- Esse callback roda quando o curl terminar, sem bloquear
        vim.schedule(function()
            local ok, response = pcall(vim.json.decode, result.stdout)
            if not ok then
                vim.notify("Erro ao decodificar resposta", vim.log.levels.ERROR)
                return
            end

            local files = io.open(M.temp_path, "w")
            if not files then return end
            files:write("new\n")
            files:write(response.choices[1].message.content or "", "\n")
            files:close()

            vim.notify(M.temp_path, vim.log.levels.INFO)
            vim.cmd("edit " .. M.temp_path)
        end)
    end)
end
function M.setup()
    vim.api.nvim_create_user_command("CreateTempFile", function()
        M.create_temp_file()
    end, {})
    vim.api.nvim_create_user_command("Chat", function()
        M.curl_lms()
    end, {})
end

return M
