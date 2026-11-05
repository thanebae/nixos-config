# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Ho_Chi_Minh";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "vi_VN";
    LC_IDENTIFICATION = "vi_VN";
    LC_MEASUREMENT = "vi_VN";
    LC_MONETARY = "vi_VN";
    LC_NAME = "vi_VN";
    LC_NUMERIC = "vi_VN";
    LC_PAPER = "vi_VN";
    LC_TELEPHONE = "vi_VN";
    LC_TIME = "vi_VN";
  };

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."thane" = {
    isNormalUser = true;
    description = "THANE";
    extraGroups = ["networkmanager" "wheel" "video" "camera"];
    packages = with pkgs; [
      #  thunderbird
    ];
  };
  # =========================================================================
  # 1. TỰ ĐỘNG TẠO KEYRING RỖNG (Cho các ứng dụng hệ thống khác không bị hỏi pass)
  # =========================================================================
  systemd.tmpfiles.rules = [
    "d /home/thane/.local/share/keyrings 0700 thane users -"
    "f /home/thane/.local/share/keyrings/default 0600 thane users - login"
    "f /home/thane/.local/share/keyrings/login.keyring 0600 thane users - [keyring]\ndisplay-name=login\nctime=0\nmtime=0\nlock-on-idle=false\nlock-after=false\n"
  ];

  # =========================================================================
  # 2. XDG DESKTOP PORTAL (Chuẩn Wayland cho GNOME)
  # =========================================================================
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gnome];
    config.common.default = ["gnome" "*"];
  };

  # Install firefox.
  programs.firefox.enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    (google-chrome.override {
      commandLineArgs = [
        "--password-store=basic"
        "--ozone-platform-hint=auto"
        "--enable-features=WaylandWindowDecorations"
      ];
    })
    git
    pciutils
    fastfetch
    vlc
    htop
    btop
    mkvtoolnix
    remmina
    localsend
    telegram-desktop
    qbittorrent
    zip
    unzip
    p7zip
    unrar
    plex-desktop
  ];
  # 1. Bật uinput module cho kernel
  boot.kernelModules = ["uinput"];

  # 2. Cấu hình Fcitx5 với engine Lotus
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-lotus
      fcitx5-gtk
    ];
  };

  # 3. Kích hoạt fcitx5-lotus-server systemd daemon cho user thane
  systemd.packages = [pkgs.fcitx5-lotus];
  systemd.services."fcitx5-lotus-server@thane" = {
    wantedBy = ["multi-user.target"];
    overrideStrategy = "asDropin";
    serviceConfig = {
      TimeoutStopSec = "3s";
    };
  };

  # 4. Biến môi trường bộ gõ
  environment.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
    # Bật bộ gõ Wayland cho Chrome/Electron
    NIXOS_OZONE_WL = "1";
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

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?
  nix.settings.experimental-features = ["nix-command" "flakes"];
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "5s";
  };
  services.gnome.gnome-keyring.enable = true;
  # 1. Kích hoạt OpenGL / Graphics
  hardware.graphics.enable = true;

  # 2. Khai báo driver nvidia cho hệ thống đồ họa
  services.xserver.videoDrivers = ["nvidia"];

  # 3. Thiết lập chi tiết driver NVIDIA
  hardware.nvidia = {
    # Bắt buộc bật cho Wayland / GNOME để tránh xé hình
    modesetting.enable = true;

    # Tắt open driver vì Quadro T2000 (Turing) dùng driver đóng ổn định hơn
    open = false;

    # Bật bảng điều khiển đồ họa nvidia-settings
    nvidiaSettings = true;

    # Sử dụng bản driver ổn định (Production/Stable)
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Cấu hình PRIME Offload (tiết kiệm pin, chỉ bật card rời khi cần)
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # ==========================================
  # 1. PHÂN QUYỀN TRUY CẬP PHẦN CỨNG CAMERA (UDEV)
  # Gán quyền đọc/ghi camera cho mọi tiến trình đăng nhập (kể cả user gdm)
  # ==========================================
  services.udev.extraRules = ''
    KERNEL=="video[0-9]*", SUBSYSTEM=="video4linux", MODE="0666"
  '';

  # Gán thêm nhóm video và camera cho user gdm
  users.users.gdm = {
    extraGroups = ["video" "camera"];
  };

  # ==========================================
  # 2. CẤU HÌNH NHẬN DIỆN KHUÔN MẶT (HOWDY)
  # ==========================================
  services.howdy = {
    enable = true;
    package = pkgs.howdy;
    settings = {
      core = {
        no_confirmation = true;
        abort_if_ssh = true;
        detection_notice = false;
      };
      video = {
        device_path = "/dev/video2";
        dark_threshold = 50;
        certainty = 4.5;
        timeout = 4;
      };
    };
  };

  # ==========================================
  # 3. CẤU HÌNH CẢM BIẾN VÂN TAY (FPRINTD TOD)
  # ==========================================
  services.fprintd = {
    enable = true;
    package = pkgs.fprintd-tod;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix;
    };
  };

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id.indexOf("net.reactivated.fprint.") === 0 && subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  # ==========================================
  # 4. CHUỖI PAM TÍCH HỢP SONG SONG
  # ==========================================

  # Chuỗi xác thực cho SUDO
  security.pam.services.sudo.text = pkgs.lib.mkForce ''
    account required pam_unix.so
    auth sufficient ${pkgs.howdy}/lib/security/pam_howdy.so
    auth [success=done default=ignore] ${pkgs.fprintd}/lib/security/pam_fprintd.so
    auth sufficient pam_unix.so try_first_pass likeauth nullok
    auth required pam_deny.so
    password sufficient pam_unix.so nullok yescrypt
    session required pam_env.so conffile=/etc/pam/environment readenv=0
    session required pam_unix.so
  '';

  # Chuỗi xác thực cho LOGIN (Console TTY)
  security.pam.services.login.text = pkgs.lib.mkForce ''
     account required pam_unix.so
     account required pam_nologin.so
     auth sufficient ${pkgs.howdy}/lib/security/pam_howdy.so
     auth [success=done default=ignore] ${pkgs.fprintd}/lib/security/pam_fprintd.so
     auth sufficient pam_unix.so nullok
     auth required pam_deny.so
     password sufficient pam_unix.so nullok yescrypt
     session required pam_env.so conffile=/etc/pam/environment readenv=0
     session required pam_unix.so
     session optional ${pkgs.systemd}/lib/security/pam_systemd.so
     auth optional ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so
    session optional ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so auto_start
  '';

  # Chuỗi xác thực cho GDM (Kế thừa login + nạp đầy đủ systemd session)
  security.pam.services.gdm-password.text = pkgs.lib.mkForce ''
    account include login
    auth substack login
    password substack login
    session include login
  '';
}
