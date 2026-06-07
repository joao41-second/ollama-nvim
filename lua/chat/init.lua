-- lua/mychat/init.lua

local M = {}

M.state = {
    buf = nil,
    win = nil,
}

-- adiciona mensagens ao chat
function M.append_message(lines)
    local buf = M.state.buf

    if not buf or not vim.api.nvim_buf_is_valid(buf) then
        return
    end

    -- desbloqueia buffer
    vim.bo[buf].modifiable = true

    -- adiciona linhas
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)

    -- volta a bloquear
    vim.bo[buf].modifiable = false

    -- scroll automático para baixo
    local line_count = vim.api.nvim_buf_line_count(buf)

    vim.api.nvim_win_set_cursor(M.state.win, {
        line_count,
        0,
    })
end

function M.open_chat()
    -- se já existir, foca
    if M.state.win and vim.api.nvim_win_is_valid(M.state.win) then
        vim.api.nvim_set_current_win(M.state.win)
        return
    end

    -- cria buffer
    local buf = vim.api.nvim_create_buf(false, true)

    -- abre split vertical
    vim.cmd("vsplit")

    -- move para direita
    vim.cmd("wincmd L")

    local win = vim.api.nvim_get_current_win()

    -- largura fixa
    vim.api.nvim_win_set_width(win, 40)

    -- associa buffer
    vim.api.nvim_win_set_buf(win, buf)

    --------------------------------------------------
    -- BUFFER OPTIONS
    --------------------------------------------------

    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].swapfile = false
    vim.bo[buf].buflisted = false
    vim.bo[buf].filetype = "mychat"

    -- read only
    vim.bo[buf].modifiable = false
    vim.bo[buf].readonly = true

    --------------------------------------------------
    -- WINDOW OPTIONS
    --------------------------------------------------

    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].signcolumn = "no"
    vim.wo[win].wrap = true
    vim.wo[win].cursorline = false

    -- impede resize automático
    vim.wo[win].winfixwidth = true

    --------------------------------------------------
    -- KEYMAPS
    --------------------------------------------------

    -- fechar chat
    vim.keymap.set("n", "q", function()
        M.close_chat()
    end, { buffer = buf })

    --------------------------------------------------
    -- ESTADO
    --------------------------------------------------

    M.state.buf = buf
    M.state.win = win

    --------------------------------------------------
    -- CONTEÚDO INICIAL
    --------------------------------------------------

    M.append_message({
        "╭────────────────────────────╮",
        "│         My Chat            │",
        "╰────────────────────────────╯",
        "",
        "AI: Olá 👋",
        "",
    })
end

function M.close_chat()
    if M.state.win and vim.api.nvim_win_is_valid(M.state.win) then
        vim.api.nvim_win_close(M.state.win, true)
    end

    M.state.win = nil
end

function M.toggle_chat()
    if M.state.win and vim.api.nvim_win_is_valid(M.state.win) then
        M.close_chat()
    else
        M.open_chat()
    end
end

return M
