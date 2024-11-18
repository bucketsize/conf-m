return {

  {
    "lewis6991/gitsigns.nvim"
  },
  {
    "tpope/vim-fugitive",
    cmd = "Git",
    keys = {
      {
        "<leader>gu", vim.cmd.Git, desc = "vim fugitive"
      }
    }
  }
}
