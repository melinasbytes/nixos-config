# Waybar — schlanke Statusleiste oben, macOS-Stil.
# Farben kommen aus der Stylix-Palette (via config.lib.stylix.colors),
# damit alles automatisch zum Wallpaper passt.
{ config, pkgs, ... }:

let
  c = config.lib.stylix.colors;
in
{
  programs.waybar = {
    enable = true;

    systemd = {
      enable = true;
      # Waybar nur starten, wenn Hyprland läuft — nicht bei GNOME oder anderen Sessions.
      target = "hyprland-session.target";
    };

    settings = [{
      layer    = "top";
      position = "top";
      height   = 26;
      spacing  = 2;

      modules-left   = [];
      modules-center = [ "clock" ];
      modules-right  = [ "network" "bluetooth" "pulseaudio" "battery" "tray" "custom/power" ];

      "clock" = {
        format         = "{:%H:%M  %a %d.%m.%Y}";
        tooltip-format = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
      };

      # Kein Netzwerkname — nur Signal-Icon; SSID und IP stehen im Tooltip.
      # format-icons: Index 0 = kein Signal … 4 = volles Signal (nach Signalstärke-%).
      "network" = {
        format-wifi         = "{icon}";
        format-ethernet     = "󰈀";
        format-disconnected = "󰤭";
        format-icons        = [ "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
        tooltip-format-wifi = "{essid}  {signalStrength}%\n{ipaddr}";
        on-click            = "nm-connection-editor";
      };

      "bluetooth" = {
        format           = "󰂯";
        format-disabled  = "󰂲";
        format-connected = "󰂱";
        tooltip-format   = "{controller_alias}\n{num_connections} verbunden";
        on-click         = "blueman-manager";
      };

      # {icon} wechselt mit Lautstärke (leise → laut) — erkennbar als Ton-Modul.
      "pulseaudio" = {
        format       = "{icon} {volume}%";
        format-muted = "󰝟";
        format-icons = { default = [ "󰕿" "󰖀" "󰕾" ]; };
        on-click     = "pamixer -t";
        scroll-step  = 5;
      };

      "battery" = {
        format          = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        # 10 Nerd-Font-Batterie-Icons für feingranulare Ladeanzeige.
        format-icons    = [ "󰂃" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰁹" ];
        states = {
          warning  = 30;
          critical = 15;
        };
      };

      "tray" = {
        spacing = 6;
      };

      "custom/power" = {
        format   = "⏻";
        on-click = "wlogout";
        tooltip  = false;
      };
    }];

    style = ''
      * {
        border:        none;
        border-radius: 0;
        font-size:     12px;
        min-height:    0;
      }

      window#waybar {
        /* rgba braucht dezimale RGB-Werte — Stylix liefert base00-rgb-r/g/b dafür,
           weil das normale base00 nur Hex ist und CSS rgba kein #hex akzeptiert. */
        background-color: rgba(${c.base00-rgb-r}, ${c.base00-rgb-g}, ${c.base00-rgb-b}, 0.92);
        color:            #${c.base05};
        border-bottom:    1px solid #${c.base02};
      }

      /* Alle Module einheitlich in der Hauptfarbe — kein buntes Durcheinander. */
      #clock,
      #network,
      #bluetooth,
      #pulseaudio,
      #battery,
      #tray,
      #custom-power {
        padding: 0 8px;
        color:   #${c.base05};
      }

      /* Deaktiviert/stummgeschaltet: gedimmt statt unsichtbar. */
      #pulseaudio.muted   { color: #${c.base03}; }
      #bluetooth.disabled { color: #${c.base03}; }

      #battery.warning    { color: #${c.base0A}; }
      #battery.critical   { color: #${c.base08}; font-weight: bold; }

      #custom-power {
        font-size: 14px;
        padding:   0 10px;
      }

      #custom-power:hover {
        color:            #${c.base00};
        background-color: #${c.base08};
      }
    '';
  };
}
