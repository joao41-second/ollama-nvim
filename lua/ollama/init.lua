local M = {}
M.temp_file = vim.fn.tempname()
M.temp_path = M.temp_file .. ".tmp"

local function get_project_structure()
    -- conta ficheiros
    local count_result = vim.system({
        "find", ".", "-type", "f", "-not", "-path", "*/.git/*"
    }, { text = true }):wait()

    local files = vim.split(count_result.stdout or "", "\n", { trimempty = true })

    -- se tiver muitos ficheiros, mostra só diretórios raiz
    if #files > 50 then
        local dirs_result = vim.system({
            "find", ".", "-maxdepth", "1", "-type", "d", "-not", "-path", "./.git"
        }, { text = true }):wait()

        return dirs_result.stdout or ""
    end

    -- caso contrário devolve todos os ficheiros
    return count_result.stdout or ""
end

local function read_file(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local content = f:read("*a")
    f:close()
    return content
end

local tools = {
    {
        type = "function",  -- faltava isto!
        ["function"] = {    -- a definição vai dentro de "function"
            name = "read_file",
            description = "Lê o conteúdo de um ficheiro do projeto",
            parameters = {  -- era "input_schema", agora é "parameters"
                type = "object",
                properties = {
                    path = {
                        type = "string",
                        description = "Caminho do ficheiro relativo à raiz do projeto"
                    }
                },
                required = { "path" }
            }
        }
    }
}

local function run_agent(prompt, callback)
    local project_structure = get_project_structure()
    local messages = {
        {
            role = "user",
            content = "Estrutura do projeto:\n" .. project_structure .. "\n\n" .. prompt
        }
    }

    local function call_api()
        local json = vim.fn.json_encode({
            model = "qwen/qwen3-4b-2507",
            messages = messages,
            tools = tools
        })

        vim.system({
            "curl", "-s",
            "http://localhost:1234/v1/chat/completions",
            "-H", "Content-Type: application/json",
            "-d", json
        }, { text = true }, function(result)
            vim.schedule(function()
                local ok, response = pcall(vim.json.decode, result.stdout)
                if not ok then
                    vim.notify("Erro ao decodificar resposta", vim.log.levels.ERROR)
                    return
                end

                local choice = response.choices[1]
                local msg = choice.message

                -- Se a IA quer usar uma tool
                if choice.finish_reason == "tool_calls" and msg.tool_calls then
                    -- Adiciona a resposta da IA ao histórico
                    table.insert(messages, msg)

                    for _, tool_call in ipairs(msg.tool_calls) do
                        if tool_call["function"].name == "read_file" then
                            local args = vim.json.decode(tool_call["function"].arguments)
                            local file_content = read_file(args.path)

                            vim.notify("IA pediu ficheiro: " .. args.path, vim.log.levels.INFO)

                            -- Adiciona o resultado da tool ao histórico
                            table.insert(messages, {
                                role = "tool",
                                tool_call_id = tool_call.id,
                                content = file_content or "Ficheiro não encontrado: " .. args.path
                            })
                        end
                    end

                    -- Chama a API novamente com o contexto atualizado
                    call_api()

                else
                    -- Resposta final
                    callback(msg.content or "")
                end
            end)
        end)
    end

    call_api()
end


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



function M.curl_lms()
    local prompt = vim.fn.input("Chat > ")

    run_agent(prompt, function(answer)
        local f = io.open(M.temp_path, "w")
        if not f then return end
        f:write(answer .. "\n")
        f:close()

        vim.notify(M.temp_path, vim.log.levels.INFO)
        vim.cmd("edit " .. M.temp_path)
    end)
end

function M.setup()
    vim.api.nvim_create_user_command("Chat", function()
        M.curl_lms()
    end, {})
  vim.api.nvim_create_user_command("CreateTempFile", function()
        M.create_temp_file()
    end, {})
end

return M
