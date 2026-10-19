local M = {}

local config = require("pyrepl.config")
local group = vim.api.nvim_create_augroup("PyreplImage", { clear = true })
local ns = vim.api.nvim_create_namespace("PyreplImage")

---@type pyrepl.ImageHistoryState
local state = {
  history = {},
  closing = false,
  idx = 1,
  buf = nil,
  win = nil,
}

local layout = "vertical"

---Open a floating window for image display.
---Placed in the top-right corner in a vertical layout.
---Placed in the bottom-right corner in a horizontal layout.
---@param buf integer
---@return integer
-- local function open_image_win(buf)
  --     local width = vim.o.columns
  --     local height = vim.o.lines
  --
  --     local float_width = math.max(1, math.floor(width * config.get_state().image_width_ratio))
  --     local float_height = math.max(1, math.floor(height * config.get_state().image_height_ratio))
  --
  --     local col = math.max(0, width - float_width)
  --     -- bottom-right corner for split_horizontal, top-right corner otherwise
  --     -- subtract 2 to take command line into account
  --     local row = math.max(0, config.get_state().split_horizontal and height - float_height - 2 or 0)
  --
  --     -- effective window size (without borders)
  --     -- subtract 2 to take borders into account
  --     local opts = {
    --         relative = "editor",
    --         width = float_width - 2,
    --         height = float_height - 2,
    --         row = row,
    --         col = col,
    --         style = "minimal",
    --     }
    --
    --     local win = vim.api.nvim_open_win(buf, false, opts)
    --     vim.wo[win].winhl =
    --         "NormalFloat:PyreplImageNormal,FloatBorder:PyreplImageBorder,FloatTitle:PyreplImageTitle"
    --
    --     return win
    -- end


    -- NEW: create a dedicated plots split above the REPL.
    
local function open_image_win(buf)
  local repl_win = require("pyrepl.core").get_win()

  if not repl_win or not vim.api.nvim_win_is_valid(repl_win) then
    error("[pyrepl] Open the REPL first")
  end

  local opts = {
    win = repl_win,
  }

  if layout == "horizontal" then
    -- CODE
    -- REPL | PLOTS
    opts.split = "right"
    opts.width = math.max(
      10,
      math.floor(vim.api.nvim_win_get_width(repl_win) * 0.5)
    )
  else
    -- CODE | PLOTS
    --      | REPL
    opts.split = "above"
    opts.height = math.max(
      6,
      math.floor(vim.api.nvim_win_get_height(repl_win) * 0.5)
    )
  end

  local win = vim.api.nvim_open_win(buf, false, opts)

  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].wrap = false

  return win
