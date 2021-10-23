local M = {}
local lsp_util = require('vim.lsp.util')

vim.opt.completeopt = { 'menu', 'menuone' }

local function raw_key(key_code)
  return vim.api.nvim_replace_termcodes(key_code, true, false, true)
end

-- from runtime lsp.lua
-- this script ensures that the match start column is based on the encoding used
-- by the lsp
local function adjust_start_col(lnum, line, items, encoding)
  local min_start_char = nil
  for _, item in pairs(items) do
    if item.textEdit and item.textEdit.range.start.line == lnum - 1 then
      if
        min_start_char
        and min_start_char ~= item.textEdit.range.start.character
      then
        return nil
      end
      min_start_char = item.textEdit.range.start.character
    end
  end
  if min_start_char then
    if encoding == 'utf-8' then
      return min_start_char
    else
      return vim.str_byteindex(line, min_start_char, encoding == 'utf-16')
    end
  else
    return nil
  end
end

local TAB = 1
local S_TAB = 2
local CR = 3

function M.complete(key)
  if vim.fn.pumvisible() == 1 then
    if key == TAB then
      return raw_key('<c-n>')
    end
    if key == S_TAB then
      return raw_key('<c-p>')
    end
    if key == CR then
      return raw_key('<c-y>')
    end
    return raw_key('<c-e>')
  end

  if key == CR then
    return raw_key('<cr>')
  end

  local min_chars = 1
  local pos = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line():sub(1, pos[2])
  local last_chars = line:match('%S+$')
  if not last_chars or #last_chars < min_chars then
    return raw_key('<tab>')
  end

  if vim.fn.match(last_chars, '^\\(.*\\W\\)\\?\\(/\\w\\+\\)*/\\w*') ~= -1 then
    -- open the file completion popup
    return raw_key('<c-x><c-f>')
  end

  -- open the keyword completion popup
  vim.api.nvim_feedkeys(raw_key('<c-n>'), 'm', true)

  -- if omnifunc isn't the lsp omnifunc, stop here
  if vim.bo.omnifunc ~= 'v:lua.vim.lsp.omnifunc' then
    return ''
  end

  -- get the list of keyword matches in the completion menu
  local keyword_items = {}
  vim.schedule(function()
    -- This is run in a schedule callback because complete_info won't return
    -- anything until the popup menu has been displayed. It will complete before
    -- the lsp results request below does.
    local info = vim.fn.complete_info({ 'mode', 'items' })
    vim.list_extend(keyword_items, info.items)
  end)

  local bufnr = vim.api.nvim_get_current_buf()
  local keyword = vim.fn.match(line, '\\k*$')
  local params = lsp_util.make_position_params()

  -- Call the lsp completer using the request code from the runtime lua.lsp.
  -- It's repeated here so that we can mix the LSP results into the keyword
  -- results rather than overriding them.
  vim.lsp.buf_request(
    bufnr,
    'textDocument/completion',
    params,
    function(err, result, ctx)
      if err or not result or vim.fn.mode() ~= 'i' then
        return
      end
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      local encoding = client and client.offset_encoding or 'utf-16'
      local candidates = vim.lsp.util.extract_completion_items(result)
      local startbyte = adjust_start_col(pos[1], line, candidates, encoding)
        or keyword
      local prefix = line:sub(startbyte + 1, pos[2])
      local matches =
        vim.lsp.util.text_document_completion_list_to_complete_items(
          result,
          prefix
        )

      -- Append any keyword items to the match list that aren't already in the
      -- LSP matches
      local lsp_items = matches
      local lsp_words = vim.tbl_map(function(item)
        return item.word
      end, matches)
      for _, item in pairs(keyword_items) do
        if not vim.tbl_contains(lsp_words, item.word) then
          table.insert(lsp_items, item)
        end
      end

      vim.fn.complete(startbyte + 1, lsp_items)
    end
  )

  -- consume the key that was pressed
  return ''
end

-- manual completion and cycling
local util = require('util')
util.imap('<tab>', 'v:lua.completion.complete(' .. TAB .. ')', { expr = true })
util.imap(
  '<s-tab>',
  'v:lua.completion.complete(' .. S_TAB .. ')',
  { expr = true }
)
util.imap('<cr>', 'v:lua.completion.complete(' .. CR .. ')', { expr = true })

-- automatic completion
-- util.augroup('custom-completion', {
--   'TextChangedI *.md,*.textile lua completion.complete(0)',
-- })

_G.completion = M

return M
