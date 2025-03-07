{ pkgs, config, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [
    pkgs.vim
    pkgs.neovim
    pkgs.mkalias
    pkgs.nixfmt-rfc-style
    pkgs.zsh
  ];

  homebrew = {
    enable = true;
    taps = [
      # "FelixKratz/formulae" # borders
    ];
    brews = [
      "mas"
      "mactop"
      "jandedobbeleer/oh-my-posh/oh-my-posh"
    ];
    casks = [
      "microsoft-edge"
      "visual-studio-code"
      "ghostty"
      "font-monaspace"
      "retroarch"
    ];
    masApps = {
      "Microsoft Word" = 462054704;
      "Microsoft Excel" = 462058435;
      "Microsoft PowerPoint" = 462062816;
      "Microsoft Outlook" = 985367838;
      "Microsoft Onedrive" = 823766827;
      "Pasty" = 1544620654;
      "Bitwarden" = 1352778147;
    };
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };

  system.activationScripts.applications.text =
    let
      env = pkgs.buildEnv {
        name = "system-applications";
        paths = config.environment.systemPackages;
        pathsToLink = "/Applications";
      };
    in
    pkgs.lib.mkForce ''
      # Set up applications.
      echo "setting up /Applications..." >&2
      rm -rf /Applications/Nix\ Apps
      mkdir -p /Applications/Nix\ Apps
      find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
      while read -r src; do
        app_name=$(basename "$src")
        echo "copying $src" >&2
        ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
      done
    '';

  system.defaults = {
    NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
      AppleShowAllExtensions = true;
      # "com.apple.keyboard.fnState" = true;
    };
  };

  # Add Rosetta installation script
  system.activationScripts.extraActivation.text = ''
    if ! /usr/bin/pgrep oahd >/dev/null 2>&1; then
      softwareupdate --install-rosetta --agree-to-license
    fi
  '';

  # Enable Touch ID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Set Git commit hash for darwin-version.
  system.configurationRevision = config.rev or config.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