end

    ---@param idx integer
    local function pop_history(idx)
      if state.history[idx] then
        state.history[idx]:delete()
        table.remove(state.history, idx)
        state.idx = math.min(state.idx, #state.history)
      end
    end

    ---@param img_base64 string
    local function push_history(img_base64)
      if #state.history >= config.get_state().image_max_history then
        pop_history(1)
      end
      -- table.insert(state.history, config.get_image_provider().create(img_base64))
      local image = config.get_image_provider().create(img_base64)
      image.original_png = img_base64
      table.insert(state.history, image)
    end

    ---Clear image when buffer is wiped/deleted.
    local function setup_buf_autocmds()
      if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then
        return
      end

      vim.api.nvim_clear_autocmds({
        event = { "BufWipeout", "BufDelete" },
        group = group,
        buffer = state.buf,
      })

      vim.api.nvim_create_autocmd({ "BufWipeout", "BufDelete" }, {
        group = group,
        buffer = state.buf,
        callback = function()
          M.close_image_history()
        end,
        once = true,
      })
    end

    ---Clear image when window is closed.
    local function setup_win_autocmds()
      if not (state.win and vim.api.nvim_win_is_valid(state.win)) then
        return
      end

      vim.api.nvim_clear_autocmds({
        event = "WinClosed",
        group = group,
        pattern = tostring(state.win),
      })

      vim.api.nvim_create_autocmd("WinClosed", {
        group = group,
        pattern = tostring(state.win),
        callback = function()
          M.close_image_history()
        end,
        once = true,
      })
    end

    local function setup_keybinds()
      if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then
        return
      end

      local opts = { noremap = true, silent = true, nowait = true, buffer = state.buf }

      -- show previous image
      vim.keymap.set("n", "j", function()
        if state.idx > 1 then
          M.open_image_history(state.idx - 1, true)
        end
      end, opts)

      vim.keymap.set("n", "h", function()
        if state.idx > 1 then
          M.open_image_history(state.idx - 1, true)
        end
      end, opts)

      -- show next image
      vim.keymap.set("n", "k", function()
        if state.idx < #state.history then
          M.open_image_history(state.idx + 1, true)
        end
      end, opts)

      vim.keymap.set("n", "l", function()
        if state.idx < #state.history then
          M.open_image_history(state.idx + 1, true)
        end
      end, opts)

      -- delete image
      vim.keymap.set("n", "dd", function()
        pop_history(state.idx)
        if #state.history == 0 then
          M.close_image_history()
        else
          M.open_image_history(state.idx)
        end
      end, opts)

      -- Navigate plot history
      vim.keymap.set("n", "<Left>", function()
        if state.idx > 1 then
          M.open_image_history(state.idx - 1, true)
        end
      end, opts)

      vim.keymap.set("n", "<Right>", function()
        if state.idx < #state.history then
          M.open_image_history(state.idx + 1, true)
        end
      end, opts)

      -- Refresh current plot
      vim.keymap.set("n", "r", function()
        if state.history[state.idx] then
          state.history[state.idx]:clear()
          state.history[state.idx]:render(state.buf, state.win)
        end
      end, opts)

      -- Save selected plot
      vim.keymap.set("n", "s", function()
        local image = state.history[state.idx]
        if not image or not image.original_png then
          return
        end

        local directory = vim.fn.expand("~/Pictures/Pyrepl")
        vim.fn.mkdir(directory, "p")

        vim.ui.input({
          prompt = "Save plot as: ",
          default = directory .. "/plot_" .. state.idx .. ".png",
        }, function(path)
          if not path or path == "" then
            return
          end

          path = vim.fn.expand(path)
          vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")

          local ok, err = pcall(function()
            local file = assert(io.open(path, "wb"))
            file:write(vim.base64.decode(image.original_png))
            file:close()
          end)

          if ok then
            vim.notify("Saved: " .. path)
          else
            vim.notify(tostring(err), vim.log.levels.ERROR)
          end
        end)
      end, opts)

      -- exit image
      vim.keymap.set("n", "q", function()
        M.close_image_history()
      end, opts)

      vim.keymap.set("n", "<Esc>", function()
        M.close_image_history()
      end, opts)
    end

    ---@param idx? integer
    ---@param focus? boolean if not passed, equals true
    function M.open_image_history(idx, focus)
      if #state.history == 0 then
        vim.notify(config.get_message_prefix() .. "no image history available", vim.log.levels.WARN)
        return
      end

      -- ensure last image is cleared
      if state.history[state.idx] then
        state.history[state.idx]:clear()
      end
      state.idx = math.max(1, math.min(idx or state.idx, #state.history))

      -- ensure state buf is valid
      if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then
        state.buf = vim.api.nvim_create_buf(false, true)
        setup_buf_autocmds()
        setup_keybinds()
      end

      -- ensure state win is valid
      if not (state.win and vim.api.nvim_win_is_valid(state.win)) then
        state.win = open_image_win(state.buf)
        setup_win_autocmds()
      else
        vim.api.nvim_win_set_buf(state.win, state.buf)
      end

      -- local title = string.format(" History %d/%d ", state.idx, #state.history)
      -- local opts = { title = title, title_pos = "center" }
      -- vim.api.nvim_win_set_config(state.win, opts)

      local title = string.format(
        " Plots [%d/%d] ",
        state.idx,
        #state.history
      )

      vim.wo[state.win].winbar = title
      -- focus history manager or show image once before any cursor movement
      -- if focus or focus == nil then
      --   vim.on_key(nil, ns)
      --   vim.api.nvim_set_current_win(state.win)
      -- else
      --   -- image.nvim can emit <Ignore> code to force redraw
      --   -- ignoring it so window will not auto-close
      --   local ignore = vim.api.nvim_replace_termcodes("<Ignore>", true, false, true)
      --   vim.on_key(function(key)
        --     if key == ignore then
        --       return
        --     end
        --     vim.on_key(nil, ns)
        --     M.close_image_history()
        --   end, ns)
        -- end
        -- Do not automatically close the plots window.
        vim.on_key(nil, ns)

        -- Focus the plots window only when requested.
        if focus or focus == nil then
          vim.api.nvim_set_current_win(state.win)
        end
        -- render current image
        state.history[state.idx]:render(state.buf, state.win)
      end

      ---Closes image history window completely.
      function M.close_image_history()
        if state.closing then
          return
        end

        -- prevent possible recursion
        state.closing = true
        vim.on_key(nil, ns)

        if state.history[state.idx] then
          state.history[state.idx]:clear()
        end

        if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
          pcall(function()
            vim.api.nvim_buf_delete(state.buf, { force = true })
            state.buf = nil
          end)
        end

        if state.win and vim.api.nvim_win_is_valid(state.win) then
          pcall(function()
            vim.api.nvim_win_close(state.win, true)
            state.win = nil
          end)
        end

        state.closing = false
      end

      ---Push base64 PNG image to history and display it.
      ---@param img_base64 string
      function M.console_endpoint(img_base64)
        if type(img_base64) ~= "string" or img_base64 == "" then
          error(config.get_message_prefix() .. "image data missing or invalid", 0)
        end
        push_history(img_base64)
        M.open_image_history(#state.history, false)
      end


      local layout = "vertical"

      function M.toggle_layout()
        local repl_win = require("pyrepl.core").get_win()
        local plots_win = state.win

        if not repl_win or not plots_win
          or not vim.api.nvim_win_is_valid(repl_win)
          or not vim.api.nvim_win_is_valid(plots_win) then
          vim.notify("Open the REPL and plots first",
          vim.log.levels.WARN)
          return
        end

        -- Find the source editor window.
        local code_win = vim.api.nvim_get_current_win()

        if code_win == repl_win or code_win == plots_win then
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if win ~= repl_win and win ~= plots_win
              and vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "" then
              code_win = win
              break
            end
          end
        end

        if code_win == repl_win or code_win == plots_win then
          vim.notify("Could not find source editor",
          vim.log.levels.WARN)
          return
        end

        local current_win = vim.api.nvim_get_current_win()
        local next_layout = layout == "vertical"
        and "horizontal" or "vertical"

        -- Remove the old graphics placement before moving windows.
        if state.history[state.idx] then
          state.history[state.idx]:clear()
        end

        local ok, err = pcall(function()
          if next_layout == "horizontal" then
            -- CODE
            -- REPL | PLOTS
            vim.api.nvim_win_set_config(repl_win, {
              win = code_win,
              split = "below",
            })

            vim.api.nvim_win_set_config(plots_win, {
              win = repl_win,
              split = "right",
            })
          else
            -- CODE | PLOTS
            --      | REPL
            vim.api.nvim_win_set_config(repl_win, {
              win = code_win,
              split = "right",
            })

            vim.api.nvim_win_set_config(plots_win, {
              win = repl_win,
              split = "above",
            })
          end
        end)

        if not ok then
          vim.notify(tostring(err), vim.log.levels.ERROR)
          return
        end

        layout = next_layout

        -- Restore focus to the original window.
        if vim.api.nvim_win_is_valid(current_win) then
          vim.api.nvim_set_current_win(current_win)
        end

        -- Redraw the current plot.
        if state.history[state.idx] then
          state.history[state.idx]:render(state.buf, state.win)
        end
      end

      return M
