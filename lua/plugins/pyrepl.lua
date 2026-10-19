
return {
  "dangooddd/pyrepl.nvim",

  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },

  config = function()
    -- load custom Pyrepl modules
    package.loaded["pyrepl.core"] = nil
    package.loaded["pyrepl.image"] = nil
    package.preload["pyrepl.core"] = function()
      return require("custom.pyrepl.core")
    end
    package.preload["pyrepl.image"] = function()
      return require("custom.pyrepl.image")
    end
    local pyrepl = require("pyrepl")

    pyrepl.setup({
      split_horizontal = false,
      split_ratio = 0.5,
      style_integration = true,

      image_provider = "placeholders",
      image_max_history = 1000,
      image_width_ratio = 0.5,
      image_height_ratio = 0.5,

      jupytext_hook = true,
    })

    vim.keymap.set("n", "<leader>jo", pyrepl.open_repl)
    vim.keymap.set("n", "<leader>jh", pyrepl.hide_repl)
    vim.keymap.set("n", "<leader>jc", pyrepl.close_repl)
    vim.keymap.set("n", "<leader>jt", pyrepl.toggle_repl)
    vim.keymap.set({ "n", "t" }, "<C-j>", pyrepl.toggle_repl_focus)
    vim.keymap.set("n", "<leader>jb", pyrepl.send_buffer)
    vim.keymap.set("n", "<leader>jl", pyrepl.send_cell)
    vim.keymap.set("v", "<leader>jv", pyrepl.send_visual)
    vim.keymap.set("n", "<leader>jp", pyrepl.step_cell_backward)
    vim.keymap.set("n", "<leader>jn", pyrepl.step_cell_forward)
    vim.keymap.set("n", "<leader>ji", pyrepl.open_image_history)
    vim.keymap.set("n", "<leader>jv", function()
      require("pyrepl.image").toggle_layout()
    end, { desc = "Toggle Pyrepl layout" })
  end,
}

