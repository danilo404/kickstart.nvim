local M = {}

M.commands = {
  py = function(_)
    local cwd = vim.fn.getcwd()
    local relative = vim.fn.expand '%'

    return {
      'docker',
      'run',
      '--rm',
      '-v',
      cwd .. ':/workspace',
      '-w',
      '/workspace',
      'python:3.15.0a7-trixie',
      'python',
      relative,
    }
  end,

  sh = function(file)
    return { 'bash', file }
  end,

  go = function(file)
    return { 'go', 'run', file }
  end,
}

M.state = {
  buf = nil,
  win = nil,
}

local function ensure_output_buffer()
  if M.state.buf and vim.api.nvim_buf_is_valid(M.state.buf) then
    return M.state.buf
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, 'Runner Output')

  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'hide'
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false

  vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf, silent = true })

  M.state.buf = buf
  return buf
end

local function show_output_window(buf)
  if M.state.win and vim.api.nvim_win_is_valid(M.state.win) then
    vim.api.nvim_win_set_buf(M.state.win, buf)
    return M.state.win
  end

  vim.cmd 'botright 12split'
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)

  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].wrap = false
  vim.wo[win].signcolumn = 'no'

  M.state.win = win
  return win
end

local function set_output(lines)
  local buf = ensure_output_buffer()
  show_output_window(buf)

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
end

M.run_current_file = function()
  if vim.bo.modified then
    vim.cmd 'write'
  end

  local file = vim.fn.expand '%:p'
  local ext = vim.fn.expand '%:e'

  if file == '' then
    vim.notify('Current buffer has no file on disk', vim.log.levels.WARN)
    return
  end

  local builder = M.commands[ext]
  if not builder then
    vim.notify('No run command configured for *.' .. ext, vim.log.levels.WARN)
    return
  end

  local cmd = builder(file)
  local stdout = {}
  local stderr = {}

  set_output {
    '$ ' .. table.concat(cmd, ' '),
    '',
    '[running...]',
  }

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,

    on_stdout = function(_, data)
      if not data then
        return
      end
      for _, line in ipairs(data) do
        if line ~= '' then
          table.insert(stdout, line)
        end
      end
    end,

    on_stderr = function(_, data)
      if not data then
        return
      end
      for _, line in ipairs(data) do
        if line ~= '' then
          table.insert(stderr, line)
        end
      end
    end,

    on_exit = function(_, code)
      vim.schedule(function()
        local lines = {
          '$ ' .. table.concat(cmd, ' '),
          '',
          'exit code: ' .. code,
          '',
        }

        if #stdout > 0 then
          vim.list_extend(lines, stdout)
        end

        if #stderr > 0 then
          if #stdout > 0 then
            table.insert(lines, '')
          end
          table.insert(lines, '[stderr]')
          table.insert(lines, '')
          vim.list_extend(lines, stderr)
        end

        if #stdout == 0 and #stderr == 0 then
          table.insert(lines, '[no output]')
        end

        set_output(lines)

        if code == 0 then
          vim.notify('Command finished successfully', vim.log.levels.INFO)
        else
          vim.notify('Command exited with code ' .. code, vim.log.levels.ERROR)
        end
      end)
    end,
  })
end

M.setup = function()
  vim.keymap.set('n', '<leader>r', M.run_current_file, { desc = 'Run current file' })
end

return M
