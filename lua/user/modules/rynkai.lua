local M = {}

local alias = "colorscheme"

M.setup = function()
  -- local rynkai = require "rynkai"
  local present, rynkai = pcall(require, "rynkai")
  if not present then
    return
  end

  local config_file = vim.fn.stdpath "config" .. "/lua/user/modules/rynkai.lua"
  local rynkai_dir = vim.fn.stdpath "data" .. "/site/pack/packer/opt/" .. alias .. "/lua/rynkai/colors/"

  rynkai.setup {
    theme = "mirage", -- NOTE: this field is a must.
    config_file = config_file,
    rynkai_dir = rynkai_dir,
  }

  vim.cmd [[ colorscheme rynkai ]]

  local telescope_present, telescope = pcall(require, "telescope")
  if not telescope_present then
    return
  end

  telescope.load_extension "rynkai"

  require("user.modules.whichkey").registers {
    s = {
      c = { "<cmd>Telescope rynkai<CR>", "Colorscheme" },
    },
  }
end

M.colorscheme_switcher = function(opts)
  local pickers, finders, action_state, conf, actions
  actions = require "telescope.actions"
  pickers = require "telescope.pickers"
  finders = require "telescope.finders"
  action_state = require "telescope.actions.state"
  conf = require("telescope.config").values

  local before_color = require("rynkai.config").options.theme
  local need_restore = true

  local themes = require("rynkai.fn").list_themes()
  local colors = { before_color }

  themes = vim.list_extend(
    colors,
    vim.tbl_filter(function(color)
      return color ~= before_color
    end, themes)
  )

  local picker = pickers.new(opts, {
    prompt_title = "Change color style",
    finder = finders.new_table {
      results = colors,
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        if selection == nil then
          print "[telescope] Nothing currently selected"
          return
        end

        actions.close(prompt_bufnr)
        need_restore = false
        require("rynkai.fn").change(selection[1])
        require("rynkai.fn").change_theme(before_color, selection[1])
      end)
      return true
    end,
  })

  local close_windows = picker.close_windows
  picker.close_windows = function(status)
    close_windows(status)
    if need_restore then
      require("rynkai.fn").change(before_color)
    end
  end

  picker:find()
end

function M.theme_config(theme_path)
  if vim.fn.empty(vim.fn.glob(theme_path)) > 0 or theme_path == nil then
    theme_path = "qqhgs/rynkai.nvim" -- github url
  end
  return {
    theme_path,
    event = "VimEnter",
    as = alias,
    config = function()
      require("user.modules.rynkai").setup()
    end,
  }
end

return M
