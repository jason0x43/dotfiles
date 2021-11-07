-- try to require a module, return nil if not found
return function (module)
  local status, mod = pcall(require, module)
  if status then
    return mod
  end
  return nil
end
