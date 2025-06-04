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
      }

      -- Optional: map <leader>e to toggle the tree
      vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle file explorer' })
      vim.keymap.set('n', '<leader>l', ':NvimTreeFindFile<CR>', { desc = 'Reveal current file in nvim-tree' })
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
}
