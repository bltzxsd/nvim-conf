local autocmd = vim.api.nvim_create_autocmd
local alacritty_mod = require "custom.configure_alacritty"

-- Auto resize panes when resizing nvim window
-- autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })

-- Modify padding when Neovim starts
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		alacritty_mod.modify_alacritty_config()
	end,
})

if vim.fn.has "wsl" == 1 then
	if vim.fn.executable "wl-copy" == 0 then
		print "wl-clipboard not found, clipboard integration won't work"
	else
		vim.g.clipboard = {
			name = "wl-clipboard (wsl)",
			copy = {
				["+"] = "wl-copy --foreground --type text/plain",
				["*"] = "wl-copy --foreground --primary --type text/plain",
			},
			paste = {
				["+"] = function()
					return vim.fn.systemlist('wl-paste --no-newline|sed -e "s/\r$//"', { "" }, 1) -- '1' keeps empty lines
				end,
				["*"] = function()
					return vim.fn.systemlist('wl-paste --primary --no-newline|sed -e "s/\r$//"', { "" }, 1)
				end,
			},
			cache_enabled = true,
		}
	end
end

autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
	command = "if mode() != 'c' | checktime | endif",
	pattern = { "*" },
})

if not vim.lsp.inlay_hint.is_enabled() then
	vim.lsp.inlay_hint.enable(true)
end

-- Restore padding when Neovim exits
vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		alacritty_mod.restore_alacritty_config()
	end,
})
