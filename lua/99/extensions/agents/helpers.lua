local M = {}

--- @param dir string
--- @return _99.Agents.Rule[]
function M.ls(dir)
  local cwd = vim.fs.joinpath(vim.uv.cwd(), dir)
  local glob = vim.fs.joinpath(cwd, "/*.{mdc,md}")
  local files = vim.fn.glob(glob, false, true)
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

--- @param file string
--- @param count? number
--- @return string
function M.head(file, count)
  count = count or 5
  local fd = vim.uv.fs_open(file, "r", 438)
  if not fd then
    return ""
  end

  local stat = vim.uv.fs_fstat(fd)
  if not stat then
    vim.uv.fs_close(fd)
    return ""
  end

  local data = vim.uv.fs_read(fd, stat.size, 0)
  vim.uv.fs_close(fd)

  if not data then
    return ""
  end

  local lines = {}
  for line in data:gmatch("([^\n]*)\n?") do
    if count == 0 then
      break
    end
    count = count - 1
    table.insert(lines, line)
  end

  return table.concat(lines, "\n")
end

return M
