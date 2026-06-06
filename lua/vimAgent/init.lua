local M = {}

M.state = {
    buf = nil,
    win = nil,
}

M.temp_file = vim.fn.tempname()
M.temp_path = M.temp_file .. ".tmp.md" -- os .. e concatenasao
M.width = 40

function M.append_message(lines)
    local buf = M.state.buf

    if not buf or not vim.api.nvim_buf_is_valid(buf) then
        return
    end

    vim.bo.modifiable = true

    vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)

    vim.bo.modifiable = false

    local cursor = vim.api.nvim_buf_line_count(buf)
    vim.api.nvim_win_set_cursor(M.state.win, { cursor, 0 })
end

local function open_chat_status()
    local buf = vim.api.nvim_create_buf(false, true)

    vim.cmd("split")

    local win = vim.api.nvim_get_current_win()

    vim.api.nvim_win_set_width(win, M.width)
    vim.api.nvim_win_set_height(win, 10)
    vim.api.nvim_win_set_buf(win, buf)

    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].swapfile = false
    vim.bo[buf].buflisted = false
    vim.bo[buf].filetype = "md"

    -- read only
    vim.bo[buf].modifiable = false
    vim.bo[buf].readonly = true
end

local function open_file()
    if M.state.win then
        return
    end

    local buf = vim.api.nvim_create_buf(false, true)

    vim.cmd("vsplit")
    vim.cmd("wincmd L ")

    local win = vim.api.nvim_get_current_win()

    vim.api.nvim_win_set_width(win, M.width)
    vim.api.nvim_win_set_buf(win, buf)

    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].swapfile = false
    vim.bo[buf].buflisted = false
    vim.bo[buf].filetype = "md"

    -- read only
    vim.bo[buf].modifiable = false
    vim.bo[buf].readonly = true

    M.state.buf = buf
    M.state.win = win

    M.append_message({
        "╭────────────────────────────╮",
        "│         My Chat            │",
        "╰────────────────────────────╯",
        "",
        "#AI: Olá 👋",
        "",
    })
    open_chat_status()
end

local function close_chat()
    if M.state.win and vim.api.nvim_win_is_valid(M.state.win) then
        vim.api.nvim_win_close(M.state.win, true)
    end

    M.state.win = nil
end

function M.setup()
    vim.api.nvim_create_user_command("OpenFile", function()
        open_file()
    end, {})
    vim.api.nvim_create_user_command("CloseFile", function()
        close_chat()
    end, {})
end
return M
