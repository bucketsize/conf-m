#include "{home}/.config/xresources.d/colors-terminal.sexy-4"

!#define FONTMONO -*-{font_monospace}-*-*-*-*-{font_monospace_size}-*-*-*-*-*-iso8859-*

#define FONT 	 xft:{font}:size={font_size}
#define FONTMONO xft:{font_monospace}:size={font_monospace_size},xft:cozette:size=13

!global Font
*font:         FONT

!xft -- matchup with fontconfig
Xft.dpi:       96
Xft.antialias: true
Xft.hinting:   true
Xft.autohint:  false
Xft.hintstyle: hintslight
Xft.rgba:      rgb
Xft.lcdfilter: lcddefault

!emacs
!emacs.fontBackend: 
emacs.bitmapIcon: on
emacs.font: FONTMONO
emacs.geometry: 90x25

!dunst
dunst.font: FONT

!xterm
xterm*faceName: FONTMONO

!urxvt
URxvt.depth: 32
URxvt*scrollBar: false
URxvt*font: FONTMONO
URxvt*buffered: false
URxvt.lineSpace: 0
URxvt.letterSpace: 0
URxvt*borderless: 1
URxvt*underlineColor: pink
URxvt*colorUL: pink
URxvt*iconFile: {term_icon} 
URxvt.geometry: 96x24
URxvt*skipBuiltinGlyphs: true
URxvt.urgentOnBell: false
URxvt.visualBell: false
URxvt.iso14755: false
