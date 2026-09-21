local outs = {
  hdmi = {
    internal = "eDP-1",
    external = "HDMI-A-1",
  },
}

local monitors = {
  function ()
    hl.monitor {
      output = outs.hdmi.external,
      disabled = false,
      mode = "1920x1080@180",
      position = "auto",
      scale = 1,
    }
    hl.monitor {
      output = outs.hdmi.internal,
      disabled = true,
    }
  end,
  function ()
    hl.monitor {
      output = outs.hdmi.external,
      disabled = true,
    }
    hl.monitor {
      output = outs.hdmi.internal,
      disabled = false,
      mode = "1920x1080@165",
      position = "auto",
      scale = 1,
    }
  end,
  function ()
    hl.monitor {
      output = outs.hdmi.external,
      disabled = false,
      mode = "preferred",
      position = "auto",
      scale = 1,
      mirror = outs.hdmi.internal,
    }
    hl.monitor {
      output = outs.hdmi.internal,
      disabled = false,
      mode = "1920x1080@165",
      position = "auto",
      scale = 1,
    }
  end,
  function ()
    hl.monitor {
      output = outs.hdmi.external,
      disabled = false,
      mode = "preferred",
      position = "auto",
      scale = 1,
    }
    hl.monitor {
      output = outs.hdmi.internal,
      disabled = false,
      -- mode = "1920x1080@165",
      position = "auto",
      scale = 1,
      mirror = outs.hdmi.external,
    }
  end,
}

monitors[1]()

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

hl.config {
  general = {
    border_size = 0,
    gaps_in = 6,
    gaps_out = 12,
    allow_tearing = false,
  },
  decoration = {
    rounding = 6, -- default 0
    inactive_opacity = 0.92,
    -- dim_inactive = true,
    -- dim_strength = 0.36,
    -- dim_special = 0.36,
    blur = {
      enabled = true,
      size = 3,
      passes = 1,
      noise = 0.012,
      contrast = 0.8916,
      brightness = 0.72,
      vibrancy = 0.12,
      vibrancy_darkness = 0.0,
      special = false,
    },
    shadow = { enabled = false },
  },
  animations = { enabled = false },
  input = {
    kb_layout = "tr,us",
    kb_variant = "",
    kb_model = "",
    kb_options = "caps:swapescape,grp:win_space_toggle",
    kb_rules = "",
    -- resolve_binds_by_sym
    repeat_rate = 60,
    repeat_delay = 240,
    sensitivity = 0.0,
    accel_profile = "adaptive",
    natural_scroll = true,
    scroll_factor = 2.0,
    follow_mouse = 1,

    touchpad = {
      natural_scroll = true,
    },
  },
  misc = {
    disable_hyprland_logo = true,
    -- disable_splash_rendering = true,
    force_default_wallpaper = -1,
    -- font_family = "oziosevka",
    -- splash_font_family = "oziosevka",
    -- vrr = 1,
    -- vfr = true,
    close_special_on_empty = true,
    render_unfocused_fps = 15,
  },
  binds = {
    scroll_event_delay = 0,
    workspace_back_and_forth = true,
    hide_special_on_workspace_change = true,
    workspace_center_on = 1,
  },
  cursor = {},
  ecosystem = {
    no_update_news = false,
    no_donation_nag = true,
    enforce_permissions = false,
  },

  master = {
    new_status = "master",
    orientation = "right",
  },
}

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
hl.curve("easy", { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

hl.animation { leaf = "global", enabled = true, speed = 1.0, bezier = "default" }
hl.animation { leaf = "border", enabled = true, speed = 1.0, bezier = "easeOutQuint" }
hl.animation { leaf = "windows", enabled = true, speed = 1.0, spring = "easy" }
hl.animation { leaf = "windowsIn", enabled = true, speed = 1.0, spring = "easy", style = "popin 87%" }
hl.animation { leaf = "windowsOut", enabled = true, speed = 1.0, bezier = "linear", style = "popin 87%" }
hl.animation { leaf = "fadeIn", enabled = true, speed = 1.0, bezier = "almostLinear" }
hl.animation { leaf = "fadeOut", enabled = true, speed = 1.0, bezier = "almostLinear" }
hl.animation { leaf = "fade", enabled = true, speed = 1.0, bezier = "quick" }
hl.animation { leaf = "layers", enabled = true, speed = 1.0, bezier = "easeOutQuint" }
hl.animation { leaf = "layersIn", enabled = true, speed = 1.0, bezier = "easeOutQuint", style = "fade" }
hl.animation { leaf = "layersOut", enabled = true, speed = 1.0, bezier = "linear", style = "fade" }
hl.animation { leaf = "fadeLayersIn", enabled = true, speed = 1.0, bezier = "almostLinear" }
hl.animation { leaf = "fadeLayersOut", enabled = true, speed = 1.0, bezier = "almostLinear" }
hl.animation { leaf = "workspaces", enabled = false }
hl.animation { leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" }

hl.workspace_rule { workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 }
hl.workspace_rule { workspace = "f[1]", gaps_out = 0, gaps_in = 0 }
hl.window_rule {
  name = "no-gaps-wtv1",
  match = { float = false, workspace = "w[tv1]" },
  border_size = 0,
  rounding = 0,
}
hl.window_rule {
  name = "no-gaps-f1",
  match = { float = false, workspace = "f[1]" },
  border_size = 0,
  rounding = 0,
}

hl.gesture {
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
}

hl.window_rule {
  name = "float-quickshell-polkit",
  match = { title = "^quickshell-polkit$" },
  float = true,
  center = true,
}

local mainMod = "SUPER"

hl.bind(
  mainMod .. " + Y",
  hl.dsp.exec_cmd "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"
)

hl.bind(mainMod .. " + BackSpace", hl.dsp.exec_cmd "qs ipc call launcher toggle applications")
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd "qs ipc call launcher toggle clipboard")
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd "qs ipc call launcher toggle power")
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd "qs ipc call notifications toggle")
hl.bind(mainMod .. " + SHIFT + Escape", hl.dsp.exec_cmd "qs ipc call lock lock")

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd "alacritty")
-- hl.bind(mainMod .. " + BackSpace", hl.dsp.exec_cmd "fuzzel")
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd "nautilus")
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd "grim")
hl.bind(mainMod .. " + U", hl.dsp.exec_cmd "hyprpicker --autocopy --notify")
-- hl.bind(mainMod .. " + C", hl.dsp.exec_cmd "cliphist list | fuzzel --dmenu --width 60 | cliphist decode | wl-copy")
-- hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd "selected=$(printf '%s\n' '⎋ Lock' '🆥 Monitors' '⏼ Reboot' '⏻ Shutdown' '⏾ Suspend' '⏎ Exit' | fuzzel --dmenu); case \"$selected\" in '⎋ Lock') hyprlock ;; '🆥 Monitors') niri msg action power-off-monitors ;; '⏼ Reboot') systemctl reboot ;; '⏻ Shutdown') systemctl poweroff ;; '⏾ Suspend') systemctl suspend-then-hibernate ;; '⏎ Exit') niri msg action quit ;; esac")

