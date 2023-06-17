local dejavu_sans_mono = "DejaVuSansMono Nerd Font Mono"
local agave_mono = "agave Nerd Font Mono"

return {

	-- latest def is considered --

	home = os.getenv("HOME"),
	font = "DejaVu",
	font_size = "12",
	font_monospace = dejavu_sans_mono,
	font_monospace_size = "10",
	font_family_monospace = dejavu_sans_mono,
	font_family_monospace_alt = dejavu_sans_mono,
	font_family_serif = "DejaVu Serif",
	font_family_serif_alt = "Liberation Serif",
	font_family_sans = "DejaVu Sans",
	font_family_sans_alt = "Libaration Sans",
	openbox_theme = "Arc-Dark", --"Nightmare",
	gtk_theme = "Arc", --"Adwaita-Dark",
	gtk_theme_isdark = "1", --"Adwaita-Dark",
	gtk_icon_theme = "Arc", --"Adwaita",
	gtk_cursor_theme = "Arc", --"Adwaita",
	dock_position = "Top",
	font_conky = agave_mono,
	font_conky_size = "12",

	-- window border colors
	color_normal = "#644832",
	color_active = "#ba4824",
	color_active_pre = "#884824",
	color_urgent = "#2448aa",
}
