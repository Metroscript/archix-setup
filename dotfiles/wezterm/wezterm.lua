---- TAB APPEARANCE

local wezterm = require ("wezterm")

local config = {
    -- Font
    font = wezterm.font 'Hack Nerd Font Mono',
    font_size = 10,

    --Cursor
    default_cursor_style = "BlinkingUnderline",
    animation_fps = 1,
    cursor_blink_rate = 750,
    cursor_thickness = "0.15pt",

    -- Terminal Appearance
   -- window_background_image = "$PATH_TO",
    use_fancy_tab_bar = false,
    show_tab_index_in_tab_bar = false,
    hide_tab_bar_if_only_one_tab = true,
    tab_bar_at_bottom = true,
    adjust_window_size_when_changing_font_size = false,
    initial_cols = 99,
    initial_rows = 37,
    window_padding = {
        left = "2px",
        right = "2px",
        top = "2px",
        bottom = "2px"
    },
    
    -- Terminal Interaction
    term ="wezterm",
    audible_bell = "Disabled",
    check_for_updates = false,
    detect_password_input = false,
    warn_about_missing_glyphs = false,
    disable_default_key_bindings = true,
    scrollback_lines = 10000,
    enable_scroll_bar = false,
    swallow_mouse_click_on_pane_focus = true,
    front_end = "WebGpu",

    -- Alacritty Theming
    colors = {
        ansi = {
            "#181818", --Black
            "#ac4242", --Red
            "#90a959", --Green
            "#f4bf75", --Yellow
            "#6a9fb5", --Blue
            "#aa759f", --Magenta
            "#75b5aa", --Cyan
            "#d8d8d8" --White
        },
        brights = {
            "#6b6b6b", --Black
            "#c55555", --Red
            "#aac474", --Green
            "#feca88", --Yellow
            "#82b8c8", --Blue
            "#c28cb8", --Magenta
            "#93d3c3", --Cyan
            "#f8f8f8" --White
        },
        foreground = "#d8d8d8",
        background = "#181818",
        selection_fg = "#181818",
        selection_bg = "d8d8d8",
        cursor_bg = "#d7d7d7",
        cursor_border = "#d7d7d7",

        -- Tab Theming
--        tab_bar = {
            -- The color of the strip that goes along the top of the window
            -- (does not apply when fancy tab bar is in use)
            --background = '#0b0022',

            -- The active tab is the onethat has focus in the window
--            active_tab = {
                -- The color of the background area for the tab
            --    bg_color = '#2b2042',
                -- The color of the text for the tab
            --    fg_color = '#c0c0c0',

                -- Specify whether you want "Half", "Normal" or "Bold" intensity for the
                -- label shown for this tab.
                -- The default is "Normal"
            --    intensity = 'Normal',

                -- Specify whether you want "None", "Single" or "Double" underline for
                -- label shown for this tab.
                -- The default is "None"
            --    underline = 'None',

                -- Specify whether you want the text to be italic (true) or not (false)
                -- for this tab.  The default is false.
            --    italic = false,

                -- Specify whether you want the text to be rendered with strikethrough (true)
                -- or not for this tab.  The default is false.
            --    strikethrough = false,
--            },

            -- Inactive tabs are the tabs that do not have focus
--            inactive_tab = {
            --    bg_color = '#1b1032',
            --    fg_color = '#808080',

                -- The same options that were listed under the `active_tab` section above
                -- can also be used for `inactive_tab`.
--            },

            -- You can configure some alternate styling when the mouse pointer
            -- moves over inactive tabs
--            inactive_tab_hover = {
            --    bg_color = '#3b3052',
            --    fg_color = '#909090',
            --    italic = true,

                -- The same options that were listed under the `active_tab` section above
                -- can also be used for `inactive_tab_hover`.
--            },

            -- The new tab button that let you create new tabs
--            new_tab = {
            --    bg_color = '#1b1032',
            --   fg_color = '#808080',

                -- The same options that were listed under the `active_tab` section above
                -- can also be used for `new_tab`.
--            },

            -- You can configure some alternate styling when the mouse pointer
            -- moves over the new tab button
--            new_tab_hover = {
            --    bg_color = '#3b3052',
            --    fg_color = '#909090',
            --    italic = true,

            -- The same options that were listed under the `active_tab` section above
            -- can also be used for `new_tab_hover`.
--            }
--        }
    },

    -- Keybinds
    keys = {
        { --Open New Tab
            key = 't',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.SpawnTab 'CurrentPaneDomain'
        },
        { --Close Current Tab
            key = 'q',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.CloseCurrentTab {confirm=true}
        },
        { --Activate Tab to the Left
            key = '<',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.ActivateTabRelativeNoWrap(-1)
        },
        { --Activate Tab to the Right
            key = '>',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.ActivateTabRelativeNoWrap(1)
        },
        { -- Move Tab Leftward
            key = '<', 
            mods = 'CTRL|SHIFT|ALT',
            action = wezterm.action.MoveTabRelative(-1)
        },
        { -- Move Tab Rightward
            key = '>',
            mods = 'CTRL|SHIFT|ALT', 
            action = wezterm.action.MoveTabRelative(1) 
        },
        { -- Split Vertically
            key = 'w',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' }
        },
        { -- Split Horizontally
            key = 'e',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' }
        },
        { -- Close Current Pane
            key = 'q',
            mods = 'CTRL|SHIFT|ALT',
            action = wezterm.action.CloseCurrentPane { confirm = true },
        },
        { --Activate Upward Pane
            key = 'UpArrow',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.ActivatePaneDirection 'Up'
        },
        { --Activate Leftward Pane
            key = 'LeftArrow',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.ActivatePaneDirection 'Left'
        },
        { --Activate Rightward Pane
            key = 'RightArrow',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.ActivatePaneDirection 'Right'
        },
        { --Activate Leftward Pane
            key = 'UpArrow',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.ActivatePaneDirection 'Up'
        },
        { --Activate Downward Pane
            key = 'DownArrow',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.ActivatePaneDirection 'Down'
        },
        { --Copy
            key = 'c',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.CopyTo 'Clipboard'
        },
        { --Paste
            key = 'v',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.PasteFrom 'Clipboard'
        },
        { --Increase Font Size
            key = '+',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.IncreaseFontSize
        },
        { --Decrease Font Size
            key = '_',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.DecreaseFontSize
        },
        { --Reset Font Size
            key = ')',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.ResetFontSize
        },
        { --Force Reload Config
            key = 'r',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.ReloadConfiguration
        },
        { --Show Debug Overlay
            key = 'd',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.ShowDebugOverlay
        },
        { --F11 for Fullscreen
            key = 'F11',
            action = wezterm.action.ToggleFullScreen
        },
        { --Search Case Insensitively
            key = 'f',
            mods = 'CTRL|SHIFT',
            action = wezterm.action.Search {CaseInSensitiveString = ""}
        },
    }
}
return config
