local wezterm = require("wezterm")

local function resolve_bundled_config()
  local resource_dir = wezterm.executable_dir:gsub("MacOS/?$", "Resources")
  local bundled = resource_dir .. "/kaku.lua"
  local f = io.open(bundled, "r")
  if f then
    f:close()
    return bundled
  end

  local dev_bundled = wezterm.executable_dir .. "/../../assets/macos/Kaku.app/Contents/Resources/kaku.lua"
  f = io.open(dev_bundled, "r")
  if f then
    f:close()
    return dev_bundled
  end

  local app_bundled = "/Applications/Kaku.app/Contents/Resources/kaku.lua"
  f = io.open(app_bundled, "r")
  if f then
    f:close()
    return app_bundled
  end

  local home = os.getenv("HOME") or ""
  local home_bundled = home .. "/Applications/Kaku.app/Contents/Resources/kaku.lua"
  f = io.open(home_bundled, "r")
  if f then
    f:close()
    return home_bundled
  end

  return nil
end

local config = {}
local bundled = resolve_bundled_config()

if bundled then
  local ok, loaded = pcall(dofile, bundled)
  if ok and type(loaded) == "table" then
    config = loaded
  else
    wezterm.log_error("Kaku: failed to load bundled defaults from " .. bundled)
  end
else
  wezterm.log_error("Kaku: bundled defaults not found")
end

config.font = wezterm.font_with_fallback({
  "FiraCode Nerd Font",
  "D2Coding",
})
config.font_size = 15
config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}
config.color_scheme = "Catppuccin Mocha"
config.cursor_blink_rate = 0
config.window_close_confirmation = "NeverPrompt"

return config
