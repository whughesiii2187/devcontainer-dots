return { 
  "oonamo/ef-themes.nvim",
  config = function()
    require("ef-themes").setup({ 
      transparent = true 
    })
  vim.cmd.colorscheme("ef-deuteranopia-dark")
  end
}
