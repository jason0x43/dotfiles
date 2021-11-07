-- try to require a module, return nil if not found
return function (module, func, ...)
  local status, mod = pcall(require, module)
  if not status then
    return nil
  end

  if type(func) == 'function' then
    return func(mod)
  end

  if type(func) == 'string' then
    return mod[func](...)
  end

  return mod
end
