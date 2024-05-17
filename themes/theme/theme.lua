local gears = require("gears")
local lain = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local dpi = require("beautiful.xresources").apply_dpi

local my_table = awful.util.table or gears.table

local black = "#000000"
local white = "#FFFFFF"
local active = "#d88166"
local default = "#5f849c"
local gray = "#575757"

local theme = {}
theme.font = "Mononoki Nerd Font 16"
theme.fg_normal = default
theme.fg_focus = active
theme.fg_urgent = "#CC9393"
theme.bg_normal = black
theme.bg_focus = black
theme.bg_urgent = "#2a1f1e"
theme.border_width = dpi(1)
theme.border_normal = "#302627"
theme.border_focus = active
theme.border_marked = "#CC9393"
theme.taglist_fg_focus = active
theme.tasklist_bg_focus = black
theme.tasklist_bg_normal = black
theme.tasklist_fg_focus = active
theme.tasklist_fg_normal = gray
theme.menu_height = dpi(20)
theme.menu_width = dpi(200)
theme.layout_txt_tile = "[t]"
theme.layout_txt_tileleft = "[l]"
theme.layout_txt_tilebottom = "[b]"
theme.layout_txt_tiletop = "[tt]"
theme.layout_txt_fairv = "[fv]"
theme.layout_txt_fairh = "[fh]"
theme.layout_txt_spiral = "[s]"
theme.layout_txt_dwindle = "[d]"
theme.layout_txt_max = "[m]"
theme.layout_txt_fullscreen = "[F]"
theme.layout_txt_magnifier = "[M]"
theme.layout_txt_floating = "[|]"
theme.tasklist_plain_task_name = true
theme.tasklist_disable_icon = false
theme.useless_gap = dpi(0)

-- lain related
theme.layout_txt_termfair = "[termfair]"
theme.layout_txt_centerfair = "[centerfair]"

local markup = lain.util.markup

-- Clock
local date_clock = wibox.widget.textclock(" %H:%M")
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

-- Battery
local bat = lain.widget.bat({
	settings = function()
		local perc = bat_now.perc
		local icon = "󰂄:"
		local conv_perc = tonumber(bat_now.perc)
		if conv_perc == nil then
			conv_perc = 0
		end
		local perc_as_num = math.floor(conv_perc)
		if perc_as_num == 100 then
			icon = "󰁹:"
		end
		if perc_as_num >= 90 then
			icon = "󰂂:"
		end
		if perc_as_num >= 80 then
			icon = "󰂁:"
		end
		if perc_as_num >= 70 then
			icon = "󰂀:"
		end
		if perc_as_num >= 60 then
			icon = "󰁿:"
		end
		if perc_as_num >= 50 then
			icon = "󰁾:"
		end
		if perc_as_num >= 40 then
			icon = "󰁽:"
		end
		if perc_as_num >= 30 then
			icon = "󰁼:"
		end
		if perc_as_num >= 20 then
			icon = "󰁻:"
		end
		if perc_as_num >= 10 then
			icon = "󰁺:"
		end

		if bat_now.ac_status == 1 then
			icon = "󰂄:"
		end
		widget:set_markup(markup.font(theme.font, markup("#FF0087", " " .. icon .. perc .. "%")))
	end,
})

-- ALSA volume
theme.volume = lain.widget.alsa({
	settings = function()
		local header = " :"
		local vlevel = volume_now.level

		if volume_now.status == "off" then
			header = " 󰝟 :"
		end

		widget:set_markup(markup.font(theme.font, markup("#AAFF00", header .. vlevel)))
	end,
})

-- Filesystem
local fs_widget = require("widgets.fs")
local fs_prompt = wibox.widget.textbox(markup.font(theme.font, markup("#34B7EB", " :")))

-- Separators
local first = wibox.widget.textbox(markup.font(theme.font, ""))
local spr = wibox.widget.textbox("  |  ")

local function update_txt_layoutbox(s)
	-- Writes a string representation of the current layout in a textbox widget
	local txt_l = theme["layout_txt_" .. awful.layout.getname(awful.layout.get(s))] or ""
	s.mytxtlayoutbox:set_text(txt_l)
end

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
	s.mytxtlayoutbox = wibox.widget.textbox(theme["layout_txt_" .. awful.layout.getname(awful.layout.get(s))])
	awful.tag.attached_connect_signal(s, "property::selected", function()
		update_txt_layoutbox(s)
	end)
	awful.tag.attached_connect_signal(s, "property::layout", function()
		update_txt_layoutbox(s)
	end)
	s.mytxtlayoutbox:buttons(my_table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 2, function()
			awful.layout.set(awful.layout.layouts[1])
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
	s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.selected, awful.util.taglist_buttons)

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, awful.util.tasklist_buttons)

	-- Create the wiboxes
	s.mywiboxtop = awful.wibar({ position = "top", screen = s, height = dpi(25) })

	-- Add widgets to the wibox
	s.mywiboxtop:setup({
		layout = wibox.layout.align.horizontal,
		{
			layout = wibox.layout.fixed.horizontal,
			first,
			s.mytaglist,
			spr,
			s.mytxtlayoutbox,
			s.mypromptbox,
			spr,
			date_clock,
			spr,
		},
		s.mytasklist,
		{
			layout = wibox.layout.fixed.horizontal,
			bat.widget,
			spr,

			theme.volume.widget,
			spr,

			fs_prompt,
			fs_widget({ mounts = { "/home" } }),
			spr,

			wibox.widget.systray(),
		},
	})
end

return theme
