local M = {}

M.state = {
    buf = nil,
    bug_status = nil,
    win = nil,
}

M.temp_file = vim.fn.tempname()
M.temp_path = M.temp_file .. ".tmp.md"
M.width = 40
function M.append_status(name)
    vim.schedule(function()
        local buf = M.state.bug_status

        if not buf or not vim.api.nvim_buf_is_valid(buf) then
            return
        end

        local cursor = vim.api.nvim_buf_line_count(buf)
        local last_line = cursor - 1
        local last_col = #vim.api.nvim_buf_get_lines(buf, last_line, last_line + 1, false)[1]

        vim.api.nvim_set_option_value("modifiable", true, { buf = buf })

        local cleaned = name:gsub("\n", " ")
        vim.api.nvim_buf_set_text(buf, last_line, last_col, last_line, last_col, { cleaned })

        vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

        cursor = vim.api.nvim_buf_line_count(buf)
        vim.api.nvim_win_set_cursor(M.state.win, { cursor, 0 })
    end)
end

function M.append_message(lines)
    vim.schedule(function()
        local buf = M.state.buf

        if not buf or not vim.api.nvim_buf_is_valid(buf) then
            return
        end

        local cursor = vim.api.nvim_buf_line_count(buf)
        local last_line = cursor - 1
        local last_col = #vim.api.nvim_buf_get_lines(buf, last_line, last_line + 1, false)[1]

        vim.api.nvim_set_option_value("modifiable", true, { buf = buf })

        local cleaned = lines:gsub("\n", " ")
        vim.api.nvim_buf_set_text(buf, last_line, last_col, last_line, last_col, { cleaned })
        if string.find(lines, "\n") then
            M.append_message_line("")
        end

        vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

        cursor = vim.api.nvim_buf_line_count(buf)
        vim.api.nvim_win_set_cursor(M.state.win, { cursor, 0 })
    end)
end

function M.append_message_line(lines)
    vim.schedule(function()
        local buf = M.state.buf

        if not buf or not vim.api.nvim_buf_is_valid(buf) then
            return
        end

        vim.api.nvim_set_option_value("modifiable", true, { buf = buf })

        local cleaned = lines:gsub("\n", " ")
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, { cleaned })

        vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

        local cursor = vim.api.nvim_buf_line_count(buf)
        vim.api.nvim_win_set_cursor(M.state.win, { cursor, 0 })
    end)
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
    vim.bo[buf].filetype = ".md"
    vim.bo[buf].modifiable = false
    vim.bo[buf].readonly = true

    M.state.bug_status = buf
end

function M.open_file()
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
    vim.bo[buf].filetype = ".md"
    vim.bo[buf].modifiable = false
    vim.bo[buf].readonly = true

    M.state.buf = buf
    M.state.win = win

    M.append_message_line("╭────────────────────────────╮")
    M.append_message_line("│         My Chat            │")
    M.append_message_line("╰────────────────────────────╯")
    M.append_message_line("")
    open_chat_status()
end

function M.close_chat()
    if M.state.win and vim.api.nvim_win_is_valid(M.state.win) then
        vim.api.nvim_win_close(M.state.win, true)
    end

    M.state.win = nil
    -- M.state.buf = nil
end

return M
