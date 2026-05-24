local M = {}
M.temp_file = vim.fn.tempname()
M.temp_path = M.temp_file .. ".tmp"


function read_project()
  local cwd = vim.fn.getcwd()
  local content = {}

  local files = vim.fn.globpath(cwd, "**/*", false, true)

  for _, file in ipairs(files) do
    local f = io.open(file, "r")

    if f then
      local text = f:read("*a")
      f:close()

      -- evita binários gigantes
      if text and #text < 20000 then
        table.insert(content, "FILE: " .. file .. "\n" .. text)
      end
    end
  end

  return table.concat(content, "\n\n")
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

function M.chat()
    local prompt = vim.fn.input("Chat > ")

    print("Você escreveu: " .. prompt)
end

function M.curl_lms()


    local prompt = vim.fn.input("Chat > ")
    local project = read_project()

    local json = vim.fn.json_encode({
        model = "qwen/qwen3-vl-4b",
        messages = {
            {
                role = "user",
                content =  "PROJECT FILES:\n" .. project .. "\n\nUSER QUESTION:\n" .. prompt
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

    local files = io.open(M.temp_path , "w")

    local response = vim.json.decode(result.stdout)

    files:write("new\n")
    files:write(response.choices[1].message.content or "", "\n")
    files:close()

    vim.notify(M.temp_path, vim.log.levels.INFO)

    vim.cmd("edit " .. M.temp_path)
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
