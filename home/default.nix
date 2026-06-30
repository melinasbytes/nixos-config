# Home Manager Einstiegspunkt für den User "mel".
# Zieht hyprland.nix und waybar.nix rein, die den Desktop konfigurieren.
{ config, pkgs, ... }:

{
  imports = [ ./hyprland.nix ./waybar.nix ];

  home.username      = "mel";
  home.homeDirectory = "/home/mel";
  home.stateVersion  = "26.05";

  programs.home-manager.enable = true;

  # Stylix würde KDE, GTK und GNOME automatisch theamen, aber:
  # KDE schlägt fehl ohne installierte Plasma-Pakete; GTK braucht ein vorher
  # gesetztes gtk.theme.package. Beide Targets werden deaktiviert, bis der
  # Desktop vollständig auf Hyprland umgestellt ist.
  stylix.targets.kde.enable   = false;
  stylix.targets.gtk.enable   = false;
  stylix.targets.gnome.enable = false;
}
