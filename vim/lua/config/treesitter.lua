require('nvim-treesitter.configs').setup(
  {
    ensure_installed = 'maintained',
    highlight = {
      enable = true,
      -- this option prevents treesitter highlighting from breaking indenting
      -- see https://github.com/nvim-treesitter/nvim-treesitter/discussions/1271#discussioncomment-795299
      additional_vim_regex_highlighting = true
    },
    indent = {
      enable = true,
      -- indenting is currently broken for JS/TS, particularly for doc comments
      disable = {
        'typescript',
        'typescriptreact',
        'typescript.tsx',
        'javascript',
        'javascriptreact',
        'javascript.jsx'
      }
    },
    autopairs = { enable = true },
    rainbow = { enable = true },
    autotag  = { enable = true },
    context_commentstring  = { enable = true },
  }
)