hl.bind(mainMod .. " + H", hl.dsp.focus { direction = "left" })
hl.bind(mainMod .. " + L", hl.dsp.focus { direction = "right" })
hl.bind(mainMod .. " + K", hl.dsp.focus { direction = "up" })
hl.bind(mainMod .. " + J", hl.dsp.focus { direction = "down" })

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(mainMod .. " + W", hl.dsp.window.float { action = "toggle" })
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen { mode = "fullscreen", action = "toggle" })
hl.bind(mainMod .. " + Q", hl.dsp.window.close())

hl.bind(mainMod .. " + Tab", hl.dsp.focus { workspace = "previous" })
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.window.move { workspace = "previous" })
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special "magic")
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move { workspace = "special:magic" })
for i = 1, 6 do
  hl.bind(mainMod .. " + " .. i, hl.dsp.focus { workspace = i })
  hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move { workspace = i })
end

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus { workspace = "e+1" })
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus { workspace = "e-1" })

hl.bind(mainMod .. " + D", hl.dsp.submap "display")
hl.define_submap("display", function ()
  hl.bind("escape", hl.dsp.submap "reset")
  for i, v in ipairs(monitors) do
    hl.bind(tostring(i), v)
  end
end)

hl.bind(mainMod .. " + minus", hl.dsp.exec_cmd "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle", { locked = true })
hl.bind(mainMod .. " + period", hl.dsp.exec_cmd "playerctl play-pause", { locked = true })
hl.bind(mainMod .. " + Right", hl.dsp.exec_cmd "playerctl next", { locked = true })
hl.bind(mainMod .. " + Left", hl.dsp.exec_cmd "playerctl previous", { locked = true })
hl.bind(mainMod .. " + Up", hl.dsp.exec_cmd "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 6%+", { locked = true })
hl.bind(mainMod .. " + Down", hl.dsp.exec_cmd "wpctl set-volume @DEFAULT_AUDIO_SINK@ 6%-", { locked = true })

hl.bind(
  "XF86AudioRaiseVolume",
  hl.dsp.exec_cmd "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+",
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioLowerVolume",
  hl.dsp.exec_cmd "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-",
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioMute",
  hl.dsp.exec_cmd "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioMicMute",
  hl.dsp.exec_cmd "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle",
  { locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd "brightnessctl -e4 -n2 set 5%+", { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd "brightnessctl -e4 -n2 set 5%-", { locked = true, repeating = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd "playerctl next", { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd "playerctl play-pause", { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd "playerctl play-pause", { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd "playerctl previous", { locked = true })

hl.window_rule {
  name = "fix-xwayland-drags",
  match = {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
  no_focus = true,
}

hl.window_rule {
  name = "move-hyprland-run",
  match = { class = "hyprland-run" },

  move = "20 monitor_h-120",
  float = true,
}
