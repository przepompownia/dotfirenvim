vim.g.pluginDirs = vim.iter({
  'arctgx',
  'plugins',
  'unmerged',
  'colorscheme',
}):map(function (group)
  return vim.fs.joinpath(vim.fn.stdpath('config'), 'pack', group, 'opt')
end):totable()

vim.go.cmdheight = 0
require('vim._extui').enable({enable = true, msg = {target = 'msg'}})

for _, path in ipairs(vim.opt.packpath:get()) do
  if vim.startswith(path, '/etc/') or vim.startswith(path, '/usr/') then
    vim.opt.packpath:remove(path)
  end
end

for _, path in ipairs(vim.opt.runtimepath:get()) do
  if vim.startswith(path, '/etc/') or vim.startswith(path, '/usr/') then
    vim.opt.runtimepath:remove(path)
  end
end

vim.loader.enable()

---@type NvimPlugins
local extensions = {
  {name = 'firenvim'}
}

if not vim.tbl_contains({vim.fn.stdpath('config'), vim.env.NVIM_UNSANDBOXED_CONFIGDIR}, vim.uv.cwd()) then
  local exrc = vim.fs.joinpath(vim.fn.stdpath('config'), '.nvim.local.lua')
  local ok = pcall(vim.uv.fs_stat, exrc)
  if not ok then
    return
  end
  assert(loadstring(vim.secure.read(exrc) or '', 'Cannot load Lua script from ' .. exrc))()
end

require('dotnvim.plugin').packadd(extensions)


---@param cb fun()
---@param ... any
---@return boolean, ...?any
local function epcall(cb, ...)
  return xpcall(cb, function (e) vim.api.nvim_echo({{e}}, true, {err = true}) end, ...)
end

local keymap = vim.keymap
local function silentLuaRhsMap(mode, lhs, rhs, opts)
  if type(rhs) ~= 'function' then
    keymap.set(mode, lhs, rhs, opts)
    return
  end
  local silentRhs = function ()
    epcall(rhs)
  end
  keymap.set(mode, lhs, silentRhs, opts)
end
local opts = {silent = true}
keymap.set('i', '<C-BS>', '<C-w>', opts)
keymap.set('i', '<C-Del>', function () vim.cmd.normal('dw') end, opts)
silentLuaRhsMap({'i', 'n', 'x'}, '<F2>', vim.cmd.update, opts)
silentLuaRhsMap({'i', 'n', 'x'}, '<F3>', vim.cmd.quit, opts)
silentLuaRhsMap({'i', 'n'}, '<S-F3>', function () vim.cmd.quit {bang = true} end, opts)
silentLuaRhsMap({'i', 'n'}, '<F15>', function () vim.cmd.quit {bang = true} end, opts)
keymap.set({'i'}, '<C-Left>', function () vim.cmd.normal('b') end, opts)
keymap.set({'i'}, '<C-Right>', function ()
  vim._with({wo = {virtualedit = 'onemore'}}, function ()
    vim.cmd.normal('w')
  end)
end, opts)
vim.go.exrc = true

vim.go.laststatus = 0
vim.g.firenvim_config = {
  localSettings = {
    ['.*'] = {
      takeover = 'never',
      priority = 0,
    }
  }
}

vim.api.nvim_create_autocmd({'BufEnter'}, {
  pattern = 'github.com_*.txt',
  command = 'set filetype=markdown'
})

vim.api.nvim_create_autocmd({'TextChanged', 'TextChangedI'}, {
  callback = function (e)
    if vim.g.timer_started == true then
      return
    end
    vim.g.timer_started = true
    vim.fn.timer_start(10000, function ()
      vim.g.timer_started = false
      vim.cmd('silent write')
    end)
  end
})

vim.cmd.startinsert()
