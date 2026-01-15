local Window = require("99.window")
Window.clear_active_popups()
R("99")

-- Modern Neovim completion example using vim.lsp.completion and custom completions
-- This is the newer API that replaced omnifunc

-- Example 1: Using the built-in completion with a custom source
local function setup_custom_completion()
  -- Set up completion options
  vim.opt.completeopt = { "menu", "menuone", "noselect" }

  -- Create a custom completion function
  -- This is called when user triggers completion (Ctrl-X Ctrl-U by default)
  vim.api.nvim_buf_set_option(0, 'completefunc', 'v:lua.custom_complete')
end

-- Custom completion function
-- Returns completion items when called
function _G.custom_complete(findstart, base)
  if findstart == 1 then
    -- First call: return the column where completion starts
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]

    -- Find start of the word
    local start = col
    while start > 0 and line:sub(start, start):match("[%w_]") do
      start = start - 1
    end

    return start
  else
    -- Second call: return list of completions
    -- 'base' is the text to complete
    local completions = {
      { word = "example_item", menu = "Example", kind = "Function" },
      { word = "example_variable", menu = "Example", kind = "Variable" },
      { word = "example_constant", menu = "Example", kind = "Constant" },
    }

    -- Filter completions based on what user typed
    local matches = {}
    for _, item in ipairs(completions) do
      if item.word:find("^" .. base) then
        table.insert(matches, item)
      end
    end

    return matches
  end
end

-- Example 2: Using nvim-cmp style manual completion
-- This is the modern approach used by popular plugins
local function create_completion_source()
  return {
    items = {
      { label = "Window.clear_active_popups", kind = vim.lsp.protocol.CompletionItemKind.Method },
      { label = "Window.capture_input", kind = vim.lsp.protocol.CompletionItemKind.Method },
      { label = "Window.create_popup", kind = vim.lsp.protocol.CompletionItemKind.Method },
      { label = "custom_item", kind = vim.lsp.protocol.CompletionItemKind.Variable },
    },

    complete = function(self, ctx)
      local line = ctx.line
      local cursor = ctx.cursor

      -- Return filtered items based on context
      return vim.tbl_filter(function(item)
        return item.label:find(ctx.query or "", 1, true) ~= nil
      end, self.items)
    end
  }
end

-- Example 3: Set up omnifunc (older API, but still works)
-- This is triggered with Ctrl-X Ctrl-O
function _G.my_omnifunc(findstart, base)
  if findstart == 1 then
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    return vim.fn.match(line:sub(1, col), [[\k*$]])
  else
    -- Return completion matches
    return {
      "Window.clear_active_popups()",
      "Window.capture_input(callback, opts)",
      "Window.create_floating_window()",
      { word = "advanced_item", abbr = "adv", menu = "Custom", info = "Detailed info here" },
    }
  end
end

-- Set it up for the current buffer
vim.api.nvim_buf_set_option(0, 'omnifunc', 'v:lua.my_omnifunc')

-- Usage:
-- Ctrl-X Ctrl-O to trigger omnifunc completion
-- Ctrl-X Ctrl-U to trigger completefunc completion

-- Example: Auto-trigger completion when typing '@' in 99-prompt buffer

-- Custom completion function that provides context-aware items
function _G.prompt_at_complete(findstart, base)
  if findstart == 1 then
    -- Find the start position (right after the '@')
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]

    -- Find the '@' symbol
    local start = col
    while start > 0 and line:sub(start, start) ~= '@' do
      start = start - 1
    end

    return start
  else
    -- Return completion items based on what comes after '@'
    local completions = {
      { word = "@file", menu = "Reference a file", kind = "File" },
      { word = "@buffer", menu = "Reference a buffer", kind = "Reference" },
      { word = "@selection", menu = "Reference current selection", kind = "Reference" },
      { word = "@codebase", menu = "Search entire codebase", kind = "Keyword" },
      { word = "@web", menu = "Search the web", kind = "Keyword" },
    }

    -- Filter based on what user has typed
    local matches = {}
    for _, item in ipairs(completions) do
      if item.word:find("^@" .. vim.pesc(base), 1) then
        table.insert(matches, item)
      end
    end

    return matches
  end
end

setup_custom_completion()

