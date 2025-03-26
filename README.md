# nvim-workspaces

A simple yet powerful workspace management plugin for Neovim, with Telescope integration.

## Features

- Add, remove, and list named workspaces (directory paths)
- Persistent storage of workspaces in JSON format
- Telescope integration for visual workspace selection
- Quickly add current directory as a workspace
- Change directories by selecting a workspace

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "mtfrsantos/nvim-workspaces"
    dependencies = { "nvim-telescope/telescope.nvim" }, -- optional
    config = true,
}
```

## Configuration

Default configuration:

```lua
require("workspaces").setup({
    file_path = vim.fn.stdpath("data") .. "/workspaces.json", -- default storage location
})
```

## Usage

### Commands

- `:WorkspaceAdd <name> <path>` - Add a new workspace
- `:WorkspaceRemove <name>` - Remove a workspace
- `:WorkspaceAddCurrent` - Add current directory as a workspace (prompts for name)
- `:Workspaces` - Open Telescope picker to select a workspace (requires Telescope)

### API

You can also use the plugin's Lua API directly:

```lua
local workspaces = require("workspaces")

-- Add a workspace
workspaces.add("project1", "~/projects/project1")

-- Remove a workspace
workspaces.remove("project1")

-- List all workspaces
local all_workspaces = workspaces.list()
```

### Telescope Integration

If you have [Telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) installed, you can use the `:Workspaces` command to open an interactive picker. Selecting a workspace will change your current directory to that workspace.

You can also create a custom keybinding:

```lua
vim.keymap.set("n", "<leader>w", ":Workspaces<CR>", { desc = "Open workspaces picker" })
```

## Example Workflow

1. Navigate to your project directory
1. Run `:WorkspaceAddCurrent` and give it a name
1. Later, quickly switch back using `:Workspaces` and selecting your project

## Requirements

- Neovim 0.7 or higher
- (Optional) Telescope.nvim for the visual picker

## License

MIT
