---@diagnostic disable: no-unknown

local wezterm = require("wezterm")
local config = wezterm.config_builder()
local action = wezterm.action

-- Platform detection
local is_darwin = wezterm.target_triple:find("darwin") ~= nil
local is_linux = wezterm.target_triple:find("linux") ~= nil
local is_windows = wezterm.target_triple:find("windows") ~= nil

-- Set environment variables (platform-specific)
if is_darwin then
	config.set_environment_variables = {
		PATH = "/opt/homebrew/bin:" .. os.getenv("PATH"),
	}
elseif is_linux then
	config.set_environment_variables = {
		PATH = "/usr/local/bin:" .. os.getenv("PATH"),
	}
end

-- Set appearance
config.color_scheme = "ayu"
config.font = wezterm.font("0xProto Nerd Font")
config.font_size = 15.5
config.line_height = 1.1
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.93
config.use_fancy_tab_bar = true

-- macOS-specific settings
if is_darwin then
	config.macos_window_background_blur = 30
end

config.window_frame = {
	font = wezterm.font("0xProto Nerd Font"),
	font_size = 12,
	active_titlebar_bg = "#000000",
	inactive_titlebar_bg = "#111111",
}

config.colors = {
	tab_bar = {
		active_tab = {
			bg_color = "#000000",
			fg_color = "#c0c0c0",
		},
		inactive_tab = {
			bg_color = "#212121",
			fg_color = "#808080",
		},
	},
}

-- Animation Framerate
config.animation_fps = 120
config.max_fps = 120

-- Set Key Bindings (platform-aware)
local super = is_darwin and "CMD" or "CTRL"
local alt = is_darwin and "OPT" or "ALT"

