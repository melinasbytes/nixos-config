# Stylix leitet aus dem Wallpaper automatisch eine base16-Farbpalette ab
# und verteilt sie systemweit (Terminal, GTK, Waybar, Cursor …).
# Das base16Scheme kann die automatischen Farben überschreiben — hier mit
# einer manuell abgestimmten Sakura-Palette.
{ pkgs, ... }:

{
  stylix = {
    enable = true;
    image        = ../wallpapers/sakura.png;
    polarity     = "dark";
    base16Scheme = ../themes/sakura-dark.yaml;

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name    = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.inter;
        name    = "Inter";
      };
      serif = {
        package = pkgs.inter;
        name    = "Inter";
      };
      sizes = {
        applications = 11;
        terminal     = 13;
      };
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name    = "Bibata-Modern-Classic";
      size    = 24;
    };

  };
}
