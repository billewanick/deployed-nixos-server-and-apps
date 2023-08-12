# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Applications that run on this server
      ../nixos-apps/cutesealfanpage.love.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  networking.usePredictableInterfaceNames = false;
  networking.hostName = "linode-nixos";

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Nix daemon config
  nix = {
    # Automate garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    package = pkgs.nixVersions.stable;
    extraOptions = ''
      # https://github.com/nix-community/nix-direnv#home-manager
      keep-outputs = true
      keep-derivations = true

      # Enable the nix 2.0 CLI and flakes support feature-flags
      experimental-features = nix-command flakes
    '';

    settings = {
      # Automate `nix store --optimise`
      auto-optimise-store = true;

      # Required by Cachix to be used as non-root user
      trusted-users = [ "root" "alice" ];
    };
  };

  # Configure keymap in X11
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "ctrl:swapcaps";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alice = {
    isNormalUser = true;
    home = "/home/alice";
    description = "Alice Foobar";
    extraGroups = [ "wheel" "networkmanager" ];
    packages = with pkgs; [
      tldr
    ];
    password = "alice";
  };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    git
    kitty

    # Linode tools
    inetutils
    mtr
    sysstat
  ];

  # Enable Nix-ld for remote VSCode SSH to work
  programs.nix-ld.enable = true;
  environment.variables = {
    NIX_LD_LIBRARY_PATH = lib.mkDefault (lib.makeLibraryPath [
      pkgs.stdenv.cc.cc
    ]);
    NIX_LD = lib.mkDefault (lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker");
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;

  # Linode Longview monitoring
  services.longview = {
    enable = true;
    apiKeyFile = "/var/lib/longview/apiKeyFile";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
