local Sh = require("minilib.shell")

local T = {}
function T.assert_urltask(t)
	assert(t.url, "property 'url' expected")
	assert(t.name, "property 'name' expected")
	assert(t.ext, "property 'ext' expected")
	assert(t.cp, "property 'cp' expected")
end
function T.assert_extracttask(t)
	assert(t.name, "property 'name' expected")
	assert(t.ext, "property 'ext' expected")
	assert(t.cp, "property 'cp' expected")
end
function T.geturl(t)
	T.assert_urltask(t)
	Sh.wget(t.url, "/tmp/dlfo_" .. t.name)
	return t
end
local extmap = {
	["zip"] = "unzip -o ",
	["tar.gz"] = "tar --overwrite -xvzf ",
	["tar.xz"] = "tar --overwrite -xvf ",
	["tar.bz2"] = "tar --overwrite -xvjf ",
}
function T.extract(t)
	T.assert_extracttask(t)
	local extcmd = extmap[t.ext]
	Sh.sh(string.format(
		[[
          cd /tmp
          %s dlfo_%s
          cp -av %s ~/.fonts/
          ]],
		extcmd,
		t.name,
		t.cp
	))
	return t
end
return T
