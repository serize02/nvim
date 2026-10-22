return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
  },
  config = function()
    require("lualine").setup({
      options = { 
        icons_enabled = true,
        theme = "onedark"
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      winbar = {
        lualine_c = {
          {
            function()
              local ok, navic = pcall(require, "nvim-navic")
              return ok and navic.is_available() and navic.get_location() or ""
            end,
          },
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      -- tabline = {
      --   lualine_a = {{ "buffers", show_filename_only = true } },
      --   lualine_x = {},
      --   lualine_y = {},
      --   lualine_z = { "tabs" },
      -- },
      extensions = {},
    })
  end,
}
