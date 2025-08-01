-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'github/copilot.vim',
    lazy = false, -- load on startup
    config = function()
      vim.g.copilot_no_tab_map = true
      vim.api.nvim_set_keymap('i', '<C-l>', 'copilot#Accept("<CR>")', { expr = true, silent = true })
    end,
  },

  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons', -- optional but recommended for icons
    },
    config = function()
      require('nvim-tree').setup {
        view = {
          width = 30,
          side = 'left',
        },
        filters = {
          dotfiles = false,
        },
        update_focused_file = {
          enable = true,
          update_cwd = true,
        },
        on_attach = function(bufnr)
          local api = require 'nvim-tree.api'
          local opts = { buffer = bufnr }

          api.config.mappings.default_on_attach(bufnr)

          vim.keymap.set('n', 'v', api.node.open.vertical, opts)
          vim.keymap.set('n', 's', api.node.open.horizontal, opts)
        end,
      }

      -- Optional: map <leader>e to toggle the tree
      vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle file explorer' })
      vim.keymap.set('n', '<leader>l', ':NvimTreeFindFile<CR>', { desc = 'Reveal current file in nvim-tree' })

      vim.keymap.set('n', '<leader>tw', function()
        -- Find the nvim-tree window and resize it
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
          if bufname:match 'NvimTree_' then
            vim.api.nvim_set_current_win(win)
            vim.cmd 'vertical resize +10'
            break
          end
        end
      end, { desc = 'Widen nvim-tree window' })
    end,
  },

  {
    'ThePrimeagen/harpoon',
    dependencies = {
      'nvim-lua/plenary.nvim', -- required dependency for harpoon
    },
    config = function()
      require('harpoon').setup {
        menu = {
          width = 80,
        },
      }

      -- Optional: map keys for harpoon navigation
      vim.keymap.set('n', '<leader>ha', ":lua require('harpoon.mark').add_file()<CR>", { desc = 'Add file to harpoon' })
      vim.keymap.set('n', '<leader>hh', ":lua require('harpoon.ui').toggle_quick_menu()<CR>", { desc = 'Toggle harpoon menu' })
      vim.keymap.set('n', '<leader>hj', ":lua require('harpoon.ui').nav_next()<CR>", { desc = 'Next harpoon file' })
      vim.keymap.set('n', '<leader>hk', ":lua require('harpoon.ui').nav_prev()<CR>", { desc = 'Previous harpoon file' })
    end,
  },

  -- with lazy.nvim
  {
    'LintaoAmons/bookmarks.nvim',
    -- pin the plugin at specific version for stability
    -- backup your bookmark sqlite db when there are breaking changes (major version change)
    tag = '3.2.0',
    dependencies = {
      { 'kkharji/sqlite.lua' },
      { 'nvim-telescope/telescope.nvim' }, -- currently has only telescopes supported, but PRs for other pickers are welcome
      { 'stevearc/dressing.nvim' }, -- optional: better UI
      { 'GeorgesAlkhouri/nvim-aider' }, -- optional: for Aider integration
    },
    config = function()
      local opts = {} -- check the "./lua/bookmarks/default-config.lua" file for all the options
      require('bookmarks').setup(opts) -- you must call setup to init sqlite db
      vim.keymap.set({ 'n', 'v' }, 'mm', '<cmd>BookmarksMark<cr>', { desc = 'Mark current line into active BookmarkList.' })
      vim.keymap.set({ 'n', 'v' }, 'mo', '<cmd>BookmarksGoto<cr>', { desc = 'Go to bookmark at current active BookmarkList' })
      vim.keymap.set({ 'n', 'v' }, 'ma', '<cmd>BookmarksCommands<cr>', { desc = 'Find and trigger a bookmark command.' })
    end,
  },

  -- run :BookmarksInfo to see the running status of the plugin
}
