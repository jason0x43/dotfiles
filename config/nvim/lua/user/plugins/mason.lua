return {
  'williamboman/mason-lspconfig.nvim',

  config = function()
    require('mason').setup({
      ui = {
        border = 'rounded',
      },
    })
    require('mason-lspconfig').setup()

    -- use mason's automatic server startup functionality
    require("mason-lspconfig").setup_handlers({
			function (server_name)
				local config = require('user.lsp').get_lsp_config(server_name)
				require("lspconfig")[server_name].setup(config)
			end,
    })
  end,

	dependencies = 'williamboman/mason.nvim'
}
