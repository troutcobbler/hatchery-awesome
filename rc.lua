-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
-- Tag icons
tag1 = ""
tag2 = ""
tag3 = ""
tag4 = ""
tag5 = "ﱘ"
tag6 = ""

-- Colors
foreground = "#a7a7a7"
background = "#202020"
color0     = "#2d2d2d"
color8     = "#605f61"
color1     = "#9d5b61"
color9     = "#9d5b61"
color2     = "#838d69"
color10    = "#838d69"
color3     = "#b38d6a"
color11    = "#b38d6a"
color4     = "#606d84"
color12    = "#606d84"
color5     = "#766577"
color13    = "#766577"
color6     = "#808fa0"
color14    = "#808fa0"
color7     = "#9c9a9a"
color15    = "#9c9a9a"

beautiful.init({
    -- Fonts
    font = "Inter 15",

    -- Background & foreground
    bg_normal = background,
    fg_normal = foreground,

    -- Borders & gaps
    border_focus      = "#6699cc",
    border_normal     = "#444444", 
    border_width      = 1,
    useless_gap       = 2,
    gap_single_client = false,

    -- Taglist
    taglist_bg_focus    = color0,
    taglist_fg_focus    = foreground,
    taglist_bg_occupied = color0,
    taglist_fg_occupied = foreground,
    taglist_bg_empty    = color0,
    taglist_fg_empty    = color8,
    taglist_spacing     = 6,

    -- Tooltips
    tooltip_bg = color0,
    tooltip_fg = foreground,

    -- Wallpaper
    wallpaper = true,
})

-- Notifications
local nconf = naughty.config
nconf.padding = 20
nconf.defaults.margin = 20
nconf.defaults.timeout = 3
nconf.presets.critical.bg = background 
nconf.presets.critical.fg = foreground

-- Wonky
wonky_font = "hack 12"
wonky_bg   = "#00000000"
wonky_fg   = "#808080"

-- Default applications 
terminal   = "xfce4-terminal"
launcher   = "rofi -show drun"
browser    = "firefox"
editor     = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor
volume_app = "pavucontrol"

-- Screenshot settings, use Printscreen or Alt + Printscreen for a selected area
scrot      = "scrot -F "..os.getenv("HOME").."/Pictures/'%Y-%m-%d-%s_$wx$h.png'"
scrot_sel  = "scrot -s -F "..os.getenv("HOME").."/Pictures/'%Y-%m-%d-%s_$wx$h.png'"

-- Power menu commands
suspend_cmd  = "systemctl suspend && slock" 
reboot_cmd   = "systemctl reboot"
logout_cmd   = awesome.quit
lock_cmd     = "slock"
poweroff_cmd = "systemctl poweroff"

-- Laptop backlight
-- Run "brightnessctl info" from the terminal to get your specific values
-- and then input them here.
backlight      = "amdgpu_bl0"
max_brightness = 255

