local awful = require("awful")
local beautiful = require("beautiful")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local wibox = require("wibox")

local helpers = require("helpers")
local system_controls = require("helpers.system_controls")
local create_button = require("ui.exit_screen.create_button")

local dpi = beautiful.xresources.apply_dpi

local function hide_exit_screen()
    awesome.emit_signal("exit_screen::hide")
end

-- Commands
local function lock_command()
    awesome.emit_signal("lockscreen::visible", true)
end

local function suspend_command()
    lock_command()
    gtimer {
        timeout = 1,
        autostart = true,
        single_shot = true,
        callback = system_controls.suspend
    }
end

-- Create the buttons
local poweroff = create_button("\u{e8ac}", beautiful.red, "P", "oweroff", system_controls.poweroff)
local reboot = create_button("\u{f053}", beautiful.yellow, "R", "eboot", system_controls.reboot)
local suspend = create_button("\u{ef44}", beautiful.magenta, "S", "uspend", suspend_command)
local lock = create_button("\u{e897}", beautiful.green, "L", "ock", lock_command)
local exit = create_button("\u{e9ba}", beautiful.blue, "E", "xit", awesome.quit)

local create_exit_screen = function(s)
    s.exit_screen = wibox {
        screen = s,
        type = "splash",
        visible = false,
        ontop = true,
        bg = beautiful.black .. "D7",
        y = s.geometry.y,
        height = s.geometry.height,
        width = s.geometry.width
    }

    s.exit_screen:setup{
        {
            {
                poweroff,
                reboot,
                suspend,
                lock,
                exit,
                spacing = dpi(44),
                layout = wibox.layout.fixed.horizontal
            },
            {
                {
                    markup = "Press any of the listed keys to perform an action",
                    font = beautiful.font_name .. 13,
                    halign = "center",
                    widget = wibox.widget.textbox
                },
                fg = beautiful.xforeground .. "A0",
                widget = wibox.container.background
            },
            spacing = dpi(16),
            layout = wibox.layout.fixed.vertical
        },
        widget = wibox.container.place
    }

    s.exit_screen:buttons(
        gtable.join(
            awful.button({}, 2, hide_exit_screen), awful.button({}, 3, hide_exit_screen)
        )
    )
end

screen.connect_signal("request::desktop_decoration", create_exit_screen)

local exit_screen_grabber = awful.keygrabber {
    auto_start = true,
    stop_event = "release",
    keypressed_callback = function(_, _, key)
        if key == "s" then
            suspend_command()
        elseif key == "e" then
            awesome.quit()
        elseif key == "l" then
            lock_command()
        elseif key == "p" then
            system_controls.poweroff()
        elseif key == "r" then
            system_controls.reboot()
        end
        hide_exit_screen()
    end
}

awesome.connect_signal(
    "exit_screen::show", function()
        for s in screen do
            s.exit_screen.visible = true
        end
        exit_screen_grabber:start()
    end
)

awesome.connect_signal(
    "exit_screen::hide", function()
        exit_screen_grabber:stop()
        for s in screen do
            s.exit_screen.visible = false
        end
    end
)
