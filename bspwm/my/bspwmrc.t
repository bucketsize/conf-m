#! /bin/sh

bspc monitor -d I II III IV 
bspc config border_width         2
bspc config window_gap           4

bspc config split_ratio          0.5
bspc config borderless_monocle   true
bspc config gapless_monocle      false
bspc config focus_follows_pointer false

# browsers
bspc rule -a Chromium desktop=^2
bspc rule -a Chromium-browser desktop=^2
bspc rule -a Firefox  desktop=^2
bspc rule -a firefox  desktop=^2
bspc rule -a Navigator desktop=^2

# ide
bspc rule -a Eclipse  desktop=^3 state=floating

# image viewers/editors
bspc rule -a Gimp desktop=^4 state=floating follow=on
bspc rule -a Gpicview state=floating
bspc rule -a Qiv state=floating

# media players
bspc rule -a Mpv state=floating
bspc rule -a vlc state=floating

# widgets
bspc rule -a Conky state=floating
bspc rule -a Popeye state=floating follow=on

# gaming
bspc rule -a Steam desktop=^5 state=floating follow=on

bspc config normal_border_color		      "{color_normal}"
bspc config active_border_color	          "{color_active}"
bspc config focused_border_color	      "{color_active}"
bspc config presel_feedback_color	      "{color_active_pre}"
bspc config urgent_border_color 	      "{color_urgent}"

# java sh*t
export _JAVA_AWT_WM_NONREPARENTING=1

# autostart items
~/.config/autostart/old/autostart_bspwm