-- Default modkey
-- Mod4 is the Super key, Mod1 is Alt 
modkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.floating,
}
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = ("/usr/share/backgrounds/hatchery/hatchery.png")
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.centered(wallpaper, s)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ tag1, tag2, tag3, tag4, tag5, tag6, }, s, awful.layout.layouts[1])

    -- Set some gaps and padding on the last tag
    awful.tag.attached_connect_signal(nil, "property::selected", function(t)
        local s = t.screen or awful.screen.focused()
        local padding = t.padding or 0
        s.padding = padding
    end)

    awful.tag.find_by_name(awful.screen.focused().tags[TAG_INDEX], tag6).padding = {
        left = 200, right = 200, top = 100, bottom = 100
    }
    awful.tag.find_by_name(awful.screen.focused().tags[TAG_INDEX], tag6).gap_single_client = true
    awful.tag.find_by_name(awful.screen.focused().tags[TAG_INDEX], tag6).gap = 50

    -- Shapes
    -- Bubble 
    bubble = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 5)
    end

    -- Tray widgets
    -- Launcher widget
    s.mylauncher = wibox.layout {
        layout = wibox.layout.fixed.vertical,
        {
            markup = "<span foreground='"..color6.."'></span>",
            align = "center",
            valign = "center",
            widget = wibox.widget.textbox,
        },
    }

    -- Launcher widget functions
    s.mylauncher:connect_signal('button::release', function(self)
        awful.spawn.easy_async(launcher, function() end)
    end)

    -- Taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        layout = wibox.layout.fixed.vertical,
        filter  = awful.widget.taglist.filter.all,
        widget_template = {
            {
                {
                    {
                        id     = 'text_role',
                        widget = wibox.widget.textbox,
                    },
                    widget = wibox.container.place,
                    layout = wibox.layout.fixed.horizontal,
                },
                widget = wibox.container.place,
                forced_width = tag_width,
            },
            id = 'background_role',
            widget = wibox.container.background,
        },
        buttons = taglist_buttons,
    }

    -- Battery widget       
    s.mybattery = wibox.layout {
        layout = wibox.layout.fixed.vertical,
        {
            top = 2, 
            bottom = 4, 
            widget = wibox.container.margin,
            {
                id = "icon",
                markup = "<span foreground='"..color4.."'></span>",
                align = "center",
                valign = "center",
                widget = wibox.widget.textbox,
            },
        },          
    }

    -- Battery widget timer
    s.mybattery_timer = gears.timer {
        timeout   = 60,
        call_now  = true,
        autostart = true,
        callback  = function()
            awful.spawn.easy_async(
                {"bash", "-c", "cat /sys/class/power_supply/BAT0/capacity"},
                function(stdout)

                    if tonumber(stdout) < 30 then
                        s.mybattery:get_children_by_id("icon")[1]:set_markup("<span foreground='"..color4.."'></span>")
                    else
                        s.mybattery:get_children_by_id("icon")[1]:set_markup("<span foreground='"..color4.."'></span>")
                    end

                end
            )
        end
    }

    -- Battery widget tooltip
    s.mybattery.tooltip = awful.tooltip { }
    s.mybattery.tooltip:add_to_object(s.mybattery)

    -- Battery widget tooltip function
    s.mybattery:get_children_by_id("icon")[1]:connect_signal('mouse::enter', function()
            awful.spawn.easy_async(
                {"bash", "-c", "cat /sys/class/power_supply/BAT0/capacity"},
                function(stdout)
                    tooltip = stdout:gsub("\n[^\n]*$", "")
                    s.mybattery.tooltip.text = "Battery: "..tooltip.."%"
                end
            )
    end)

    -- Network widget
    s.mynetwork = wibox.layout {
        layout = wibox.layout.fixed.vertical,
        {
            bottom = 4,
            widget = wibox.container.margin,
            {
                id = "icon",
                markup = "<span foreground='"..color5.."'>直</span>",
                align = "center",
                valign = "center",
                widget = wibox.widget.textbox,
            },
        },
    }

    -- Network widget timer 
    s.mynetwork_timer = gears.timer {
        timeout   = 10, 
        call_now  = true,
        autostart = true,
        callback  = function()
            awful.spawn.easy_async(
                {"bash", "-c", "cat /sys/class/net/w*/operstate"},
                function(stdout)

                    if string.match(stdout, "down") then
                        s.mynetwork:get_children_by_id("icon")[1]:set_markup("<span foreground='"..color5.."'>睊</span>")
                    else
                        s.mynetwork:get_children_by_id("icon")[1]:set_markup("<span foreground='"..color5.."'>直</span>")
                    end 

                end
            )   
        end
    }

    -- Network widget functions
    s.mynetwork:connect_signal('button::release', function(self)
        awful.spawn.easy_async(terminal.." -e ".."nmtui", function() end)
    end)

    -- Network widget tooltip
    s.mynetwork.tooltip = awful.tooltip { }
    s.mynetwork.tooltip:add_to_object(s.mynetwork)

    -- Network widget tooltip function
    s.mynetwork:get_children_by_id("icon")[1]:connect_signal('mouse::enter', function()
            awful.spawn.easy_async(
                {"bash", "-c", "nmcli | grep '^wlp'  | cut -d ':' -f2 | sed 's/ connected to /Network: /g'"},
                function(stdout)
                    tooltip = stdout:gsub("\n[^\n]*$", "")
                    s.mynetwork.tooltip.text = tooltip 
                end
            )
    end)

    -- Brightness widget
    s.mybrightness = wibox.layout {
        layout = wibox.layout.fixed.vertical,
        {
            bottom = 4,
            widget = wibox.container.margin,
            {
                layout = wibox.layout.fixed.vertical,
                {
                    id            = "slider_box",
                    direction     = 'east',
                    layout        = wibox.container.rotate,
                    forced_height = 0,
                    {
                        id               = "slider",
                        max_value        = 1,
                        value            = 0.33,
                        shape            = gears.shape.rounded_bar,
                        bar_shape        = gears.shape.rounded_bar,
                        background_color = background,
                        color            = color3,
                        margins = {
                            top    = 11,
                            bottom = 11,
                            left   = 4,
                            right  = 4,
                        },
                        widget = wibox.widget.progressbar,
                    },
                },
                {
                    id     = "icon",
                    markup = "<span foreground='"..color3.."'></span>",
                    align  = "center",
                    valign = "center",
                    widget = wibox.widget.textbox,
                },
            },
        },
    }

    -- Brightness widget functions
    -- Show slider when entering widget
    s.mybrightness:connect_signal('mouse::enter', function(self)

        -- Reflect brightness changes prior to opening widget
        awful.spawn.easy_async("brightnessctl g "..backlight, function(stdout)
            local brightness = tonumber(stdout)/max_brightness
            s.mybrightness:get_children_by_id("slider")[1]:set_value(brightness)
        end)

        -- Reveal slider
        s.mybrightness:get_children_by_id("slider_box")[1].forced_height = 88

    end)

    -- Hide slider when leaving widget
    s.mybrightness:connect_signal('mouse::leave', function(self)
        s.mybrightness:get_children_by_id("slider_box")[1].forced_height = 0
    end)

    -- Change brightness on click
    s.mybrightness:get_children_by_id("slider")[1]:connect_signal('button::release', function(lx, ly)

        local brightness = math.floor(ly/88*100)

        -- Slider is small make sure it get sets to 0 or 100
        if brightness < 10 then
            brightness = 0
        elseif brightness > 90 then
            brightness = 100
        end

        local command = "brightnessctl s "..tostring(brightness).."% "..backlight

        awful.spawn.easy_async(command, function() end)

        s.mybrightness:get_children_by_id("slider")[1]:set_value(brightness/100)

    end)

    -- Brightness widget tooltip
    s.mybrightness.tooltip = awful.tooltip { }
    s.mybrightness.tooltip:add_to_object(s.mybrightness:get_children_by_id("icon")[1])

    -- Brightness widget tooltip function
    s.mybrightness:get_children_by_id("icon")[1]:connect_signal('mouse::enter', function()
            awful.spawn.easy_async(
                {"bash", "-c", "brightnessctl g "..backlight},
                function(stdout)
                    tooltip = tostring(math.floor(tonumber(stdout)/max_brightness*100))
                    s.mybrightness.tooltip.text = "Brightness: "..tooltip.."%"
                end
            )
    end)

    -- Volume widget
    s.myvolume = wibox.layout {
        layout = wibox.layout.fixed.vertical,
        {
            bottom = 2, 
            widget = wibox.container.margin,
            {
                layout = wibox.layout.fixed.vertical,
                {
                    id            = "slider_box",
                    direction     = 'east',
                    layout        = wibox.container.rotate,
                    forced_height = 0,
                    {
                        id               = "slider",
                        max_value        = 1,
                        value            = 0.33,
                        shape            = gears.shape.rounded_bar,
                        bar_shape        = gears.shape.rounded_bar,
                        background_color = background,
                        color            = color2,
                        margins = {
                            top    = 11,
                            bottom = 11,
                            left   = 4,
                            right  = 4,
                        }, 
                        widget = wibox.widget.progressbar,
                    },
                },
                {
                    id = "icon",
                    markup = "<span foreground='"..color2.."'>墳</span>",
                    align = "center",
                    valign = "center",
                    widget = wibox.widget.textbox,
                },
            },
        },
    }

    -- Volume widget functions
    -- Show slider when entering widget
    s.myvolume:connect_signal('mouse::enter', function(self)

        -- Reflect volume changes prior to opening widget
        awful.spawn.easy_async("pamixer --get-volume", function(stdout)
            local volume = tonumber(stdout)/100
            s.myvolume:get_children_by_id("slider")[1]:set_value(volume)
        end)

        -- Reveal slider
        s.myvolume:get_children_by_id("slider_box")[1].forced_height = 88

    end)

    -- Hide slider when leaving widget
    s.myvolume:connect_signal('mouse::leave', function(self)
        s.myvolume:get_children_by_id("slider_box")[1].forced_height = 0
    end)

    -- Change volume on click
    s.myvolume:get_children_by_id("slider")[1]:connect_signal('button::release', function(lx, ly)

        local volume = math.floor(ly/88*100)

        -- Slider is small make sure it get sets to 0 or 100
        if volume < 10 then
            volume = 0
        elseif volume > 90 then
            volume = 100
        end

        local command = "pamixer --set-volume "..tostring(volume)

        awful.spawn.easy_async(command, function() end)

        s.myvolume:get_children_by_id("slider")[1]:set_value(volume/100)
           
    end)

    -- Launch volume_app when clicking on volume icon
    s.myvolume:get_children_by_id("icon")[1]:connect_signal('button::release', function()
        awful.spawn.easy_async(volume_app, function() end)
    end)

    -- Volume widget tooltip
    s.myvolume.tooltip = awful.tooltip { }
    s.myvolume.tooltip:add_to_object(s.myvolume:get_children_by_id("icon")[1])

    -- Volume widget tooltip function
    s.myvolume:get_children_by_id("icon")[1]:connect_signal('mouse::enter', function()
            awful.spawn.easy_async(
                {"bash", "-c", "pamixer --get-volume"},
                function(stdout)
                    tooltip = stdout:gsub("\n[^\n]*$", "")
                    s.myvolume.tooltip.text = "Volume: "..tooltip.."%"
                end
            )
    end)

    -- Clock widget
    s.myclock = wibox.layout {
        id = "clock",
        layout = wibox.layout.fixed.vertical,
        {
            align = "center",
            valign = "center",
            widget = wibox.container.place,
            wibox.widget.textclock('%H'),
        },
        {
            align = "center",
            valign = "center",
            widget = wibox.container.place,
            wibox.widget.textclock('%M'),
        },
    }

    -- Calendar widget (clock functions below)
    -- Calendar style
    calendar_style = {}

    calendar_style.month   = { padding      = 8,
                       bg_color     = background,
                       border_width = 2,
                       shape        = bubble
    }

    calendar_style.normal  = { shape    = bubble }

    calendar_style.focus   = { fg_color = background,
                       bg_color = color6,
                       markup   = function(t) return '<b>' .. t .. '</b>' end,
                       shape    = bubble
    }

    calendar_style.header  = { fg_color = foreground,
                       bg_color     = color0,
                       markup   = function(t) return '<b>' .. t .. '</b>' end,
                       shape    = bubble
    }

    calendar_style.weekday = { fg_color = foreground,
                       markup   = function(t) return '<b>' .. t .. '</b>' end,
                       shape    = bubble 
    }

    function decorate_calendar(widget, flag, date)
        if flag=='monthheader' and not styles.monthheader then
            flag = 'header'
        end

        local props = calendar_style[flag] or {}

        if props.markup and widget.get_text and widget.set_markup then
            widget:set_markup(props.markup(widget:get_text()))
        end

        -- Change bg color for weekends
        local d = {year=date.year, month=(date.month or 1), day=(date.day or 1)}
        local weekday = tonumber(os.date('%w', os.time(d)))
        local default_bg = (weekday==0 or weekday==6) and background or color0
        local default_fg = (weekday==0 or weekday==6) and color8 or foreground
        local ret = wibox.widget {
            {
                widget,
                margins = (props.padding or 2) + (props.border_width or 0),
                widget  = wibox.container.margin
            },
            shape              = props.shape,
            shape_border_color = props.border_color or color0,
            shape_border_width = props.border_width or 0,
            fg                 = props.fg_color or default_fg,
            bg                 = props.bg_color or default_bg,
            widget             = wibox.container.background
        }
        return ret
    end

    -- Calendar widget
    calendar = wibox.widget {
        date     = os.date('*t'),
        fn_embed = decorate_calendar,
        font     = beautiful.font,
        start_sunday = true,
        widget   = wibox.widget.calendar.month
    }

    -- Calendar popup
    s.myclock.calendar = awful.popup {
        widget = calendar,
        visible      = false,
        ontop        = true,
        placement = function(w)
            awful.placement.bottom_left(w, { offset = { x = 68, y = -20 } })
        end
    }

    -- Calendar state variable
    calendar_toggled = false

    -- Clock functions
    s.myclock:get_children_by_id("clock")[1]:connect_signal('button::release', function()
        calendar_toggled = not calendar_toggled
        if calendar_toggled then
            s.myclock.calendar.visible = true 
        else
            s.myclock.calendar.visible = false 
        end
    end)

    s.myclock:get_children_by_id("clock")[1]:connect_signal('mouse::enter', function()
        if calendar_toggled == false then
            calendar.date = nil 
            calendar.date = os.date('*t')
            s.myclock.calendar.visible = true
        end
    end)

    s.myclock:get_children_by_id("clock")[1]:connect_signal('mouse::leave', function()
        if calendar_toggled == false then
            s.myclock.calendar.visible = false 
        end
    end)

    -- Power widget
    s.mypower = wibox.layout {
        layout = wibox.layout.fixed.vertical,
        {
            id = "slider_box",
            layout = wibox.layout.fixed.vertical,
            forced_height = 0,
            {
                widget = wibox.container.margin,
                bottom = 6,
                {
                    id = "suspend",
                    markup = "<span foreground='"..color2.."'>鈴</span>",
                    align = "center",
                    valign = "center",
                    widget = wibox.widget.textbox,
                },
            },
            {
                bottom = 6,
                widget = wibox.container.margin,
                {
                    id = "reboot",
                    markup = "<span foreground='"..color3.."'>凌</span>",
                    align = "center",
                    valign = "center",
                    widget = wibox.widget.textbox,
                },
            },
            {
                bottom = 6,
                widget = wibox.container.margin, 
                {
                    id = "logout",
                    markup = "<span foreground='"..color5.."'>﫼</span>",
                    align = "center",
                    valign = "center",
                    widget = wibox.widget.textbox,
                },
            },
            {
                bottom = 6,
                widget = wibox.container.margin,
                {
                    id = "lock",
                    markup = "<span foreground='"..color4.."'></span>",
                    align = "center",
                    valign = "center",
                    widget = wibox.widget.textbox,
                },
            },
        },
        {
            bottom = 2,
            widget = wibox.container.margin,
            {
                id = "poweroff",
                markup = "<span foreground='"..color1.."'>襤</span>",
                align = "center",
                valign = "center",
                widget = wibox.widget.textbox,
            },
        },
    }

    -- Power widget functions
    -- Reveal menu 
    s.mypower:connect_signal('mouse::enter', function(self)
        s.mypower:get_children_by_id("slider_box")[1].forced_height = 116
    end)

    -- Hide menu when leaving widget
    s.mypower:connect_signal('mouse::leave', function(self)
        s.mypower:get_children_by_id("slider_box")[1].forced_height = 0
    end)

    -- We don't need a popup for lock
    s.mypower:get_children_by_id("lock")[1]:connect_signal('button::release', function()
        s.mypower:get_children_by_id("slider_box")[1].forced_height = 0
        awful.spawn.easy_async(lock_cmd, function() end)
    end)

    -- Power widget popups
    -- Suspend popup widgets
    suspend_cancel = wibox.widget {
        text   = "CANCEL",
        align = "center",
        halign = "center",
        widget = wibox.widget.textbox,
    }

    suspend_yes = wibox.widget {
        markup = "<span foreground='"..color2.."'>YES</span>",
        align = "center",
        halign = "center",
        widget = wibox.widget.textbox,
    }

    -- Suspend popup
    s.mypower.suspend = awful.popup {
        widget = {
            {
                {
                    widget = wibox.container.margin,
                    margins = 20,
                    {
                        text   = 'Suspend this computer?',
                        align = "center",
                        halign = "center",
                        widget = wibox.widget.textbox
                    },
                },
                {
                    {
                        top = 4,
                        bottom = 4,
                        left = 22,
                        right = 12,
                        widget = wibox.container.margin,
                        {
                            bg     = color0,
                            shape = bubble,
                            widget = wibox.container.background,
                            {
                                margins = 5,
                                widget = wibox.container.margin,
                                {
                                    widget = suspend_cancel,
                                },
                            },
                        },
                    },
                    {
                        top = 4,
                        bottom = 4,
                        left = 12,
                        right = 22,
                        widget = wibox.container.margin,
                        {
                            bg     = color0,
                            shape = bubble,
                            widget = wibox.container.background,
                            {
                                margins = 5,
                                widget = wibox.container.margin,
                                {
                                    widget = suspend_yes,
                                },
                            },
                        },
                    },
                    layout = wibox.layout.flex.horizontal,
                },
                layout = wibox.layout.fixed.vertical,
            },
            margins = 10,
            widget  = wibox.container.margin
        },
        placement    = awful.placement.centered,
        ontop        = true,
        visible      = false,
        minimum_width = 480,
        minimum_height = 120,
    }

    -- Suspend popup functions
    suspend_cancel:connect_signal("button::release", function(self)
        s.mypower.suspend.visible = false
    end)

    suspend_yes:connect_signal("button::release", function(self)
        s.mypower.suspend.visible = false
        awful.spawn.with_shell(suspend_cmd)
    end)

    s.mypower:get_children_by_id("suspend")[1]:connect_signal('button::release', function()
        s.mypower.suspend.visible = not s.mypower.suspend.visible
    end)

    -- Reboot popup widgets
    reboot_cancel = wibox.widget {
        text   = "CANCEL",
        align = "center",
        halign = "center",
        widget = wibox.widget.textbox,
    }

    reboot_yes = wibox.widget {
        markup = "<span foreground='"..color3.."'>YES</span>",
        align = "center",
        halign = "center",
        widget = wibox.widget.textbox,
    }

    -- Reboot popup
    s.mypower.reboot = awful.popup {
        widget = {
            {
                {
                    widget = wibox.container.margin,
                    margins = 20,
                    {
                        text   = 'Reboot this computer?',
                        align = "center",
                        halign = "center",
                        widget = wibox.widget.textbox
                    },
                },
                {
                    {
                        top = 4,
                        bottom = 4,
                        left = 22,
                        right = 12,
                        widget = wibox.container.margin,
                        {
                            bg     = color0,
                            shape = bubble,
                            widget = wibox.container.background,
                            {
                                margins = 5,
                                widget = wibox.container.margin,
                                {
                                    widget = reboot_cancel,
                                },
                            },
                        },
                    },
                    {
                        top = 4,
                        bottom = 4,
                        left = 12,
                        right = 22,
                        widget = wibox.container.margin,
                        {
                            bg     = color0,
                            shape = bubble,
                            widget = wibox.container.background,
                            {
                                margins = 5,
                                widget = wibox.container.margin,
                                {
                                    widget = reboot_yes,
                                },
                            },
                        },
                    },
                    layout = wibox.layout.flex.horizontal,
                },
                layout = wibox.layout.fixed.vertical,
            },
            margins = 10,
            widget  = wibox.container.margin
        },
        placement    = awful.placement.centered,
        ontop        = true,
        visible      = false,
        minimum_width = 480,
        minimum_height = 120,
    }

    -- Reboot popup functions
    reboot_cancel:connect_signal("button::release", function(self)
        s.mypower.reboot.visible = false
    end)

    reboot_yes:connect_signal("button::release", function(self)
        s.mypower.reboot.visible = false
        awful.spawn.easy_async(reboot_cmd, function() end)
    end)

    s.mypower:get_children_by_id("reboot")[1]:connect_signal('button::release', function()
        s.mypower.reboot.visible = not s.mypower.reboot.visible
    end)

    -- Logout popup widgets
    logout_cancel = wibox.widget {
        text   = "CANCEL",
        align = "center",
        halign = "center",
        widget = wibox.widget.textbox,
    }

    logout_yes = wibox.widget {
        markup = "<span foreground='"..color5.."'>YES</span>",
        align = "center",
        halign = "center",
        widget = wibox.widget.textbox,
    }

    -- Logout popup
    s.mypower.logout = awful.popup {
        widget = {
            {
                {
                    widget = wibox.container.margin,
                    margins = 20,
                    {
                        text   = 'Logout of this computer?',
                        align = "center",
                        halign = "center",
                        widget = wibox.widget.textbox
                    },
                },
                {
                    {
                        top = 4,
                        bottom = 4,
                        left = 22,
                        right = 12,
                        widget = wibox.container.margin,
                        {
                            bg     = color0,
                            shape = bubble,
                            widget = wibox.container.background,
                            {
                                margins = 5,
                                widget = wibox.container.margin,
                                {
                                    widget = logout_cancel,
                                },
                            },
                        },
                    },
                    {
                        top = 4,
                        bottom = 4,
                        left = 12,
                        right = 22,
                        widget = wibox.container.margin,
                        {
                            bg     = color0,
                            shape = bubble,
                            widget = wibox.container.background,
                            {
                                margins = 5,
                                widget = wibox.container.margin,
                                {
                                    widget = logout_yes,
                                },
                            },
                        },
                    },
                    layout = wibox.layout.flex.horizontal,
                },
                layout = wibox.layout.fixed.vertical,
            },
            margins = 10,
            widget  = wibox.container.margin
        },
        placement    = awful.placement.centered,
        ontop        = true,
        visible      = false,
        minimum_width = 480,
        minimum_height = 120,
    }

    -- Logout popup functions
    logout_cancel:connect_signal("button::release", function(self)
        s.mypower.logout.visible = false
    end)

    logout_yes:connect_signal("button::release", function(self)
        s.mypower.logout.visible = false
        logout_cmd()
    end)

    s.mypower:get_children_by_id("logout")[1]:connect_signal('button::release', function()
        s.mypower.logout.visible = not s.mypower.logout.visible
    end)

    -- Poweroff popup widgets
    poweroff_cancel = wibox.widget {
        text   = "CANCEL",
        align = "center",   
        halign = "center",  
        widget = wibox.widget.textbox,
    }                       
                            
    poweroff_yes = wibox.widget {
        markup = "<span foreground='"..color1.."'>YES</span>",
        align = "center",
        halign = "center",
        widget = wibox.widget.textbox,
    }               
             
    -- Poweroff popup
    s.mypower.poweroff = awful.popup {
        widget = {  
            {   
                {       
                    widget = wibox.container.margin,
                    margins = 20,
                    {   
                        text   = 'Poweroff this computer?',
                        align = "center",
                        halign = "center",
                        widget = wibox.widget.textbox
                    }, 
                },      
                {       
                    {
                        top = 4,
                        bottom = 4,
                        left = 22,
                        right = 12,
                        widget = wibox.container.margin,
                        {
                            bg     = color0,
                            shape = bubble,
                            widget = wibox.container.background,
                            {
                                margins = 5,
                                widget = wibox.container.margin,
                                {
                                    widget = poweroff_cancel,
                                },
                            },
                        },
                    },
                    {
                        top = 4,
                        bottom = 4,
                        left = 12,
                        right = 22,
                        widget = wibox.container.margin,
                        {   
                            bg     = color0,
                            shape = bubble,
                            widget = wibox.container.background,
                            {
                                margins = 5,
                                widget = wibox.container.margin,
                                {
                                    widget = poweroff_yes,
                                },
                            },
                        },
                    },  
                    layout = wibox.layout.flex.horizontal,
                },  
                layout = wibox.layout.fixed.vertical,
            },          
            margins = 10,
            widget  = wibox.container.margin
        },              
        placement    = awful.placement.centered,
        ontop        = true,
        visible      = false,
        minimum_width = 480,
        minimum_height = 120, 
    }                   
                        
    -- Poweroff popup functions 
    poweroff_cancel:connect_signal("button::release", function(self)
        s.mypower.poweroff.visible = false
    end)                    
                            
    poweroff_yes:connect_signal("button::release", function(self)
        s.mypower.poweroff.visible = false
        awful.spawn.easy_async(poweroff_cmd, function() end)
    end)

    s.mypower:get_children_by_id("poweroff")[1]:connect_signal('button::release', function()
        s.mypower.poweroff.visible = not s.mypower.poweroff.visible
    end)

    -- Wonky popup
    s.wonky = awful.popup {
        widget = {
            top    = 60,
            bottom = 0,
            left   = 0, 
            right  = 20,
            widget = wibox.container.margin,
            {
                widget = wibox.layout.fixed.vertical,
                {
                    text   = 'BASIC NAVIGATION',
                    font   = wonky_font,
                    widget = wibox.widget.textbox
                },
                {
                    text   = ' ',
                    font   = wonky_font,
                    widget = wibox.widget.textbox
                },
                {
                    text   = 'ALT+P            run command',
                    font   = wonky_font,
                    widget = wibox.widget.textbox
                },
                {
                    text   = 'ALT+SHIFT+ENTER  open terminal',
                    font   = wonky_font,
                    widget = wibox.widget.textbox
                },
                {
                    text   = 'ALT+Q            close window',
                    font   = wonky_font,
                    widget = wibox.widget.textbox
                },
                {
                    text   = 'ALT+1-6          switch between workspaces',
                    font   = wonky_font,
                    widget = wibox.widget.textbox
                },
                {
                    text   = 'ALT+SHIFT+1-6    move window to workspace',
                    font   = wonky_font,
                    widget = wibox.widget.textbox
                },
                {
                    text   = 'ALT+F12          show/hide this dialog',
                    font   = wonky_font,
                    widget = wibox.widget.textbox
                },
                {
                    text   = 'ALT+SHIFT+Q      logout',
                    font   = wonky_font,
                    widget = wibox.widget.textbox
                },
            },
        },
        placement     = awful.placement.top_right,
        ontop         = false,
        visible       = true,
        minimum_width = 300,
        bg            = wonky_bg,
        fg            = wonky_fg,
    }

    -- Create the wibox
    s.mywibox = awful.wibar({
        position = "left",
        screen = s,
        width = 48,
    })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.vertical,
        { -- Top widgets
            layout = wibox.layout.fixed.vertical,
            { -- Launcher 
                top = 8,
                bottom = 6,
                widget = wibox.container.margin,
                s.mylauncher,
            },
            { -- Taglist
                margins = 4,
                widget = wibox.container.margin,
                {
                    bg     = color0,
                    shape = bubble,
                    widget = wibox.container.background,
                    {
                        top = 8,
                        bottom = 8,
                        widget = wibox.container.margin,
                        s.mytaglist,
                    },
                },
            },
        },
        nil, -- Middle widget
        { -- Bottom widgets
            layout = wibox.layout.fixed.vertical,
            { -- Tray               
                top    = 4,
                bottom = 6,
                left   = 4,
                right  = 4,
                widget = wibox.container.margin,
                {
                    bg     = color0,
                    shape = bubble,
                    widget = wibox.container.background,
                    {
                        margins = 4,
                        widget = wibox.container.margin,
                        {
                            layout = wibox.layout.fixed.vertical,
                            s.mybattery,
                            s.mynetwork,
                            s.mybrightness,
                            s.myvolume,
                        },
                    },
                },
            },
            { -- Clock
                margins = 4,
                widget = wibox.container.margin,
                {
                    bg     = color0,
                    shape = bubble,
                    widget = wibox.container.background,
                    {
                        top = 5,
                        bottom = 5,
                        widget = wibox.container.margin,
                        s.myclock,
                    },
                },
            },
            { -- Power
                top = 6,
                bottom = 8,
                widget = wibox.container.margin,
                s.mypower,
            },
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () awful.spawn(browser) end,
              {description = "open a browser", group = "browser"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey, "Shift"   }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Launcher 
    awful.key({ modkey }, "p", function() awful.spawn.easy_async(launcher, function() end) end,
              {description = "show the launcher", group = "launcher"}),

    -- Screenshot
    awful.key({ }, "Print", function() awful.spawn.easy_async(scrot, function() end) end,
              {description = "take a screenshot", group = "screen"}),

    -- Screenshot selected area 
    awful.key({ modkey }, "Print", function() awful.spawn.easy_async(scrot_sel, function() end) end,
              {description = "take a screenshot of a selected area", group = "screen"}),

    -- Wonky
    awful.key({ modkey }, "F12",
        function()
            if awful.screen.focused().wonky.visible == false then
                awful.screen.focused().wonky.visible = true
            else
                awful.screen.focused().wonky.visible = false
            end
        end,
        {description = "toggle wonky", group = "screen"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey,           }, "q",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.centered + awful.placement.no_overlap+awful.placement.no_offscreen,
                     size_hints_honor = false
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = false }
    },

    -- Open nextcloud on tag6
    { rule = { instance = "nextcloud" },
      properties = { tag = tag6 } },

    -- Open atril on tag1
    { rule = { instance = "atril" },
      properties = { tag = tag1, switchtotag = true } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- Smart borders
screen.connect_signal("arrange", function (s)
    local only_one = #s.tiled_clients == 1
    for _, c in pairs(s.clients) do
        if only_one and not c.floating or c.maximized then
            c.border_width = 0
        else
            c.border_width = beautiful.border_width
        end
    end
end)
-- }}}
