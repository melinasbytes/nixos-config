# System-seitige Hyprland-Einstellungen: Treiber, Kernel-Support, System-Pakete.
# Die eigentliche Fenstermanager-Konfiguration (Bindings, Layout, Aussehen)
# liegt in home/hyprland.nix, weil sie pro-User über Home Manager verwaltet wird.
{ pkgs, ... }:

{
  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs; [
    anyrun               # Raycast-style Launcher (SUPER+Space)
    brightnessctl        # Bildschirmhelligkeit per Tastatur
    networkmanagerapplet # nm-applet für Systray
    pamixer              # Lautstärke per Tastatur
    playerctl            # Mediensteuerung (Play/Pause etc.)
    wl-clipboard         # Clipboard im Terminal (wl-copy / wl-paste)
    wlogout              # Logout/Shutdown-Menü
  ];
}
