local beautiful = require("beautiful")
local wibox = require("wibox")
local gshape = require("gears.shape")

local helpers = require("helpers")
local color_helpers = require("helpers.color-helpers")

local text_icon = require("ui.widgets.text-icon")
local clickable_container = require("ui.widgets.clickable-container")

local bg_focused = beautiful.accent .. "40"

local icon = text_icon {
    text = "\u{e7f4}",
    size = 14,
    fill = 0
}

local button = clickable_container {
    widget = icon,
    shape = gshape.circle,
    margins = dpi(4),
    bg_focused = bg_focused,
    action = helpers.toggle_silent_mode
}

awesome.connect_signal(
    "notifications::suspended", function(suspended)
        if suspended then
            icon.markup = color_helpers.colorize_text("\u{e7f6}", beautiful.accent)
        else
            icon.markup = color_helpers.colorize_text("\u{e7f4}", beautiful.fg)
        end
        button.bg = suspended and bg_focused or beautiful.black
        button.focused = suspended
    end
)

return button
