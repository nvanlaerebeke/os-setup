-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- Required for the mouse bindings
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'Tokyo Night'

config.keys = {
  -- This will create a new split and run your default program inside it
  {
    key = 'O',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  }, {
    key = 'E',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  }
}

config.mouse_bindings = {
        {
                event = { Down = { streak = 1, button = "Right" } },
                mods = "NONE",
                action = wezterm.action_callback(function(window, pane)
                        local has_selection = window:get_selection_text_for_pane(pane) ~= ""
                        if has_selection then
                                window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
                                window:perform_action(act.ClearSelection, pane)
                        else
                                window:perform_action(act({ PasteFrom = "Clipboard" }), pane)
                        end
                end),
        },
}

-- and finally, return the configuration to wezterm
return config