# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config
, pkgs
, lib
, ...
}:
let
  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };

  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz";
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Import home-manager
    (import "${home-manager}/nixos")
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "awatwe-rog"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = false;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.awatwe = {
    isNormalUser = true;
    description = "Aaditya Watwe";
    extraGroups = [
      "dialout"
      "docker"
      "networkmanager"
      "systemd-journal"
      "wheel"
    ];
    packages = with pkgs; [
      #  thunderbird
    ];
  };
  # Define home-manager settings for each user
  home-manager.users.awatwe = {
    home.packages = with pkgs; [
      bitwarden
      btop
      vscodium
      git
      neofetch
      nil # nix language server
      nixpkgs-fmt # nix formatter of choice
      picocom
      zoom-us
    ];

    programs = {
      bash.enable = true;
      firefox = {
        enable = true;

        /* ---- POLICIES ---- */
        # Check about:policies#documentation for options.
        policies = {
          default = {
            id = 0;
            name = "default";
            isDefault = true;
            settings = {
              "browser.startup.homepage" = "https://searx.aicampground.com";
              "browser.search.defaultenginename" = "Searx";
              "browser.search.order.1" = "Searx";
            };
            search = {
              force = true;
              default = "Searx";
              order = [ "Searx" "Google" ];
              engines = {
                "Nix Packages" = {
                  urls = [{
                    template = "https://search.nixos.org/packages";
                    params = [
                      { name = "type"; value = "packages"; }
                      { name = "query"; value = "{searchTerms}"; }
                    ];
                  }];
                  icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [ "@np" ];
                };
                "NixOS Wiki" = {
                  urls = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
                  iconUpdateURL = "https://nixos.wiki/favicon.png";
                  updateInterval = 24 * 60 * 60 * 1000; # every day
                  definedAliases = [ "@nw" ];
                };
                "Searx" = {
                  urls = [{ template = "https://searx.aicampground.com/?q={searchTerms}"; }];
                  iconUpdateURL = "https://nixos.wiki/favicon.png";
                  updateInterval = 24 * 60 * 60 * 1000; # every day
                  definedAliases = [ "@searx" ];
                };
                "Bing".metaData.hidden = true;
                "Google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
              };
            };
          };

          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          EnableTrackingProtection = {
            Value = true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
          };
          DisablePocket = true;
          DisableFirefoxAccounts = true;
          DisableAccounts = true;
          DisableFirefoxScreenshots = true;
          OverrideFirstRunPage = "";
          OverridePostUpdatePage = "";
          DontCheckDefaultBrowser = true;
          DisplayBookmarksToolbar = "never"; # alternatives: "always" or "newtab"
          DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
          SearchBar = "unified"; # alternative: "separate"

          /* ---- EXTENSIONS ---- */
          # Check about:support for extension/add-on ID strings.
          # Valid strings for installation_mode are "allowed", "blocked",
          # "force_installed" and "normal_installed".
          ExtensionSettings = {
            "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
            # uBlock Origin:
            "uBlock0@raymondhill.net" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              installation_mode = "force_installed";
            };
            # Bitwarden
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
              installation_mode = "force_installed";
            };
            # uMatrix
            "uMatrix@raymondhill.net" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/umatrix/latest.xpi";
              installation_mode = "force_installed";
            };
            /*
            # Privacy Badger:
            "jid1-MnnxcxisBPnSXQ@jetpack" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
              installation_mode = "force_installed";
            };
              */
            # 1Password:
            "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
              installation_mode = "force_installed";
            };
          };

          /* ---- PREFERENCES ---- */
          # Check about:config for options.
          Preferences = {
            "browser.contentblocking.category" = { Value = "strict"; Status = "locked"; };
            "extensions.formautofill.addresses.enabled" = lock-false;
            "extensions.formautofill.creditCards.enabled" = lock-false;
            "extensions.pocket.enabled" = lock-false;
            "extensions.screenshots.disabled" = lock-true;
            "browser.topsites.contile.enabled" = lock-false;
            "browser.formfill.enable" = lock-false;
            "browser.search.suggest.enabled" = lock-false;
            "browser.search.suggest.enabled.private" = lock-false;
            "browser.urlbar.suggest.searches" = lock-false;
            "browser.urlbar.showSearchSuggestionsFirst" = lock-false;
            "browser.newtabpage.activity-stream.feeds.recommendationprovider" = lock-false;
            "browser.newtabpage.activity-stream.feeds.section.topstories" = lock-false;
            "browser.newtabpage.activity-stream.feeds.snippets" = lock-false;
            "browser.newtabpage.activity-stream.section.highlights.includePocket" = lock-false;
            "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = lock-false;
            "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = lock-false;
            "browser.newtabpage.activity-stream.section.highlights.includeVisited" = lock-false;
            "browser.newtabpage.activity-stream.showSponsored" = lock-false;
            "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
            "privacy.cpd.passwords" = lock-false;
            "privacy.donottrackheader.enabled" = lock-true;
            "privacy.globalprivacycontrol.enabled" = lock-true;
          };
        };
      };
      tmux.enable = true;
    };

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "23.11";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    auto-cpufreq
    coreutils
    curl
    direnv
    (pkgs.discord.override {
      withOpenASAR = true;
      withTTS = true;
    })
    # Flakes uses git as the dependency manager
    gh
    git
    gnupg
    gzip
    openssl
    openssh
    pciutils
    rar
    # Upstream issue with slack - does not work w/ Wayland
    (slack.overrideAttrs
      (default: {
        installPhase = default.installPhase + ''
          rm $out/bin/slack

          makeWrapper $out/lib/slack/slack $out/bin/slack \
          --prefix XDG_DATA_DIRS : $GSETTINGS_SCHEMAS_PATH \
          --prefix PATH : ${lib.makeBinPath [pkgs.xdg-utils]} \
          --prefix NIXOS_OZONE_WL : 0 \
          --add-flags "--enable-features=WebRTCPipeWireCapturer"
        '';
      })
    )
    spotify
    sudo
    unrar
    unzip
    usbutils
    v4l-utils
    vim
    vscodium
    wget
    zip
    zstd
  ];
  # Use vim as the default editor
  environment.variables.EDITOR = "vim";
  # add fonts
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
    ];
    enableDefaultPackages = true;
  };


  # Power management settings
  powerManagement.enable = true;
  # throttled is not yet supported: https://github.com/erpalma/throttled/issues/353
  services.throttled.enable = false;
  services.tlp.enable = lib.mkForce false;
  services.auto-cpufreq.settings = {
    enable = true;
    settings = ''
      # settings for when connected to a power source
      [charger]
      # see available governors by running: cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
      # preferred governor.
      governor = performance

      # EPP: see available preferences by running: cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_available_preferences
      energy_performance_preference = performance

      # turbo boost setting. possible values: always, auto, never
      turbo = auto

      # settings for when using battery power
      [battery]
      # see available governors by running: cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
      # preferred governor
      governor = powersave

      # EPP: see available preferences by running: cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_available_preferences
      energy_performance_preference = power

      # turbo boost setting. possible values: always, auto, never
      turbo = auto
    '';
  };


  # enable NVIDIA and patch video settings
  hardware.nvidia = {
    modesetting.enable = true;
    open = false; # do not use the open-source drivers
    package = config.boot.kernelPackages.nvidiaPackages.production;
    nvidiaSettings = true;
    prime = {
      # use sync instead of offload at the expense of higher power consumption
      sync.enable = true;
      # Bus ID of the NVIDIA dGPU (0000:01:00.0 on lspci)
      nvidiaBusId = "PCI:1:0:0";
      # Bus ID of the Intel integrated GPU (0000:00:02.0 on lspci)
      intelBusId = "PCI:0:2:0";
    };
    powerManagement = {
      enable = true;
      finegrained = false;
    };
  };
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [ vaapiVdpau ];
  };
  # Do not use xserver with NVIDIA
  # services.xserver.videoDrivers = [ "nvidia" ];
  # services.xserver.videoDrivers = [ "nvidia" "modesetting" ];
  # services.xserver.videoDrivers = [ "nvidia" "displaylink" "modesetting" ];

  # enable containers with GPU
  virtualisation = {
    docker = {
      enable = true;
      enableNvidia = true;
      extraOptions = "--experimental";
    };
    podman = {
      enable = true;
      enableNvidia = true;
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  # Enable wifi networks
  networking.wireless.environmentFile = "/run/secrets/wireless.env";
  # content of /run/secrets/wireless.env:
  /*
    NET_HOME_ID=HomeNetwork
    NET_HOME_PSK=HomePassword
    NET_WORK_ID=WorkNetwork
    NET_WORK_PSK=WorkPassword
  */
  # wireless-related configuration
  networking.wireless.networks = {
    # Home wifi
    "@NET_HOME_ID@" = {
      psk = "@NET_HOME_PSK@";
    };
    # Work wifi
    "@NET_WORK_ID@" = {
      psk = "@NET_WORK_PSK@";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}

