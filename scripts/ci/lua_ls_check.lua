local function read_luarc()
  local path = vim.fn.getcwd() .. "/.luarc.json"
  if vim.fn.filereadable(path) == 0 then
    return {}
  end

  local ok, content = pcall(vim.fn.readfile, path)
  if not ok then
    return {}
  end

  local ok_decode, decoded = pcall(vim.fn.json_decode, table.concat(content, "\n"))
  if not ok_decode or type(decoded) ~= "table" then
    return {}
  end

  return decoded
end

local function extract_globals(config)
  local globals = {}
  local raw = config["diagnostics.globals"]
  if type(raw) == "table" then
    for _, value in ipairs(raw) do
      if type(value) == "string" then
        table.insert(globals, value)
      end
    end
  end
  return globals
end

local function resolve_server_cmd()
  local candidates = { "lua-language-server", "lua_ls" }
  for _, cmd in ipairs(candidates) do
    if vim.fn.executable(cmd) == 1 then
      return { cmd }
    end
  end
  return nil
end

local function list_lua_files()
  local root = vim.fn.getcwd()
  return vim.fn.globpath(root, "lua/**/*.lua", false, true)
end

local function format_diag(bufnr, diagnostic)
  local file = vim.api.nvim_buf_get_name(bufnr)
  local severity_names = {
    [vim.diagnostic.severity.ERROR] = "ERROR",
    [vim.diagnostic.severity.WARN] = "WARN",
    [vim.diagnostic.severity.INFO] = "INFO",
    [vim.diagnostic.severity.HINT] = "HINT",
  }
  local severity = severity_names[diagnostic.severity] or "UNKNOWN"
  local line = (diagnostic.lnum or 0) + 1
  local col = (diagnostic.col or 0) + 1
  return string.format("%s:%d:%d: %s: %s", file, line, col, severity, diagnostic.message)
end

local function main()
  local server_cmd = resolve_server_cmd()
  if not server_cmd then
    print("lua-language-server not found in PATH.")
    vim.cmd("cquit")
    return
  end

  local config = read_luarc()
  local globals = extract_globals(config)
  local settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = globals },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  }

  local files = list_lua_files()
  if #files == 0 then
    print("No Lua files found.")
    vim.cmd("qa")
    return
  end

  local published = {}
  local default_handler = vim.lsp.handlers["textDocument/publishDiagnostics"]
  vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, cfg)
    if result and result.uri then
      local bufnr = vim.uri_to_bufnr(result.uri)
      if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
        published[bufnr] = true
      end
    end
    return default_handler(err, result, ctx, cfg)
  end

  local root_dir = vim.fn.getcwd()
  local buffers = {}
  for _, file in ipairs(files) do
    local bufnr = vim.fn.bufnr(file, true)
    vim.fn.bufload(bufnr)
    vim.bo[bufnr].filetype = "lua"
    table.insert(buffers, bufnr)

    vim.api.nvim_set_current_buf(bufnr)
    vim.lsp.start({
      name = "lua_ls",
      cmd = server_cmd,
      root_dir = root_dir,
      settings = settings,
    })
  end

  local all_published = vim.wait(10000, function()
    for _, bufnr in ipairs(buffers) do
      if not published[bufnr] then
        return false
      end
    end
    return true
  end, 100)

  local has_errors = false
  if not all_published then
    print("Timed out waiting for LSP diagnostics.")
    has_errors = true
  end

  local all_diags = {}
  for _, bufnr in ipairs(buffers) do
    local diags = vim.diagnostic.get(bufnr, {
      severity = { min = vim.diagnostic.severity.WARN },
    })
    for _, diagnostic in ipairs(diags) do
      table.insert(all_diags, format_diag(bufnr, diagnostic))
    end
  end

  if #all_diags > 0 then
    has_errors = true
    table.sort(all_diags)
    print("LSP diagnostics:")
    for _, line in ipairs(all_diags) do
      print(line)
    end
  end

  if has_errors then
    vim.cmd("cquit")
    return
  end

  print("No LSP diagnostics.")
  vim.cmd("qa")
end

main()
