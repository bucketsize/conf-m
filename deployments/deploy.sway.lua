#!/usr/bin/env lua
require("luarocks.loader")

local Sh = require("minilib.shell")
local Ut = require("minilib.util")
local Pr = require("minilib.process")
local M = require("minilib.monad")
local T = require("task")
local Home = os.getenv("HOME")

return {
	{
		path = "sway",
		configure = function()
			Sh.util.ln("$(pwd)/sway", "~/.config/sway")
		end,
		depends = { "sway|1", "swayidle", "swaylock" },
		installer = function() end,
	},
	{
		path = "foot",
		configure = function()
			Sh.util.ln("$(pwd)/foot", "~/.config/foot")
		end,
		depends = { "foot|1" },
		installer = function() end,
	},
	{
		path = "mako",
		configure = function()
			Sh.util.ln("$(pwd)/mako", "~/.config/mako")
		end,
		depends = { "mako|1" },
		installer = function() end,
	},
	{
		path = "wayland-tools",
		configure = function() end,
		depends = { "wlr-randr|1", "wlsunset", "wl-clipboard", "kanshi", "grim|1", "slurp" },
		installer = function() end,
	},
	{
		path = "waybar",
		depends = {
			"waybar",
		},
		configure = function()
			Sh.util.ln("$(pwd)/waybar", "~/.config/waybar")
		end,
		installer = function()
			Sh.util.sh([[
			cp $(pwd)/waybar/bin/* ${HOME}/.local/bin/
			]])
		end,
	},
}
