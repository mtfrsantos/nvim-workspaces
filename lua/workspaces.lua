local Workspaces = {
    _workspaces = {},
    _config = {
        file_path = vim.fn.stdpath("data") .. "/workspaces.json",
    },
}

function Workspaces.setup(config)
    Workspaces._config = vim.tbl_deep_extend("force", Workspaces._config, config or {})
    Workspaces.load()
end

function Workspaces.load()
    local file = io.open(Workspaces._config.file_path, "r")
    if not file then
        Workspaces._workspaces = {}
        return
    end
    local data = file:read("*a")
    file:close()
    Workspaces._workspaces = vim.json.decode(data) or {}
end

function Workspaces.save()
    local path = Workspaces._config.file_path
    local dir = vim.fn.fnamemodify(path, ":h")

    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, "p")
    end

    local file = io.open(path, "w")
    if not file then
        vim.notify("Failed to save workspaces to: " .. path, vim.log.levels.ERROR)
        return
    end

    local ok, json = pcall(vim.json.encode, Workspaces._workspaces)
    if not ok then
        vim.notify("Failed to encode workspaces: " .. json, vim.log.levels.ERROR)
        file:close()
        return
    end

    file:write(json)
    file:close()
end

function Workspaces.add(name, path)
    if Workspaces._workspaces[name] then
        vim.notify("Workspace '" .. name .. "' already exists.", vim.log.levels.WARN)
        return
    end
    Workspaces._workspaces[name] = path
    Workspaces.save()
    vim.notify("Workspace '" .. name .. "' added.", vim.log.levels.INFO)
end

function Workspaces.remove(name)
    if not Workspaces._workspaces[name] then
        vim.notify("Workspace '" .. name .. "' doesn't exist.", vim.log.levels.WARN)
        return
    end
    Workspaces._workspaces[name] = nil
    Workspaces.save()
    vim.notify("Workspace '" .. name .. "' removed.", vim.log.levels.INFO)
end

function Workspaces.list()
    local result = {}
    for name, path in pairs(Workspaces._workspaces) do
        table.insert(result, {
            name = name,
            path = path,
        })
    end
    return result
end

-- User Commands
vim.api.nvim_create_user_command("WorkspaceAdd", function(opts)
    local args = vim.split(opts.args, "%s+", { plain = false, trimempty = true })
    if #args < 2 then
        vim.notify("Usage: WorkspaceAdd <name> <path>", vim.log.levels.ERROR)
        return
    end
    local name = args[1]
    local path = table.concat(args, " ", 2, #args)
    path = vim.fn.expand(path)
    Workspaces.add(name, path)
end, { nargs = "+" })

vim.api.nvim_create_user_command("WorkspaceRemove", function(opts)
    if opts.args == "" then
        vim.notify("Usage: WorkspaceRemove <name>", vim.log.levels.ERROR)
        return
    end
    Workspaces.remove(opts.args)
end, { nargs = 1 })

vim.api.nvim_create_user_command("WorkspaceAddCurrent", function()
    vim.ui.input({ prompt = "Workspace name: " }, function(name)
        if not name or name == "" then
            return
        end
        local path = vim.fn.getcwd()
        Workspaces.add(name, path)
    end)
end, {})

-- Telescope Integration
local function create_picker()
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values

    return function(opts)
        opts = opts or {}
        local workspaces = Workspaces.list()

        pickers
            .new(opts, {
                prompt_title = "Workspaces",
                finder = finders.new_table({
                    results = workspaces,
                    entry_maker = function(entry)
                        return {
                            value = entry.path,
                            display = string.format("%-20s %s", entry.name, entry.path),
                            ordinal = entry.name,
                        }
                    end,
                }),
                sorter = conf.generic_sorter(opts),
                attach_mappings = function(prompt_bufnr)
                    actions.select_default:replace(function()
                        actions.close(prompt_bufnr)
                        local selection = action_state.get_selected_entry()
                        vim.fn.chdir(selection.value)
                        vim.notify("Changed directory to: " .. selection.value)
                    end)
                    return true
                end,
            })
            :find()
    end
end

vim.api.nvim_create_user_command("Workspaces", function()
    if not pcall(require, "telescope") then
        vim.notify("Telescope.nvim is required to list workspaces", vim.log.levels.ERROR)
        return
    end
    create_picker()()
end, {})

return Workspaces
