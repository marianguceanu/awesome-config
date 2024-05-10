local gears = require("gears")
local lain = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local dpi = require("beautiful.xresources").apply_dpi

local os = os
local my_table = awful.util.table or gears.table

local theme = {}
theme.zenburn_dir = require("awful.util").get_themes_dir() .. "theme"
theme.dir = os.getenv("HOME") .. "~/.config/awesome/themes/theme"
theme.font = "Mononoki Nerd Font 15"
theme.fg_normal = "#8451b8"
theme.fg_focus = "#d88166"
theme.fg_urgent = "#CC9393"
theme.bg_normal = "#000000"
theme.bg_focus = "#0F0F0F"
theme.bg_urgent = "#2a1f1e"
theme.border_width = dpi(1)
theme.border_normal = "#302627"
theme.border_focus = "#c2745b"
theme.border_marked = "#CC9393"
theme.taglist_fg_focus = "#d88166"
theme.tasklist_bg_focus = "#1c2024"
theme.tasklist_bg_normal = "#0F0F0F"
theme.tasklist_fg_focus = "#d88166"
theme.tasklist_fg_normal = "#d88166"
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
theme.useless_gap = dpi(5)

-- lain related
theme.layout_txt_termfair = "[termfair]"
theme.layout_txt_centerfair = "[centerfair]"

local markup = lain.util.markup

-- Date
local date = wibox.widget.textclock("  :%a-%d-%B ")
date.font = theme.font

-- Clock
local clock = wibox.widget.textclock("  :%H:%M ")
clock.font = theme.font

-- Calendar
theme.cal = lain.widget.cal({
	attach_to = { date },
	notification_preset = {
		font = theme.font,
		fg = theme.fg_normal,
		bg = theme.bg_normal,
	},
})

-- CPU
local cpu = lain.widget.sysload({
	settings = function()
		widget:set_markup(markup.font(theme.font, markup("#00FF7C", " " .. load_1 .. "GHz")))
	end,
})

-- MEM
local mem = lain.widget.mem({
	settings = function()
		widget:set_markup(markup.font(theme.font, markup("#FF8F00", "  " .. mem_now.used .. "MB")))
	end,
})

-- Battery
local bat = lain.widget.bat({
	settings = function()
		local perc = bat_now.perc .. "%"
		if bat_now.ac_status == 1 then
			perc = bat_now.perc .. "%  "
		end
		widget:set_markup(markup.font(theme.font, markup("#FF0087", "  " .. perc)))
	end,
})

-- Net checker
-- local net = lain.widget.net({
-- 	settings = function()
-- 		local net_state = "Off"
-- 		if net_now.state == "up" then
-- 			net_state = "On"
-- 		else
-- 			net_state = "Off"
-- 		end
-- 		widget:set_markup(markup.font(theme.font, "󰖩 " .. net_state .. " "))
-- 	end,
-- })

-- ALSA volume
theme.volume = lain.widget.alsa({
	settings = function()
		local header = "  "
		local vlevel = volume_now.level

		if volume_now.status == "off" then
			header = " 󰝟 "
		end

		widget:set_markup(markup.font(theme.font, markup("#AAFF00", header .. vlevel)))
	end,
})

-- Separators
local first = wibox.widget.textbox(markup.font(theme.font, ""))
local spr = wibox.widget.textbox("||")
local empty_spr = wibox.widget.textbox("   ")

local function update_txt_layoutbox(s)
	-- Writes a string representation of the current layout in a textbox widget
	local txt_l = theme["layout_txt_" .. awful.layout.getname(awful.layout.get(s))] or ""
	s.mytxtlayoutbox:set_text(txt_l)
end

-- Filesystem
local fs_widget = require("widgets.fs")
local fs_prompt = wibox.widget.textbox(markup.font(theme.font, markup("#34B7EB", " :")))

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
	s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.taglist_buttons)

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, awful.util.tasklist_buttons)

	-- Create the wiboxes
	s.mywiboxtop = awful.wibar({ position = "top", screen = s, height = dpi(25) })
	s.mywiboxbot = awful.wibar({ position = "bottom", screen = s, height = dpi(25) })

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
		},
		nil,
		{
			layout = wibox.layout.fixed.horizontal,
			fs_prompt,
			fs_widget({ mounts = { "/home" } }),
			empty_spr,
			spr,
			empty_spr,

			bat.widget,
			empty_spr,
			spr,
			empty_spr,

			theme.volume.widget,
			empty_spr,
			spr,
			empty_spr,

			cpu.widget,
			empty_spr,
			spr,
			empty_spr,

			mem.widget,
			empty_spr,
			spr,
			empty_spr,

			wibox.widget.systray(),
		},
	})
	s.mywiboxbot:setup({
		layout = wibox.layout.align.horizontal,
		{
			layout = wibox.layout.fixed.horizontal,
		},
		s.mytasklist,
		{
			layout = wibox.layout.fixed.horizontal,
			date,
			spr,
			clock,
		},
	})
end

return theme