config.keys = {
	{
		-- Move left word
		key = "LeftArrow",
		mods = alt,
		action = action.SendString("\x1bb"),
	},
	{
		-- Move right word
		key = "RightArrow",
		mods = alt,
		action = action.SendString("\x1bf"),
	},
	{
		-- Delete word backwards
		key = "Backspace",
		mods = alt,
		action = action.SendKey({ mods = "CTRL", key = "w" }),
	},
	{
		-- Delete whole line
		key = "Backspace",
		mods = super,
		action = action.SendKey({ mods = "CTRL", key = "u" }),
	},
	{
		-- Open wezterm config_file
		key = ",",
		mods = "SUPER",
		action = action.SpawnCommandInNewTab({
			cwd = wezterm.home_dir,
			args = { os.getenv("SHELL"), "-l", "-i", "-c", "nvim " .. wezterm.config_file },
		}),
	},
	{
		-- Show the launcher
		key = "F3",
		mods = super,
		action = action.ShowLauncher,
	},
	{
		-- Open new split vertical pane
		key = "d",
		mods = super .. "|SHIFT",
		action = action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		-- Open new split horizontal pane
		key = "d",
		mods = super,
		action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		-- Activate pane selection mode with the default alphabet (labels are "a", "s", "d", "f" and so on)
		key = "8",
		mods = "CTRL",
		action = action.PaneSelect,
	},
	{
		-- Activate pane selection mode with numeric labels
		key = "9",
		mods = "CTRL",
		action = action.PaneSelect({
			alphabet = "1234567890",
		}),
	},
	{
		-- Show the pane selection mode, but have it swap the active and selected panes
		key = "0",
		mods = "CTRL",
		action = action.PaneSelect({
			mode = "SwapWithActive",
		}),
	},
	{
		-- Clear scrollback buffer and viewport
		key = "k",
		mods = super,
		action = action.ClearScrollback("ScrollbackAndViewport"),
	},
	{
		-- Close the current pane with confirmation
		key = "w",
		mods = super,
		action = action.CloseCurrentPane({ confirm = true }),
	},
	{
		-- Close the current tab with confirmation
		key = "w",
		mods = super .. "|SHIFT",
		action = action.CloseCurrentTab({ confirm = true }),
	},
	{
		-- Move cursor to beginning of line
		key = "LeftArrow",
		mods = super,
		action = action.SendKey({ key = "Home" }),
	},
	{
		-- Move cursor to end of line
		key = "RightArrow",
		mods = super,
		action = action.SendKey({ key = "End" }),
	},
	{
		-- Open the command palette
		key = "p",
		mods = super .. "|SHIFT",
		action = action.ActivateCommandPalette,
	},
	{
		-- Open Shell (Domain wolf-family)
		key = "F1",
		mods = "CTRL|SHIFT",
		action = action.SpawnCommandInNewTab({
			cwd = wezterm.home_dir,
			args = { os.getenv("SHELL"), "-l", "-i", "-c", "ssh wolf-family" },
		}),
	},
	{
		-- Open Vim in current directory
		key = "e",
		mods = super .. "|" .. alt,
		action = action.SpawnCommandInNewTab({
			args = { os.getenv("SHELL"), "-l", "-i", "-c", "nvim" },
		}),
	},
	{ key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b\r" }) },
}

-- Platform-specific keybindings
if is_windows then
	-- Add Windows-specific keybindings if needed
	table.insert(config.keys, {
		key = "v",
		mods = "CTRL|SHIFT",
		action = action.PasteFrom("Clipboard"),
	})
end

----------------
--- GUI Customizations

local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
local SOLID_RIGHT_ARROW = utf8.char(0xe0b0)

local function merge_arrays(...)
	local result = {}
	for _, arr in ipairs({ ... }) do
		for _, v in ipairs(arr) do
			table.insert(result, v)
		end
	end
	return result
end

-- Format a section with background and foreground colors
local function format_section(text, bg, fg, is_first, prev_bg)
	local section = {}

	if not is_first then
		table.insert(section, { Background = { Color = prev_bg or "none" } })
		table.insert(section, { Foreground = { Color = bg } })
		table.insert(section, { Text = SOLID_LEFT_ARROW })
	end

	table.insert(section, { Background = { Color = bg } })
	table.insert(section, { Foreground = { Color = fg } })
	table.insert(section, { Text = " " .. text .. " " })

	return section
end

-- Get battery status (if available)
local function get_battery_info()
	for _, b in ipairs(wezterm.battery_info()) do
		return string.format("%.0f%%", b.state_of_charge * 100)
	end
	return nil
end

-- Get current working directory
local function get_cwd(pane)
	local cwd = pane:get_current_working_dir()
	if cwd then
		if type(cwd) == "userdata" then
			cwd = cwd.file_path
		end
		-- Simplify home directory
		local home = os.getenv("HOME")
		if home and cwd:find(home, 1, true) == 1 then
			cwd = "~" .. cwd:sub(#home + 1)
		end
		-- Get last two directories
		local parts = {}
		for part in string.gmatch(cwd, "[^/]+") do
			table.insert(parts, part)
		end
		if #parts > 2 then
			return ".../" .. parts[#parts - 1] .. "/" .. parts[#parts]
		end
		return cwd
	end
	return ""
end

-- Initialize status bar
wezterm.on("update-status", function(window, pane)
	local colors = window:effective_config().resolved_palette
	local sections = {}

	-- Color scheme
	local bg1 = "#1a1a1a"
	local bg2 = "#2a2a2a"
	local bg3 = "#3a3a3a"
	local fg = colors.foreground

	-- Current working directory
	local cwd = get_cwd(pane)
	if cwd and cwd ~= "" then
		local cwd_sections = format_section(cwd, bg1, fg, true, nil)
		for _, s in ipairs(cwd_sections) do
			table.insert(sections, s)
		end
	end

	-- Date and time
	local date = wezterm.strftime("%a %b %-d %H:%M")
	local time_sections = format_section(date, bg2, fg, false, bg1)
	for _, s in ipairs(time_sections) do
		table.insert(sections, s)
	end

	-- Battery info (if available)
	local battery = get_battery_info()
	if battery then
		local battery_sections = format_section(battery, bg3, fg, false, bg2)
		for _, s in ipairs(battery_sections) do
			table.insert(sections, s)
		end
	end

	-- Hostname
	local hostname_sections = format_section(wezterm.hostname(), "#000000", fg, false, bg3)
	for _, s in ipairs(hostname_sections) do
		table.insert(sections, s)
	end

	window:set_right_status(wezterm.format(sections))
end)

-- Format tab title
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local colors = config.resolved_palette

	-- Process category mapping
	local process_categories = {
		-- Editors
		editors = { "nvim", "vim", "vi", "nano", "emacs", "micro", "helix", "code" },
		-- Monitoring
		monitoring = { "top", "htop", "btop", "gtop", "iotop", "nvtop" },
		-- Development/Runtime
		development = { "node", "python", "python3", "ruby", "cargo", "npm", "yarn", "pnpm", "bun" },
		-- Shells
		shells = { "bash", "zsh", "fish", "sh", "dash", "ksh" },
		-- Version Control
		vcs = { "git", "tig", "lazygit" },
		-- Network
		network = { "ssh", "telnet", "nc", "curl", "wget" },
		-- File Managers
		files = { "ranger", "nnn", "lf", "mc", "yazi" },
		-- Database
		database = { "psql", "mysql", "redis-cli", "mongosh", "sqlite3" },
		-- Container/Cloud
		container = { "docker", "kubectl", "podman", "k9s" },
		-- Build Tools
		build = { "make", "cmake", "gradle", "mvn" },
	}

	-- Category icons (using Nerd Font icons for consistent sizing)
	local category_icons = {
		editors = utf8.char(0xe7c5), -- nf-dev-vim
		monitoring = utf8.char(0xf080), -- nf-fa-bar_chart
		development = utf8.char(0xe615), -- nf-seti-config
		shells = utf8.char(0xe795), -- nf-dev-terminal
		vcs = utf8.char(0xe725), -- nf-dev-git_branch
		network = utf8.char(0xf0ac), -- nf-fa-globe
		files = utf8.char(0xf07c), -- nf-fa-folder_open
		database = utf8.char(0xf1c0), -- nf-dev-database
		container = utf8.char(0xf308), -- nf-linux-docker
		build = utf8.char(0xf085), -- nf-fa-cogs
	}

	-- Get process name
	local process_name = tab.active_pane.foreground_process_name
	if process_name then
		process_name = process_name:match("([^/]+)$") or process_name
	else
		process_name = nil
	end

	-- Get current directory (basename only)
	local cwd = tab.active_pane.current_working_dir
	local dir_name = ""
	if cwd then
		if type(cwd) == "userdata" then
			cwd = cwd.file_path
		end
		dir_name = cwd:match("([^/]+)/?$") or ""
		local home = os.getenv("HOME")
		if home and cwd == home then
			dir_name = "~"
		end
	end

	-- Tab index
	local tab_index = tab.tab_index + 1

	-- Find process category
	local icon = nil
	local category = nil
	if process_name then
		for cat_name, processes in pairs(process_categories) do
			for _, proc in ipairs(processes) do
				if process_name == proc then
					icon = category_icons[cat_name]
					category = cat_name
					break
				end
			end
			if icon then
				break
			end
		end
	end

	-- Build title
	local title
	if not process_name or category == "shells" then
		-- No process or shell → show directory only
		title = string.format("%d · %s", tab_index, dir_name)
	elseif category == "editors" then
		-- Editors → try to extract filename from pane title
		local pane_title = tab.active_pane.title or ""
		local filename = pane_title:match("([^/]+)$") or process_name
		-- Remove common editor prefixes
		filename = filename:gsub("^nvim%s*", ""):gsub("^vim%s*", ""):gsub("^%s+", "")
		if filename == "" or filename == process_name then
			filename = dir_name
		end
		title = string.format("%d %s %s", tab_index, icon, filename)
	elseif icon then
		-- Has icon → show icon only (no process name)
		title = string.format("%d %s", tab_index, icon)
	else
		-- No icon → show process name
		title = string.format("%d · %s", tab_index, process_name)
	end

	-- Colors
	local bg = tab.is_active and colors.tab_bar.active_tab.bg_color or colors.tab_bar.inactive_tab.bg_color
	local fg = tab.is_active and colors.tab_bar.active_tab.fg_color or colors.tab_bar.inactive_tab.fg_color

	return {
		{ Background = { Color = bg } },
		{ Foreground = { Color = fg } },
		{ Text = " " .. title .. " " },
	}
end)

-- (This is where our config will go)
wezterm.log_info("Hello world! my name is " .. wezterm.hostname())

-- Returns our config to be evaluated. We must always do this at the bottom of this file
return config
