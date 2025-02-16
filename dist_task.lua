local function test()
	T.pkgfile("pactl")
	-- T.pkginst("tmux")
	local s, e, ls = T.ispkginst("syayedr")
	print("ispkginst", s, e, Ut.tos(ls))
	s, e, ls = T.ispkginst("sway")
	print("ispkginst", s, e, Ut.tos(ls))
end

test()

return T
