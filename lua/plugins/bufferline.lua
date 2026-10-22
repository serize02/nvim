return {
  {
    "akinsho/bufferline.nvim",
    version = "*",

    config = function()
      require("bufferline").setup({
        options = {
          show_buffer_icons = true,
          show_buffer_close_icons = false,
          show_close_icon = false,
          separator_style = "thin",
          offsets = {
            {
              filetype = "NvimTree",
              text = function()
                return " 󰉋 " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
              end,
              text_align = "left",
              separator = true,
              highlight = "Directory",
            },
          },        
        },
      })
    end,
  },
}
