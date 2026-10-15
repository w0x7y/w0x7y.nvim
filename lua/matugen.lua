 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#23272e',
    base01 = '#2b3038',
    base02 = '#343a44',
    base03 = '#6a707b',
    base04 = '#9aa4b6',
    base05 = '#c3ccd9',
    base06 = '#c3ccd9',
    base07 = '#c3ccd9',
    base08 = '#d98a9c',
    base09 = '#7cc4d0',
    base0A = '#bb98d6',
    base0B = '#7aa4e4',
    base0C = '#96dde9',
    base0D = '#95b6e9',
    base0E = '#c596e9',
    base0F = '#dcbef4',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#c3ccd9',          bg = '#23272e' })
  hi('TelescopeBorder',         { fg = '#6a707b',             bg = '#23272e' })
  hi('TelescopePromptNormal',   { fg = '#c3ccd9',          bg = '#23272e' })
  hi('TelescopePromptBorder',   { fg = '#6a707b',             bg = '#23272e' })
  hi('TelescopePromptPrefix',   { fg = '#7aa4e4',             bg = '#23272e' })
  hi('TelescopePromptCounter',  { fg = '#9aa4b6',  bg = '#23272e' })
  hi('TelescopePromptTitle',    { fg = '#23272e',             bg = '#7aa4e4' })
  hi('TelescopePreviewTitle',   { fg = '#23272e',             bg = '#bb98d6' })
  hi('TelescopeResultsTitle',   { fg = '#23272e',             bg = '#7cc4d0' })
  hi('TelescopeSelection',      { fg = '#c3ccd9',          bg = '#343a44' })
  hi('TelescopeSelectionCaret', { fg = '#7aa4e4',             bg = '#343a44' })
  hi('TelescopeMatching',       { fg = '#7aa4e4',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#c3ccd9',          bg = '#23272e' })
  hi('MiniPickBorder',         { fg = '#6a707b',             bg = '#23272e' })
  hi('MiniPickPrompt',   { fg = '#c3ccd9',          bg = '#23272e' })
  hi('MiniPickPromptPrefix',   { fg = '#7aa4e4',             bg = '#23272e' })
  hi('MiniPickBorderText',    { fg = '#23272e',             bg = '#7aa4e4' })
  hi('MiniPickMatchCurrent',      { fg = '#c3ccd9',          bg = '#343a44' })
  hi('MiniPickPromptCaret', { fg = '#7aa4e4',             bg = '#343a44' })
  hi('MiniPickMatchRanges',       { fg = '#7aa4e4',             bold = true })
end

-- Register a signal handler for SIGUSR1 (matugen updates).
-- The handler re-requires this module, which re-runs the code below, so the
-- previous handle is stopped first; otherwise handlers double on every signal.
if _G.__matugen_signal then
  _G.__matugen_signal:stop()
  _G.__matugen_signal:close()
end

local signal = vim.uv.new_signal()
_G.__matugen_signal = signal
signal:start(
  'sigusr1',
  vim.schedule_wrap(function()
    package.loaded['matugen'] = nil
    require('matugen').setup()
  end)
)

return M
