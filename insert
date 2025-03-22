#!/usr/bin/env lua

require("luarocks.loader")
local Sh = require("minilib.shell")
local Ut = require("minilib.util")
local Pr = require("minilib.process")
local M = require("minilib.monad")

local distro_map = {
	["debian"] = {
		pm_install = "sudo apt-get install --no-install-recommends %s",
		pm_update = "sudo apt-get update",
		pm_search = "apt-cache search %s",
		pm_installed = "dpkg -L | grep '^ii' | grep -P '%s' ",
		pm_pkgfile = "apt-file search '%s'",
	},
	["fedora"] = {
		pm_install = "sudo dnf install -y %s",
		pm_update = "sudo dnf update",
		pm_search = "sudo dnf search %s",
		pm_installed = "rpm -q '%s'",
		pm_pkgfile = "rpm -qf '%s' --queryformat '%{NAME}\n'",
	},
	["arch"] = {
		pm_install = "sudo pacman -S %s",
		pm_update = "sudo pacman -Syu",
		pm_search = "sudo pacman -Ss %s",
		pm_installed = "pacman -q '%s'",
		pm_pkgfile = "sudo pacman -q %s",
	},
}

distro_map["ubuntu"] = distro_map["debian"]
distro_map["centos"] = distro_map["fedora"]

local Cache = {
	instance = Sh.util.lsb_release(),
}

local function assert_urltask(t)
	assert(t.url, "property 'url' expected")
	assert(t.name, "property 'name' expected")
	assert(t.ext, "property 'ext' expected")
	assert(t.cp, "property 'cp' expected")
end
local function assert_extracttask(t)
	assert(t.name, "property 'name' expected")
	assert(t.ext, "property 'ext' expected")
	assert(t.cp, "property 'cp' expected")
end
local function geturl(t)
	assert_urltask(t)

	if Sh.util.path_exists(t.path .. "/" .. t.name) then
		print("#geturl, cache hit", t.url, t.path, t.name)
		return t
	end
	Sh.util.wget(t.url, t.path .. "/" .. t.name)
	return t
end
local extmap = {
	["zip"] = "unzip -o ",
	["tar.gz"] = "tar --overwrite -xvzf ",
	["tar.xz"] = "tar --overwrite -xvf ",
	["tar.bz2"] = "tar --overwrite -xvjf ",
}
local function extract(t)
	assert_extracttask(t)
	local extcmd = extmap[t.ext]
	Sh.util.sh(string.format(
		[[
          cd %s 
          %s %s
          cp -av %s %s
          ]],
		t.path,
		extcmd,
		t.name,
		t.cp,
		t.dest
	))
	return t
end
local function ispkginst(name)
	local inst = Cache.instance
	local pm = distro_map[inst.distro]
	if pm then
		return Sh.util.sh(string.format(pm.pm_installed, name))
	end
end
local function pkgfile(file)
	local inst = Cache.instance
	local pm = distro_map[inst.distro]
	if pm then
		if type(file) == "table" then
			file = M.List.of(file):join(" ")
		end
		local s, e, ls = Sh.util.sh(string.format(pm.pm_install, file))
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
local function pkginst(pkginfo)
	print("#pkginst: ", Ut.tos(pkginfo))
	local names, install, methods = pkginfo.pkgname, pkginfo.required, pkginfo.methods
	local inst = Cache.instance
	local pm = distro_map[inst.distro]
	if not pm then
		print("#pkginst, unsupported distro", inst.distro)
		return { pkg = names, status = 1 }
	end
	print("#pkginst, exec!", string.format(pm.pm_install, names))
	if not install then
		return 1, names
	end
	local s, e, ls = Sh.util.sh(string.format(pm.pm_install, names))
	if not s then
		print("#pkginst failed", e, Ut.tos(ls))
		return 2, names
	end
	print("#pkginst done", names, Ut.tos(ls))
	return 0, names
end
local function update_configs(path, subhbs)
	print("#update_configs:", path)
	Pr.pipe()
		.add(Sh.find(path, "%.t$"))
		.add(function(f)
			return f
		end)
		.add(Sh.read())
		.add(Sh.sed(subhbs))
		.add(function(fline)
			if fline == nil then
				return nil
			end
			fline.path = fline.path:gsub("%.t", "")
			return fline
		end)
		.add(Sh.write("./"))
		.run()
end
local function prepare_configs()
	print("prepare_configs")
	local subcfg = require("config")
	local subhbs = {}
	for i, v in pairs(subcfg) do
		subhbs["{" .. i .. "}"] = v
	end
	update_configs("./", subhbs)
end
local function handle_pkg_deps(e)
	return M.List
		.of(e.depends)
		:filter(function(v)
			return type(v) == "string" -- TODO: handle custom function as depends
		end)
		:fmap(function(v)
			local p = Ut.std_split("|", v)
			-- print("dd->", p[1], p[2], p[3], type(p[2]))
			return { pkgname = p[1], required = (p[2] == "1"), methods = p[3] }
		end)
		:fmap(function(pinfo)
			pkginst(pinfo)
			return 1, e
		end)
end
local function handle_github_deps(e)
	return M.List
		.of(e.depends)
		:filter(function(v)
			if type(v) == "table" and v.method == "github" then
				return true
			end
			return false
		end)
		:fmap(function(v)
			local uri = string.format("curl -L https://raw.githubusercontent.com/%s/main/install | bash ", v.resource)
			print("#handle_github_deps", v.resource, "<-", uri)
			local s, er, ls = Sh.util.sh(uri)
			print("#handle_github_deps", v, s, er, Ut.tos(ls))
			return s, e, er
		end)
end
local function setup_config(cfg)
	print("#setup_config")
	prepare_configs()
	local cs = dofile(cfg)
	print(cs)
	for _, e in pairs(cs) do
		print("#setup_config", e.path)
		if e.depends then
			handle_pkg_deps(e)
			handle_github_deps(e)
		end
		if e.installer then
			e.installer()
		end
		if e.configure then
			e.configure()
		end
		print("Ok")
	end
	return 0
end

setup_config(arg[1])
