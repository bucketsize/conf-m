require("luarocks.loader")
local Sh = require("minilib.shell")
local Ut = require("minilib.util")
local M = require("minilib.monad")
local distro_map = {
	["Debian"] = {
		pm = "apt install --no-install-recommends %s",
		pm_update = "apt update",
		pm_search = "apt-cache search %s",
		pm_installed = "dpkg -L | grep '^ii' |",
		pm_pkgfile = "apt-file search '%s'",
	},
}
local T = {}
function T.pkgfile(file)
	local inst = Sh.lsb_release()
	local pm = distro_map[inst.distro]
	if pm then
		local s, e, ls = Sh.sh(string.format(pm.pm_pkgfile, file))
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

local function test()
	T.pkgfile("pactl")
end

test()

return T
