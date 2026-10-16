-- https://github.com/sheng-tse/jupynvim
return {
  {
    "sheng-tse/jupynvim",
    build = function(plugin)
      local install = loadfile(plugin.dir .. "/lua/jupynvim/install.lua")()
      install.run(plugin)
    end,
    config = function()
      require("jupynvim").setup({
        -- Verbosity for both the Rust backend and the Lua frontend.
        log_level = "info",  -- trace, debug, info, warn, or error

        -- How code-cell outputs and embedded markdown images are rendered.
        --   "placeholder" uses the Kitty Unicode placeholder protocol. The image
        --                 is anchored to buffer text and stays put when scrolling.
        --                 Required for animated GIFs.
        --   "kitty"       uses direct kitty placement. Lives at fixed screen
        --                 coordinates and doesn't follow scroll.
        --   "chafa"       is an ASCII-art fallback. Use this on terminals without
        --                 graphics support.
        image_renderer = "placeholder",

        -- Inline image grid size in terminal cells (rows x cols). Default 16x48;
        -- bump for sharper output on large terminals or shrink for compact display.
        image_rows = 16,
        image_cols = 48,

        -- Longest output rendered per cell. A longer one shows its head and tail
        -- with a marker between them, and <leader>no expands it. The .ipynb keeps
        -- everything. 0 renders all of it.
        max_output_lines = 500,

        -- Override the path to the jupynvim-core binary. Auto-detected from the
        -- plugin directory if unset.
        core_path = nil,

        -- Per-action keymap overrides. A string replaces the default lhs, a table
        -- sets the lhs and the mode, and `false` disables the binding. The full
        -- action list lives in lua/jupynvim/notebook/keymaps.lua. <S-CR> and
        -- <C-CR> are bound in normal and insert mode; a replacement that starts
        -- with a printable key, like a space leader, stays out of insert mode
        -- unless you pass `mode`, so typing that key in a cell never stalls.
        keymaps = {
          -- example: rebind run-and-advance, in normal mode only as noted above
          -- run_advance = "<leader>jr",
          --
          -- example: rebind run-and-stay and pick its modes yourself
          -- run_stay = { mode = { "n", "i" }, lhs = "<C-s>" },
          --
          -- example: disable move-cell-up
          -- move_up = false,
        },

        -- Skip the entire default keymap set if you want to bind everything yourself.
        disable_default_keymaps = false,

        -- Walk up from the notebook's directory to find a `.venv/bin/python` (or
        -- `.venv/Scripts/python.exe` on Windows) and use it as the kernel
        -- interpreter when ipykernel is installed there. Bypasses needing to
        -- register a per-project user kernel. Set false to use only registered
        -- kernelspecs.
        auto_venv = true,

        -- LSP servers to skip on jupynvim buffers. Useful for servers that
        -- misbehave on `.ipynb` URIs without advertising notebook capability.
        -- Notebook-aware servers (anything with notebookDocumentSync) are
        -- handled correctly via the LSP notebook protocol and don't need to be
        -- listed here.
        lsp_blocklist = {},

        -- Restore animated (smooth) scrolling inside notebook buffers. Off by
        -- default so cell navigation is one-shot and frames stay aligned. Set true
        -- if you use snacks.scroll and want it back in notebooks.
        smooth_scroll = false,

        -- Named remote profiles for :JupynvimConnect / :JupynvimOpenRemote. Key is
        -- the alias; value is the connection spec.
        remote = {
          -- cluster = {
            --   host = "user@cluster.example.edu",  -- or an ~/.ssh/config Host
            --   core_path = "~/.local/bin/jupynvim-core",
            --   -- ssh_args = { "-J", "jumpbox" },
            -- },
          },

          -- Borrowed only while a remote session is active. If you already have a
          -- mapping for one of these, jupynvim takes it on connect and gives it back
          -- exactly on disconnect; if you don't, it stays bound and falls back to the
          -- local equivalent. Set a group to {} to leave those keys alone entirely.
          explorer_keys     = { "<leader>e" },  -- remote tree at the project root
          explorer_cwd_keys = { "<leader>E" },  -- remote tree at the remote cwd
          terminal_keys = { "<c-/>", "<c-_>" },           -- toggle a remote PTY
          pick_keys = {
            files = { "<leader>ff", "<leader><space>" },
            grep  = { "<leader>/", "<leader>sg" },
          },
        }) 
      end,
    }
  }
