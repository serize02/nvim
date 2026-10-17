return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      local function on_attach(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
          require("nvim-navic").attach(client, bufnr)
        end
      end

      local servers = {
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                diagnosticMode = "openFilesOnly",
                autoSearchPaths = true,
              },
            },
          },
        },

        clangd = {
          cmd = { "clangd" },
          filetypes = { "c", "cpp", "objc", "objcpp" },
          root_markers = {
            "compile_commands.json",
            "compile_flags.txt",
            ".git",
          },
        },

        marksman = {
          cmd = { "marksman", "server" },
          filetypes = { "markdown", "markdown.mdx" },
          root_markers = { ".marksman.toml", ".git" },
        },

        jdtls = {
          settings = {
            java = {
              configuration = {
                updateBuildConfiguration = "automatic",
              },
            },
          },
        },

        kotlin_lsp = {
          single_file_support = false,
        },
      }

      for name, config in pairs(servers) do
        config.capabilities = capabilities
        config.on_attach = on_attach

        vim.lsp.config(name, config)
        vim.lsp.enable(name)
      end

      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
      vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Find references" })
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
      vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })

      vim.keymap.set("n", "[d", function()
        vim.diagnostic.jump({ count = -1, float = true })
      end, { desc = "Previous diagnostic" })

      vim.keymap.set("n", "]d", function()
        vim.diagnostic.jump({ count = 1, float = true })
      end, { desc = "Next diagnostic" })
    end,
  },
}
