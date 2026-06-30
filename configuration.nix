# Haupt-Systemkonfiguration für melbook (MacBook mit NixOS).
# Hardware-spezifische Einstellungen (Partitionen, Kernel-Module) sind in
# hardware-configuration.nix — die wird von nixos-generate-config erzeugt
# und sollte nicht manuell bearbeitet werden.
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/stylix.nix
    ./modules/hyprland.nix
  ];

  # ── Boot ────────────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── MacBook WLAN (Broadcom BCM) ─────────────────────────────────────────────
  # Dieses MacBook nutzt einen Broadcom-WLAN-Chip, der keinen Open-Source-Treiber hat.
  # broadcom_sta ist der proprietäre Treiber ("wl"). Ohne diese vier Blöcke kein WLAN.
  # Auf einem anderen Gerät ohne Broadcom-Chip können diese Blöcke entfernt werden.
  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-6.18.37"
  ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  boot.kernelModules = [ "wl" ];
  boot.blacklistedKernelModules = [ "b43" "bcma" "brcmsmac" "brcmfmac" ];
  hardware.enableRedistributableFirmware = true;

  # ── Netzwerk ────────────────────────────────────────────────────────────────
  networking.hostName = "melbook";
  networking.networkmanager.enable = true;

  # ── Bluetooth ───────────────────────────────────────────────────────────────
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # ── Lokalisierung ───────────────────────────────────────────────────────────
  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT    = "de_DE.UTF-8";
    LC_MONETARY       = "de_DE.UTF-8";
    LC_NAME           = "de_DE.UTF-8";
    LC_NUMERIC        = "de_DE.UTF-8";
    LC_PAPER          = "de_DE.UTF-8";
    LC_TELEPHONE      = "de_DE.UTF-8";
    LC_TIME           = "de_DE.UTF-8";
  };

  # ── Desktop (GNOME — temporär) ──────────────────────────────────────────────
  # GNOME/GDM bleibt aktiv, bis Hyprland vollständig eingerichtet ist.
  # Danach: gdm + gnome entfernen, nur noch Hyprland als Session.
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };
  console.keyMap = "de";

  # ── Audio (PipeWire) ────────────────────────────────────────────────────────
  # pulseaudio muss explizit false sein — PipeWire und PulseAudio schließen sich aus.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ── Drucker ─────────────────────────────────────────────────────────────────
  services.printing.enable = true;

  # ── SSH ─────────────────────────────────────────────────────────────────────
  services.openssh.enable = true;

  # ── Benutzer ────────────────────────────────────────────────────────────────
  users.users.mel = {
    isNormalUser = true;
    description  = "Melina";
    extraGroups  = [ "networkmanager" "wheel" ];
  };

  # ── Pakete ──────────────────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    claude-code
    git
    gh
  ];

  # ── Nix ─────────────────────────────────────────────────────────────────────
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # ── System ──────────────────────────────────────────────────────────────────
  # stateVersion gibt an, mit welcher NixOS-Version das System initialisiert wurde.
  # Nicht erhöhen — das ist kein "aktuell halten", sondern ein Migrationswächter.
  system.stateVersion = "26.05";
}
