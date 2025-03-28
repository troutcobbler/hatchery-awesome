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
beautiful.init(gears.filesystem.get_configuration_dir () .. "theme.lua")

beautiful.gap_single_client = false
beautiful.font = "Inter 15"
beautiful.taglist_spacing = 6

-- This is used later as the default terminal and editor to run.
terminal = "xfce4-terminal"
launcher = "rofi_run.sh"
browser = "firefox"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
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
    awful.tag({ "", "", "", "", "ﱘ", "", }, s, awful.layout.layouts[1])

    -- Tray widgets
    -- Launcher widget
    s.mylauncher = wibox.layout {
        layout = wibox.layout.fixed.vertical,
        {
            markup = "<span foreground='#808fa0'></span>",
            align = "center",
            valign = "center",
            widget = wibox.widget.textbox,
        },
    }

    -- Launcher widget functions
    s.mylauncher:connect_signal('button::release', function(self)
        awful.spawn(launcher)
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
                markup = "<span foreground='#606d84'></span>",
                align = "center",
                valign = "center",
                widget = wibox.widget.textbox,
            },
        },          
    }

    -- Battery widget functions
    --s.mybattery:connect_signal('button::release', function(self)
    --    awful.spawn.easy_async("nada", function() end)
    --end)

    -- Network widget
    s.mynetwork = wibox.layout {
        layout = wibox.layout.fixed.vertical,
        {
            bottom = 4,
            widget = wibox.container.margin,
            {
                markup = "<span foreground='#766577'>直</span>",
                align = "center",
                valign = "center",
                widget = wibox.widget.textbox,
            },
        },
    }

    -- Network widget functions
    s.mynetwork:connect_signal('button::release', function(self)
        awful.spawn.easy_async(terminal.." -e ".."nmtui", function() end)
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
                    direction     = 'east',
                    layout        = wibox.container.rotate,
                    forced_height = 0,
                    {
                        max_value        = 1,
                        value            = 0.33,
                        shape            = gears.shape.rounded_bar,
                        bar_shape        = gears.shape.rounded_bar,
                        background_color = "#202020",
                        color            = "#b38d6a",
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
                    markup = "<span foreground='#b38d6a'></span>",
                    align = "center",
                    valign = "center",
                    widget = wibox.widget.textbox,
                },
            },
        },
    }

    -- Brightness widget functions
    s.mybrightness:connect_signal('mouse::enter', function(self)

        -- Get table of children widgets
        local children = self:get_all_children()

        -- Reflect brightness changes prior to opening widget
        awful.spawn.easy_async("brightnessctl g amdgpu_bl0", function(stdout)
            local volume = tonumber(stdout)/255
            children[4]:set_value(volume)
        end)

        -- Reveal slider
        children[3].forced_height = 88

        -- Change brightness on click
        children[4]:connect_signal('button::release', function(lx, ly)

            local brightness = math.floor(ly/88*100)

            -- Slider is small make sure it get sets to 0 or 100
            if brightness < 10 then
                brightness = 0
            elseif brightness > 90 then
                brightness = 100
            end

            local command = "brightnessctl s "..tostring(brightness).."% ".."amdgpu_bl0"

            awful.spawn.easy_async(command, function() end)

            children[4]:set_value(brightness/100)

            --naughty.notify{text = "Brightness: "..brightness.."%"}

        end)

    end)

    -- Hide slider when leaving widget
    s.mybrightness:connect_signal('mouse::leave', function(self)
        local children = self:get_all_children()
        children[3].forced_height = 0
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
                    direction     = 'east',
                    layout        = wibox.container.rotate,
                    forced_height = 0,
                    {
                        max_value        = 1,
                        value            = 0.33,
                        shape            = gears.shape.rounded_bar,
                        bar_shape        = gears.shape.rounded_bar,
                        background_color = "#202020",
                        color            = "#838d69",
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
                    markup = "<span foreground='#838d69'>墳</span>",
                    align = "center",
                    valign = "center",
                    widget = wibox.widget.textbox,
                },
            },
        },
    }

    -- Volume widget functions
    s.myvolume:connect_signal('mouse::enter', function(self)

        -- Get table of children widgets
        local children = self:get_all_children()

        -- Reflect volume changes prior to opening widget
        awful.spawn.easy_async("pamixer --get-volume", function(stdout)
            local volume = tonumber(stdout)/100
            children[4]:set_value(volume)
        end)

        -- Reveal slider
        children[3].forced_height = 88

        -- Change volume on click
        children[4]:connect_signal('button::release', function(lx, ly)

            local volume = math.floor(ly/88*100)

            -- Slider is small make sure it get sets to 0 or 100
            if volume < 10 then
                volume = 0
            elseif volume > 90 then
                volume = 100
            end

            local command = "pamixer --set-volume "..tostring(volume)

            awful.spawn.easy_async(command, function() end)
            
            children[4]:set_value(volume/100)
           
            --naughty.notify{text = "Volume: "..volume.."%" }

        end)

        -- launch pavucontrol when clicking on volume icon
        children[5]:connect_signal('button::release', function()
            awful.spawn("pavucontrol")
        end)

    end)

    -- Hide slider when leaving widget
    s.myvolume:connect_signal('mouse::leave', function(self)
        local children = self:get_all_children()
        children[3].forced_height = 0
    end)

    -- Clock widget
    s.myclock = wibox.layout {
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

    -- Clock functions
    -- Calendar widget
    s.mycalendar = awful.widget.calendar_popup.month {
        start_sunday = true,
        margin = 20,
    }

    -- Attach calendar to clock
    s.mycalendar:attach(s.myclock, "bl")

    -- Power widget
    s.mypower = wibox.layout {
        layout = wibox.layout.fixed.vertical,
        {
            layout = wibox.layout.fixed.vertical,
            forced_height = 0,
            {
                widget = wibox.container.margin,
                bottom = 4,
                {
                    markup = "<span foreground='#838d69'>鈴</span>",
                    align = "center",
                    valign = "center",
                    widget = wibox.widget.textbox,
                },
            },
            {
                bottom = 4,
                widget = wibox.container.margin,
                {
                    markup = "<span foreground='#b38d6a'>凌</span>",
                    align = "center",
                    valign = "center",
                    widget = wibox.widget.textbox,
                },
            },
            {
                bottom = 4,
                widget = wibox.container.margin, 
                {
                    markup = "<span foreground='#766577'>﫼</span>",
                    align = "center",
                    valign = "center",
                    widget = wibox.widget.textbox,
                },
            },
            {
                bottom = 4,
                widget = wibox.container.margin,
                {
                    markup = "<span foreground='#606d84'></span>",
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
                markup = "<span foreground='#9d5b61'>襤</span>",
                align = "center",
                valign = "center",
                widget = wibox.widget.textbox,
            },
        },
    }

    -- Power widget functions
    s.mypower:connect_signal('button::release', function(self)
        awful.spawn.easy_async("slock", function() end)
    end)

    s.mypower:connect_signal('mouse::enter', function(self)

        -- Get table of children widgets
        local children = self:get_all_children()

        -- Reveal menu 
        children[1].forced_height = 108

    end)

    -- Hide slider when leaving widget
    s.mypower:connect_signal('mouse::leave', function(self)
        local children = self:get_all_children()
        children[1].forced_height = 0
    end)

    -- Create some shapes for our widgets
    local bubble = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 5)
    end

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "left", screen = s, width = 48 })

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
                    bg     = '#2d2d2d',
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
                    bg     = '#2d2d2d',
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
                    bg     = '#2d2d2d',
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

    -- Prompt
    --awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
    --          {description = "run prompt", group = "launcher"}),

    --awful.key({ modkey }, "x",
    --          function ()
    --              awful.prompt.run {
    --                prompt       = "Run Lua code: ",
    --                textbox      = awful.screen.focused().mypromptbox.widget,
    --                exe_callback = awful.util.eval,
    --                history_path = awful.util.get_cache_dir() .. "/history_eval"
    --              }
    --          end,
    --          {description = "lua execute prompt", group = "awesome"}),
    -- Launcher 
    awful.key({ modkey }, "p", function() awful.spawn(launcher) end,
              {description = "show the launcher", group = "launcher"})
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
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
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

    -- Set nextcloud to always map on the tag named ""
    { rule = { instance = "nextcloud" },
      properties = { tag = "" } },

    -- Set atril to always map on the tag named ""
    { rule = { instance = "atril" },
      properties = { tag = "", switchtotag = true } },
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
