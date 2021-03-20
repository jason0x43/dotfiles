require'nvim-treesitter.configs'.setup {
	ensure_installed = {
		'bash',
		'c',
		'cpp',
		'css',
		'go',
		'graphql',
		'html',
		'java',
		'javascript',
		'jsdoc',
		'json',
		'jsonc',
		'lua',
		'python',
		'rust',
		'svelte',
		'toml',
		'tsx',
		'typescript',
		'vue',
		'yaml',
	},
	highlight = {
		enable = true,
		disable = { "javascript", "tsx", "typescript" }
	},
	indent = {
		enable = true,
		disable = { "javascript", "json", "typescript", "tsx" }
	},
}
