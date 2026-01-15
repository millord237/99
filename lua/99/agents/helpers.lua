local M = {}

--- @param dir string
--- @return _99.Agents.Rule[]
function M.ls(dir)
  local cursor_rules_dir = vim.uv.cwd() .. dir
  local files = vim.fn.glob(cursor_rules_dir .. "/*.{mdc,md}", false, true)
  local rules = {}

  for _, file in ipairs(files) do
    local filename = vim.fn.fnamemodify(file, ":t:r")
    table.insert(rules, {
      name = filename,
      path = file,
    })
  end

  return rules
end

return M
