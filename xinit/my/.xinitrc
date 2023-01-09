xrdb -merge ~/.Xresources
xhost +

export XDG_SESSION_TYPE=x11
export GDK_BACKEND=x11
export XDG_CURRENT_DESKTOP=GNOME

$(cat /tmp/99-xinitrc)
