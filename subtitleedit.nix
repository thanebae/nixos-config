{ pkgs }:

let
  installDir = "/opt/subtitleedit/latest";
in
pkgs.buildFHSEnv {
  pname = "subtitleedit";
  version = "latest";

  # Cung cấp toàn bộ runtime thư viện giao diện và đa phương tiện
  targetPkgs = pkgs: (with pkgs; [
    gtk3
    glib
    cairo
    pango
    atk
    gdk-pixbuf
    fontconfig
    freetype
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    xorg.libXext
    xorg.libXfixes
    libxkbcommon
    alsa-lib
    libpulseaudio
    libvlc
    mpv
    ffmpeg
    icu
    openssl
    zlib
    tesseract
    hunspell
  ]);

  extraInstallCommands = ''
    mkdir -p $out/share/applications $out/share/icons/hicolor/256x256/apps

    # Tạo entry ứng dụng cho desktop GNOME
    cat << 'EOF' > $out/share/applications/subtitleedit.desktop
[Desktop Entry]
Name=Subtitle Edit
Comment=Video subtitle editor
Exec=subtitleedit %F
Icon=subtitleedit
Terminal=false
Type=Application
Categories=AudioVideo;AudioVideoEditing;
MimeType=text/plain;application/x-subrip;
EOF
  '';

  # Script thực thi: kiểm tra file nhị phân trong /opt/subtitleedit/latest
  runScript = pkgs.writeShellScript "subtitleedit-runner" ''
    APP_BIN="${installDir}/SubtitleEdit"
    if [ ! -f "$APP_BIN" ]; then
      echo "Dang tai Subtitle Edit lan dau tu GitHub, vui long cho trong giay lat..."
      systemctl start update-subtitleedit.service || true
      sleep 3
    fi

    if [ -f "$APP_BIN" ]; then
      exec "$APP_BIN" "$@"
    else
      echo "Loi: Khong tim thay Subtitle Edit tai $APP_BIN"
      exit 1
    fi
  '';
}
