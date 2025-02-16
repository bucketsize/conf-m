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
		path = "chromium",
		depends = { "chromium" },
		configure = function()
			-- note; only works on arch linux
			Sh.ln("$(pwd)/chromium/chromium-flags.conf", "~/.config/chromium-flags.conf")

			-- other distros; custom entrypoint
			Sh.mkdir("~/.local/share/applications")
			Sh.ln("$(pwd)/chromium/chromium-accel.desktop", "~/.local/share/applications/chromium-accel.desktop")
		end,
	},
	{
		path = "firefox",
		configure = function()
			Pr.pipe()
				.add(Sh.exec('find -L ~/.mozilla/ ~/snap -name "xulstore.json" | grep -v backup'))
				.add(Sh.echo())
				.add(function(x)
					if x then
						local _, p = Sh.split_path(x)
						Sh.cp("$(pwd)/firefox/user.js", p)
					end
				end)
				.run()
		end,
		depends = { "firefox" },
		installer = function() end,
	},
	{
		path = "fontconfig",
		configure = function()
			Sh.ln("$(pwd)/fontconfig", "~/.config/fontconfig")
		end,
		depends = { "fc-list" },
		installer = function() end,
	},
	{
		path = "fonts",
		configure = function() end,
		depends = { "fc-cache", "curl" },
		installer = function()
			local d = Sh.test(Home .. "/.fonts")
			if d == nil or d == "file" then
				Sh.rm(Home .. "/.fonts")
				Sh.mkdir(Home .. "/.fonts")
			end

			Sh.sh([[mkdir -p /var/tmp/conf-m-cache/]])

			local fonts = {
				-- {
				-- 	url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/Agave.zip",
				-- 	name = "agave",
				-- 	ext = "zip",
				-- 	cp = "agave\\ regular\\ Nerd\\ Font\\ Complete.ttf " .. "agave\\ regular\\ Nerd\\ Font\\ Complete\\ Mono.ttf ",
				-- },
				{
					url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/DejaVuSansMono.zip",
					name = "dejavusansmono",
					path = "/var/tmp/conf-m-cache",
					ext = "zip",
					cp = "DejaVu\\ Sans\\ Mono*Complete\\ Mono.ttf",
					dest = "~/.fonts/",
				},
				{
					url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/DroidSansMono.zip",
					name = "droidsansmono",
					path = "/var/tmp/conf-m-cache",
					ext = "zip",
					cp = "Droid\\ Sans\\ Mono\\ Nerd\\ Font\\ Complete.otf "
						.. "Droid\\ Sans\\ Mono\\ Nerd\\ Font\\ Complete\\ Mono.otf ",
					dest = "~/.fonts/",
				},
				-- {
				-- 	url = "https://github.com/sunaku/tamzen-font/archive/refs/tags/Tamzen-1.11.5.tar.gz",
				-- 	name = "tamzen",
				-- 	ext = "tar.gz",
				-- 	cp = "/tmp/tamzen-font-Tamzen-1.11.5/otb/Tamzen*.otb",
				-- },
			}
			M.List.of(fonts):fmap(T.geturl):fmap(T.extract)

			Sh.sh([[
			cd ~/.fonts
			rm fonts.dir fonts.scale
			mkfontdir
			mkfontscale
			xset +fp "$HOME/.fonts"
			xset fp rehash
			fc-cache -fv
			]])
		end,
	},
	{
		path = "foot",
		configure = function()
			Sh.ln("$(pwd)/foot", "~/.config/foot")
		end,
		depends = { "foot" },
		installer = function() end,
	},
	{
		path = "gtkrc",
		configure = function()
			Sh.ln("$(pwd)/gtk/gtkrc-2.0", "~/.gtkrc-2.0")

			Sh.mkdir("~/.config/gtk-3.0")
			Sh.ln("$(pwd)/gtk/gtk.css", "~/.config/gtk-3.0/gtk.css")
			Sh.ln("$(pwd)/gtk/settings.ini", "~/.config/gtk-3.0/settings.ini")
		end,
		depends = {},
		installer = function() end,
	},
	{
		path = "ictl",
		configure = function()
			Sh.sh([[
			[ -d ~/.config/ictl ] || mkdir -v -p ~/.config/ictl
			[ -f ~/.config/ictl/config.json ] || cp -v $(pwd)/ictl/config.json ~/.config/ictl/
		]])
		end,
		depends = {
			"xterm",
			"xrandr",
			"fzf",
			"wmctrl",
			"pactl",
			"feh",
			"curl",
		},
		installer = function()
			Sh.ln("$(pwd)/ictl/wallpaper-1.jpg", "~/Pictures/wallpaper-1.jpg")
		end,
	},
	{
		path = "login.d",

		-- deprecated, use greetd / agreety
		-- local function setup_autologin()
		-- 	Sh.sh([[
		--     sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
		--     sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf <<EOF
		-- [Service]
		-- ExecStart=
		-- ExecStart=-/sbin/agetty --noissue --autologin jb %I $TERM
		-- Type=idle
		-- EOF
		-- 		]])
		-- end

		configure = function()
			Sh.sh([[
		[ -d /etc/systemd/logind.conf.d ] || sudo mkdir /etc/systemd/logind.conf.d	
		sudo cp -vf logind.d/*.conf /etc/systemd/logind.conf.d/
		]])
		end,
		depends = {
			"udevadm",
		},
		installer = function() end,
	},
	{
		path = "m360",
		configure = function()
			Sh.sh([[
			[ -d ~/.config/m360 ] || mkdir -v -p ~/.config/m360
			[ -f ~/.config/m360/config.json ] || cp -v $(pwd)/m360/config.json ~/.config/m360/
		]])
		end,
		depends = { "python3", "pactl", "curl" },
		installer = function() end,
	},
	{
		path = "mako",
		configure = function()
			Sh.ln("$(pwd)/mako", "~/.config/mako")
		end,
		depends = { "mako" },
		installer = function() end,
	},
	{
		path = "mangohud",
		configure = function()
			Sh.ln("$(pwd)/mangohud", "~/.config/MangoHud")
		end,
		depends = {
			"mangohud",
		},
		installer = function() end,
	},
	{
		path = "minilib",
		configure = function() end,
		depends = { "lua", "luarocks" },
		installer = function()
			local arch = Sh.arch()

			Sh.exec([[
			if [ -d ~/minilib ]; then
				cd ~/minilib && git pull
			else
				git clone https://github.com/bucketsize/minilib.git ~/minilib
			fi
		]])

			Sh.exec(string.format(
				[[
		LIBDIR=/usr/lib/%s-linux-gnu
		cd ~/minilib && luarocks make --local CRYPTO_LIBDIR=$LIBDIR OPENSSL_LIBDIR=$LIBDIR
		]],
				arch
			))
		end,
	},
	{
		path = "misc",
		configure = function()
			local function setup_bell()
				Sh.sh([[
		pcnobell=$(grep -Po "^set bell-style none" /etc/inputrc)
		if [ "$pcnobell" = "" ]; then
			echo "disabling pc bell"
			echo "set bell-style none" | sudo tee /etc/inputrc
		else
			echo "not disabling pc bell"
		fi
	]])
			end

			local function setup_dirs()
				local dirs = {
					["~/.config"] = {},
					["~/.cache"] = {},
					["~/.theme"] = {},
					["~/.wlprs"] = {},
					["~/.local/bin"] = {},
				}
				for k, _ in pairs(dirs) do
					Sh.mkdir(k)
				end
			end

			local function setup_bins()
				if not Sh.path_exists("~/.profile") then
					Sh.cp("$(pwd)/misc/profile", "~/.profile")
				end
				Sh.append(
					[[
# conf-m/misc
export PATH=~/.local/bin:~/.luarocks/bin:~/.bucketsize/scripts:/usr/sbin:$PATH
		]],
					"~/.profile"
				)
			end

			setup_dirs()
			setup_bell()
			setup_bins()
		end,
		depends = {},
		installer = function() end,
	},
	{
		path = "modprobe",
		configure = function() end,
		depends = { "modprobe" },
		installer = function()
			Sh.sh("sudo cp -v $(pwd)/modprobe.d/* /etc/modprobe.d/")
		end,
	},
	{
		path = "mxctl",
		configure = function()
			Sh.sh([[
			[ -d ~/.config/mxctl ] \
				|| mkdir -v -p ~/.config/mxctl
			[ -f ~/.config/mxctl/config ] \
				|| cp -v $(pwd)/mxctl/config ~/.config/mxctl/
		]])
		end,
		dependsOn = function()
			return Sh.file_exists({ "git", "make", "xrandr", "fzf", "wmctrl", "pactl", "feh" })
		end,
		installer = function()
			Sh.github_fetch("bucketsize", "mxctl")
			Sh.sh(string.format(
				[[
			export CRYPTO_INCDIR=/usr/include	
			LIBDIR=/usr/lib/%s-linux-gnu
			CRYPTO_LIBDIR=$LIBDIR
			OPENSSL_LIBDIR=$LIBDIR 
			cd ~/mxctl && luarocks make --local
		]],
				Sh.arch()
			))
		end,
	},
	{
		path = "network",
		configure = function()
			Sh.sh([[
		sudo cp $(pwd)/network/dhcpcd.conf /etc/dhcpcd.conf
		sudo cp $(pwd)/network/wpa_supplicant.conf /etc/wpa_supplicant/ 
		]])
		end,
		depends = {
			"dhcpcd",
			"wpa_supplicant",
		},
		installer = function() end,
	},
	{
		path = "nvim",
		configure = function()
			Sh.mkdir("~/.config/nvim")
			Sh.ln("$(pwd)/nvim", "~/.config/nvim")
			if
				Sh.path_exists("~/.var/app/io.neovim.nvim/config/user-dirs.dirs")
				and not Sh.path_exists("~/.var/app/io.neovim.nvim/config/nvim/init.lua")
			then
				Sh.ln("~/.config/nvim", "~/.var/app/io.neovim.nvim/config/nvim")
			end
		end,
		depends = { "nvim", "rg" },
		installer = function() end,
	},
	{
		path = "pipewire",
		configure = function()
			Sh.sh([[
		systemctl --user daemon-reload
		systemctl --user --now enable pipewire pipewire-pulse
		systemctl --user --now disable pulseaudio.service pulseaudio.socket
		systemctl --user mask pulseaudio
		]])
		end,
		depends = {
			"pipewire",
			"pipewire-pulse",
			"wireplumber",
		},
		installer = function()
			-- deprecated
			--    Sh.sh [[
			-- sessf=$HOME/.config/pipewire-media-session/with-pulseaudio
			-- servd=$HOME/.config/systemd/user
			--
			-- if [ ! -f $sessf ] ; then
			-- 	echo "installing pulse session [with-pulseaudio] ..."
			-- 	if [ ! -d "$HOME/.config/pipewire-media-session" ]; then
			-- 		mkdir -p $HOME/.config/pipewire-media-session
			-- 	fi
			-- 	touch $sessf
			-- fi
			--
			-- if [ "$(ls $servd/pipewire-pulse.*)" = "" ]; then
			-- 	echo "installing pulse service ..."
			-- 	cp -v /usr/share/doc/pipewire/examples/systemd/user/pipewire-pulse.* $servd/
			-- fi
			-- ]]
			Sh.sh([[
			[ -d ~/.config/pipewire ] \
				|| mkdir ~/.config/pipewire
			[ -d ~/.config/pipewire/media-session.d ] \
				|| cp -rv /usr/share/pipewire/media-session.d/ ~/.config/pipewire/
		]])
		end,
	},
	{
		path = "qt5ct",
		configure = function()
			Sh.ln("$(pwd)/qt5ct", "~/.config/qt5ct")
		end,
		depends = { "qt5ct" },
		installer = function() end,
	},
	{
		path = "rules.d",
		configure = function()
			Sh.sh([[
		[ -d /etc/udev/rules.d ] || sudo mkdir /etc/udev/rules.d	
		sudo cp -vf rules.d/* /etc/udev/rules.d/
		]])
		end,
		depends = { "udevadm" },
		installer = function() end,
	},
	{
		path = "sysctl.d",
		configure = function()
			Sh.sh([[
			sudo cp -vf sysctl.d/*.conf /etc/sysctl.d/
			sudo sysctl -p
		]])
		end,
		depends = {
			"sysctl",
		},
		installer = function() end,
	},
	{
		path = "thermald",
		configure = function()
			Sh.sh([[
			sudo cp -vf thermald/* /etc/thermald/
		]])
			print([[
			# NOTE
			On some systems, thermald.service starts with --adaptive flag.
			This does not honor xml configs and may not work properly. 

			Edit
				/lib/systemd/system/thermald.service
			Then
				systemctl daemon-reload
				systemctl restart thermald 
		]])
		end,
		depends = { "thermald" },
		installer = function() end,
	},
	{
		path = "datetimectl",
		configure = function()
			Sh.exec([[
			sudo timedatectl set-timezone Asia/Kolkata
		]])
		end,
		depends = { "timedatectl" },
		installer = function() end,
	},
	{
		path = "vim",
		configure = function()
			Sh.ln("$(pwd)/vim/vimrc", "~/.vimrc")
		end,
		depends = { "vim" },
		installer = function() end,
	},
	{
		path = "waybar",
		depends = {
			"waybar",
		},
		configure = function()
			Sh.ln("$(pwd)/waybar", "~/.config/waybar")
		end,
		installer = function()
			Sh.sh([[
			cp $(pwd)/waybar/bin/* ${HOME}/.local/bin/
			]])
		end,
	},
	{
		path = "xresources",
		configure = function()
			Sh.ln("$(pwd)/Xresources", "~/.config/xresources.d")
			Sh.ln("$(pwd)/Xresources/Xresources", "~/.Xresources")
			Sh.sh([[
			sudo cp -vf $(pwd)/Xresources/40*.conf /etc/X11/xorg.conf.d/
		]])
		end,
		dependsOn = function()
			return Sh.file_exists({ "xrdb" })
		end,
		depends = {
			"xrdb",
		},
		installer = function() end,
	},
	{
		path = "mpd",
		configure = function()
			Sh.mkdir("~/.mpd")
			Sh.ln("$(pwd)/mpd", "~/.config/mpd")

			-- going to disable automatic root start of mpd
			Sh.sh("sudo systemctl disable mpd")
		end,
		depends = { "mpd", "mpc" },
		installer = function() end,
	},
	{
		path = "ympd",
		configure = function() end,
		depends = {
			"mpd",
		},
		installer = function()
			if not Sh.file_exists("~/.local/bin/ympd") then
				local cmd = string.format(
					[[
				if [ -d ~/ympd ]; then
				cd ~/ympd
				git pull
				else
				git clone https://github.com/notandy/ympd.git
				cd ~/ympd
				fi
				export LIBDIR=/usr/lib/$%s-linux-gnu
				make ympd
				strip ympd
				cp -vf ympd ~/.local/bin/
				]],
					Sh.arch()
				)
				Sh.exec(cmd)
			end
		end,
	},
	{
		path = "mpv",
		configure = function()
			Sh.ln("$(pwd)/mpv", "~/.config/mpv")
		end,
		depends = { "mpv" },
		installer = function() end,
	},
}
