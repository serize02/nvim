return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons",},
    config = function()
      local api = require("nvim-tree.api")

      api.events.subscribe(api.events.Event.FileCreated, function(file)
        vim.cmd("edit " .. vim.fn.fnameescape(file.fname))
      end)

      require("nvim-tree").setup({
        view = { width = 30 },
        live_filter = { always_show_folders = false, },
        update_focused_file = {
          enable = true,
          update_root = false,
        },
        renderer = {
          root_folder_label = false,
          indent_markers = { enable = true },
          icons = {
            glyphs = {
              folder = {
                arrow_closed = ">",
                arrow_open = "v",
              },
            },

            show = {
              file = true,
              folder = false,
              folder_arrow = true,
              git = false,
            },
          },
        },
      })

      vim.keymap.set("n", "<leader>fe", ":NvimTreeToggle<CR>")
    end,
  },
}
