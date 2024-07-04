local gears = require("gears")
local lain = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local dpi = require("beautiful.xresources").apply_dpi

local background = "#14161b"
local main = "#215578"
local gray = "#242424"
local white = "#ffffff"

local nerd_font = "Fira Sans SemiBold 14"

local theme = {}
theme.font = nerd_font
theme.fg_normal = main
theme.fg_focus = gray
theme.fg_urgent = main
theme.bg_normal = background
theme.bg_focus = background
theme.bg_urgent = gray
theme.border_width = dpi(3)
theme.border_normal = gray
theme.border_focus = main
theme.border_marked = gray
theme.taglist_fg_focus = white
theme.taglist_bg_focus = main
theme.tasklist_bg_focus = gray
theme.tasklist_bg_normal = background
theme.tasklist_fg_focus = white
theme.tasklist_fg_normal = main
theme.menu_height = dpi(20)
theme.menu_width = dpi(200)
theme.layout_tile = "~/.config/awesome/theme/layouts/tilew.png"
theme.layout_max = "~/.config/awesome/theme/layouts/maxw.png"
theme.layout_floating = "~/.config/awesome/theme/layouts/floatingw.png"
-- theme.layout_fairh = "~/.config/awesome/themes/theme/layouts/fairhw.png"
-- theme.layout_fairv = "~/.config/awesome/themes/theme/layouts/fairvw.png"
-- theme.layout_magnifier = "~/.config/awesome/themes/theme/layouts/magnifierw.png"
-- theme.layout_fullscreen = "~/.config/awesome/themes/theme/layouts/fullscreenw.png"
-- theme.layout_tilebottom = "~/.config/awesome/themes/theme/layouts/tilebottomw.png"
-- theme.layout_tileleft = "~/.config/awesome/themes/theme/layouts/tileleftw.png"
-- theme.layout_tiletop = "~/.config/awesome/themes/theme/layouts/tiletopw.png"
-- theme.layout_spiral = "~/.config/awesome/themes/theme/layouts/spiralw.png"
-- theme.layout_dwindle = "~/.config/awesome/themes/theme/layouts/dwindlew.png"
-- theme.layout_cornernw = "~/.config/awesome/themes/theme/layouts/cornernww.png"
-- theme.layout_cornerne = "~/.config/awesome/themes/theme/layouts/cornernew.png"
-- theme.layout_cornersw = "~/.config/awesome/themes/theme/layouts/cornersww.png"
-- theme.layout_cornerse = "~/.config/awesome/themes/theme/layouts/cornersew.png"
theme.tasklist_plain_task_name = true
theme.tasklist_disable_icon = false
theme.useless_gap = dpi(5)

local markup = lain.util.markup

-- Clock
local date_clock = wibox.widget.textclock("%H:%M")
date_clock.font = theme.font

-- Calendar
theme.cal = lain.widget.cal({
	attach_to = { date_clock },
	notification_preset = {
		font = theme.font,
		fg = theme.fg_normal,
		bg = theme.bg_normal,
	},
})

local function icon_util(perc)
	local conv_perc = tonumber(perc)
	if conv_perc == nil then
		conv_perc = 0
	end
	local perc_as_num = math.floor(conv_perc)
	if perc_as_num == 100 then
		return "󰁹 "
	end
	if perc_as_num >= 90 then
		return "󰂂 "
	end
	if perc_as_num >= 80 then
		return "󰂁 "
	end
	if perc_as_num >= 70 then
		return "󰂀 "
	end
	if perc_as_num >= 60 then
		return "󰁿 "
	end
	if perc_as_num >= 50 then
		return "󰁾 "
	end
	if perc_as_num >= 40 then
		return "󰁽 "
	end
	if perc_as_num >= 30 then
		return "󰁼 "
	end
	if perc_as_num >= 20 then
		return "󰁻 "
	end
	if perc_as_num >= 10 then
		return "󰁺 "
	end
	return "󰂄 "
end

-- Battery
local bat = lain.widget.bat({
	settings = function()
		local perc = bat_now.perc
		local icon = icon_util(perc)
		if bat_now.ac_status == 1 then
			icon = "󰂄 "
		end
		widget:set_markup(markup.font(theme.font, icon .. perc .. "%"))
	end,
})

-- ALSA volume
theme.volume = lain.widget.alsa({
	settings = function()
		local header = "  "
		local vlevel = volume_now.level

		if volume_now.status == "off" then
			header = " 󰝟 "
		end

		widget:set_markup(markup.font(theme.font, header .. vlevel))
	end,
})

-- Filesystem
local fs_widget = require("widgets.fs")

-- Separators
local first = wibox.widget.textbox(markup.font(theme.font, ""))
local spr = wibox.widget.textbox("  |  ")

function theme.at_screen_connect(s)
	-- Quake application
	s.quake = lain.util.quake({ app = awful.util.terminal })

	-- If wallpaper is a function, call it with the screen
	local wallpaper = theme.wallpaper
	if type(wallpaper) == "function" then
		wallpaper = wallpaper(s)
	end
	gears.wallpaper.maximized(wallpaper, s, true)

	-- Tags
	awful.tag(awful.util.tagnames, s, awful.layout.layouts[1])

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()

	-- Textual layoutbox
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(gears.table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end),
		awful.button({}, 4, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 5, function()
			awful.layout.inc(-1)
		end)
	))
	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.taglist_buttons)

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, awful.util.tasklist_buttons)

	-- Create the wiboxes
	s.mywibox = awful.wibar({ position = "top", screen = s, height = dpi(30) })

	-- Add widgets to the wibox
	s.mywibox:setup({
		layout = wibox.layout.align.horizontal,
		{
			layout = wibox.layout.fixed.horizontal,
			s.mytaglist,
			s.mypromptbox,
			spr,
			date_clock,
			spr,
		},
		s.mytasklist,
		{
			layout = wibox.layout.fixed.horizontal,
			spr,

			bat.widget,
			spr,

			theme.volume.widget,
			spr,

			fs_widget({ mounts = { "/" } }),
			spr,

			wibox.widget.systray(),
			spr,

			s.mylayoutbox,
		},
	})
end

return theme
