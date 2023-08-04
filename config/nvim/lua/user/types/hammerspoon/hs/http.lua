---@meta

---@class http
return {
  ---Create an HTTP POST request and execute it asynchronously
  ---@param url string
  ---@param data string
  ---@param headers table
  ---@param callback fun(number, string, table):nil
  ---@return nil
  asyncPost = function(url, data, headers, callback) end,
}
