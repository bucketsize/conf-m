require("luarocks.loader")
local Sh = require("minilib.shell")
local Ut = require("minilib.util")
local M = require("minilib.monad")
local distro_map = {
	["Debian"] = {
		pm_install = "apt install --no-install-recommends %s",
		pm_update = "apt update",
		pm_search = "apt-cache search %s",
		pm_installed = "dpkg -L | grep '^ii' |",
		pm_pkgfile = "apt-file search '%s'",
	},
}
local pkg_alias = {
	["Debian"] = {
		alacritty = "alacritty",
		bspwm = "bspwm",
		sxhkd = "sxhkd",
		feh = "feh",
		lxpolkit = "lxpolkit",
		tint2 = "tint2",
		picom = "picom",
		dunst = "dunst",
		lemonbar = "lemonbar",
	},
}
local Cache = {
	instance = Sh.lsb_release(),
}

local T = {}
function T.pkgfile(file)
	local inst = Cache.instance
	local pm = distro_map[inst.distro]
	if pm then
		if type(file) == "table" then
			file = M.List.of(file):join(" ")
		end
		local s, e, ls = Sh.sh(string.format(pm.pm_install, file))
		if not s then
			print("pkgfile failed", e)
			return {}
		end
		local r = M.List.of(ls):fmap(function(l)
			local x, y = l:match("([%w%p]+):%s+([%w%p]+)")
			return { x, y }
		end)
		return r
	else
		print("unsupported distro", inst.distro)
		return {}
	end
end
function T.pkgalias(name)
	local inst = Cache.instance
	local pm = distro_map[inst.distro]
	if not pm then
		print("unsupported distro", inst.distro)
		return nil
	end
	return pkg_alias[inst.distro][name]
end
function T.pkginst(name)
	print("#pkginst", name)
	local inst = Cache.instance
	local pm = distro_map[inst.distro]
	if not pm then
		print("unsupported distro", inst.distro)
		return {}
	end
	if type(name) == "table" then
		name = M.List.of(name):join(" ")
	end
	local s, e, ls = Sh.sh(string.format(pm.pm_pkgfile, name))
	if not s then
		print("pkginst failed", e)
		return {}
	end
	return { pkg = name, status = 0 }
end

local function test()
	T.pkgfile("pactl")
	T.pkginst("tmux")
end

return T
