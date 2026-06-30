# Hyprland-Konfiguration (User-Ebene via Home Manager).
# Enthält: Kitty-Terminal, das Shortcut-Cheatsheet-Skript, und die komplette
# Hyprland-Konfiguration als Lua-ähnliches extraConfig (Hyprlands eigene Syntax).
{ config, pkgs, lib, ... }:

let
  # Stylix stellt die Farbpalette als Hex-Werte bereit (z.B. c.base00 = "01121a").
  c = config.lib.stylix.colors;

  cheatsheet = pkgs.writeShellScriptBin "hypr-keys" ''
    clear
    printf '\033[1;96m  Hyprland Shortcuts\033[0m\n\n'

    decode_mod() {
      local m=$1 parts=()
      (( m & 64 )) && parts+=("SUPER")
      (( m & 1  )) && parts+=("SHIFT")
      (( m & 4  )) && parts+=("CTRL")
      (( m & 8  )) && parts+=("ALT")
      ( IFS='+'; printf '%s' "''${parts[*]}" )
    }

    hyprctl binds -j \
      | ${pkgs.jq}/bin/jq -r '.[] | select(.has_description) | [(.modmask|tostring), .key, .description] | @tsv' \
      | while IFS=$'\t' read -r modmask key desc; do
          mod=$(decode_mod "$modmask")
          if [[ -n "$mod" ]]; then
            combo="$mod + $key"
          else
            combo="$key"
          fi
          printf '  \033[1m%-32s\033[0m%s\n' "$combo" "$desc"
        done

    printf '\n\033[2m  [Beliebige Taste zum Schließen]\033[0m\n\n'
    read -rsn1
  '';
in
{
  home.packages = [ cheatsheet pkgs.jq ];

  programs.kitty = {
    enable = true;
    settings = {
      # lib.mkForce nötig, weil Stylix background_opacity ebenfalls setzt (auf 1.0).
      # Ohne mkForce gibt es einen Definitionskonflikt beim Build.
      background_opacity = lib.mkForce "0.85";
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;

    # extraConfig verwendet Hyprlands eigene Konfigurationssprache (hyprlang / Lua-Syntax).
    # Alternativ gibt es settings = { ... } als Nix-Attrset, aber extraConfig ist
    # flexibler für Schleifen (Workspaces) und komplexere Ausdrücke.
    extraConfig = ''
      -- ── Monitor ──────────────────────────────────────────────────────────────
      hl.monitor({
        output   = "",
        mode     = "preferred",
        position = "auto",
        scale    = "auto",
      })

      -- ── Autostart ────────────────────────────────────────────────────────────
      hl.on("hyprland.start", function()
        hl.exec_cmd("hyprpaper")
        hl.exec_cmd("nm-applet --indicator")
        hl.exec_cmd("blueman-applet")
      end)

      -- ── Konfiguration ────────────────────────────────────────────────────────
      hl.config({
        input = {
          kb_layout    = "de",
          follow_mouse = 1,
          touchpad = {
            natural_scroll = true,
            tap_to_click   = true,
          },
        },
        general = {
          gaps_in     = 5,
          gaps_out    = 10,
          border_size = 2,
          col = {
            active_border   = "rgba(${c.base04}ff)",
            inactive_border = "rgba(${c.base02}ff)",
          },
          layout = "dwindle",
        },
        decoration = {
          rounding = 10,
          shadow = {
            enabled      = true,
            range        = 12,
            render_power = 3,
            color        = "rgba(${c.base00}cc)",
          },
        },
        animations = {
          enabled = true,
        },
        dwindle = {
          preserve_split = true,
        },
        misc = {
          disable_hyprland_logo    = true,
          disable_splash_rendering = true,
        },
      })

      -- ── Animationen ──────────────────────────────────────────────────────────
      hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
      hl.animation({ leaf = "windows",    enabled = true, speed = 5, bezier = "myBezier" })
      hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "default", style = "popin 80%" })
      hl.animation({ leaf = "border",     enabled = true, speed = 8, bezier = "default" })
      hl.animation({ leaf = "fade",       enabled = true, speed = 5, bezier = "default" })
      hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "default" })

      -- ── Fensterregeln ────────────────────────────────────────────────────────
      hl.window_rule({
        name  = "float-cheatsheet",
        match = { class = "^cheatsheet$" },
        float  = true,
        center = true,
      })

      -- ── Tastenkürzel ─────────────────────────────────────────────────────────
      hl.bind("SUPER + Return", hl.dsp.exec_cmd("kitty"),                        { description = "Terminal öffnen" })
      hl.bind("SUPER + Space",  hl.dsp.exec_cmd("anyrun"),                       { description = "Launcher öffnen" })

      hl.bind("SUPER + Q", hl.dsp.window.close(),                                { description = "Fenster schließen" })
      hl.bind("SUPER + M", hl.dsp.window.fullscreen(),                           { description = "Vollbild an/aus" })

      -- Workspaces 1–5
      for i = 1, 5 do
        hl.bind("SUPER + " .. i,         hl.dsp.focus({ workspace = i }),        { description = "Workspace " .. i })
        hl.bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }), { description = "Fenster → Workspace " .. i })
      end

      hl.bind("SUPER + F1", hl.dsp.exec_cmd("kitty --class cheatsheet -e hypr-keys"), { description = "Shortcuts anzeigen" })

      -- ── Lautstärke & Helligkeit ───────────────────────────────────────────────
      hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("pamixer -i 5"),         { locked = true, repeating = true, description = "Lautstärke +" })
      hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("pamixer -d 5"),         { locked = true, repeating = true, description = "Lautstärke -" })
      hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("pamixer -t"),           { locked = true, description = "Ton an/aus" })
      hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s +10%"), { locked = true, repeating = true, description = "Helligkeit +" })
      hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true, description = "Helligkeit -" })

      hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"),         { locked = true, description = "Play/Pause" })
      hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"),               { locked = true, description = "Nächster Track" })
      hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"),           { locked = true, description = "Vorheriger Track" })

    '';
  };
}
