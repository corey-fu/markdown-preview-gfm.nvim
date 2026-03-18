local M = {}

local defaults = {
  glow_path = vim.fn.expand("$HOME/go/bin/glow"),
  gfm_preview_path = vim.fn.expand("$HOME/go/bin/gh-gfm-preview"),
  filetypes = { "markdown", "text" },
  keymaps = {
    browser = "<Leader>P",
    inline = "<Leader>M",
  },
}

-- Launch gh-gfm-preview (browser-based GitHub-flavored markdown preview).
-- Kills the server process when the buffer is unloaded.
local function preview_browser(opts)
  local file = vim.fn.expand("%:p")
  local process = vim.system(
    -- Invoke the binary directly (not via `gh gfm-preview`) so SIGTERM
    -- reaches gh-gfm-preview itself rather than only the gh wrapper.
    { opts.gfm_preview_path, file },
    {},
    function(out)
      vim.notify("Markdown preview exited with code: " .. out.code, vim.log.levels.INFO)
    end
  )

  vim.api.nvim_create_autocmd({ "BufUnload", "BufDelete" }, {
    buffer = vim.api.nvim_get_current_buf(),
    once = true,
    callback = function()
      process:kill("sigterm")
      process:wait(500)
    end,
  })
end

-- Open a right-hand terminal split and render the current file with glow.
-- Press q or <Esc> inside the split to close it.
local function preview_inline(opts)
  local file = vim.fn.expand("%:p")
  local src_buf = vim.api.nvim_get_current_buf()

  vim.cmd("vsplit")
  local term_win = vim.api.nvim_get_current_win()
  vim.fn.jobstart({ opts.glow_path, file }, {
    term = true,
    on_exit = function()
      if vim.api.nvim_win_is_valid(term_win) then
        vim.api.nvim_win_close(term_win, true)
      end
    end,
  })

  vim.api.nvim_create_autocmd({ "BufUnload", "BufDelete" }, {
    buffer = src_buf,
    once = true,
    callback = function()
      if vim.api.nvim_win_is_valid(term_win) then
        vim.api.nvim_win_close(term_win, true)
      end
    end,
  })

  local term_buf = vim.api.nvim_get_current_buf()
  for _, key in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", key, function()
      if vim.api.nvim_win_is_valid(term_win) then
        vim.api.nvim_win_close(term_win, true)
      end
    end, { buffer = term_buf, nowait = true })
  end
end

function M.setup(user_opts)
  local opts = vim.tbl_deep_extend("force", defaults, user_opts or {})

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("markdown_preview", { clear = true }),
    pattern = opts.filetypes,
    callback = function()
      local km = opts.keymaps

      if km.browser then
        vim.keymap.set("n", km.browser, function()
          preview_browser(opts)
        end, { desc = "Markdown preview (browser)", buffer = true })
      end

      if km.inline then
        vim.keymap.set("n", km.inline, function()
          preview_inline(opts)
        end, { desc = "Markdown preview (inline / glow)", buffer = true })
      end

      vim.api.nvim_buf_create_user_command(0, "MarkdownPreview", function()
        preview_browser(opts)
      end, { desc = "Markdown preview (browser)" })

      vim.api.nvim_buf_create_user_command(0, "MarkdownPreviewInline", function()
        preview_inline(opts)
      end, { desc = "Markdown preview (inline / glow)" })
    end,
  })
end

return M
