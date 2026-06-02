{
  lib,
  pkgs,
  ...
}: {
  programs.swaylock.enable = true;
  # https://nixos.wiki/wiki/Sway#Cursor_is_too_tiny_on_HiDPI_displays
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    gtk.enable = true;
    x11 = {
      enable = true;
      defaultCursor = "Adwaita";
    };
    sway.enable = true;
    size = 32;
  };

  wayland.windowManager.sway = {
    systemd.variables = ["--all"];
    enable = true;
    wrapperFeatures.gtk = true;
    config = rec {
      modifier = "Mod4";
      terminal = "ghostty";
      bars = [
        {command = "waybar";}
      ];
      startup = [
        {command = "fcitx5";}
        {command = "swaymsg workspace 1";}
      ];
      keybindings = lib.mkOptionDefault {
        "XF86AudioMute" = "exec 'wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle'";
        "XF86AudioLowerVolume" = "exec 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-'";
        "XF86AudioRaiseVolume" = "exec 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+'";
        "XF86AudioMicMute" = "exec 'wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle'";
        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
        "XF86MonBrightnessUp" = "exec brightnessctl set 5%+";
        "Print" = "exec grim ''\$HOME/pictures/''\$(date +'%Y-%m-%d-%H%M%S_grim.png')";
        "${modifier}+d" = "exec fuzzel";
      };
      workspaceOutputAssign = [
        {
          workspace = "1";
          output = "HDMI-A-1 DP-2";
        }
        {
          workspace = "2";
          output = "HDMI-A-1 DP-2";
        }
        {
          workspace = "3";
          output = "HDMI-A-1 DP-2";
        }
        {
          workspace = "4";
          output = "HDMI-A-1 DP-2";
        }
        {
          workspace = "5";
          output = "HDMI-A-1 DP-2";
        }
        {
          workspace = "6";
          output = "HDMI-A-1 DP-2";
        }
        {
          workspace = "7";
          output = "HDMI-A-1 DP-2";
        }
        {
          workspace = "8";
          output = "HDMI-A-1 DP-2";
        }
        {
          workspace = "9";
          output = "eDP-1";
        }
      ];
    };
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        output = ["eDP-1" "HDMI-A-1" "DP-2"];

        modules-left = ["sway/workspaces" "sway/mode"];
        modules-center = ["clock"];
        modules-right = [
          "network"
          "memory"
          "cpu"
          "temperature"
          "battery"
          "backlight"
          "wireplumber"
          "disk"
          "bluetooth"
          "tray"
        ];

        "sway/workspaces" = {
          format = "{name}";
          disable-scroll = true;
          all-outputs = true;
        };

        clock = {
          interval = 60;
          format = "{:%Y-%m-%d %H:%M}";
          max-length = 25;
        };

        network = {
          interval = 10;
          format-wifi = "  ({signalStrength}%)";
          format-ethernet = "󰈀 {ipaddr}/{cidr}";
          format-disconnected = "⚠  Disconnected";
          tooltip-format-wifi = "  {essid} ({signalStrength}%) {frequency}GHz";
          max-length = 15;
        };

        memory = {
          interval = 10;
          format = " {used:0.1f}G";
          tooltip-format = "{used:0.1f}G / {total:0.1f}G";
          max-length = 15;
        };

        cpu = {
          interval = 5;
          format = " {usage}%";
        };

        temperature = {
          format = " {temperatureC}°C";
          critical-threshold = 80;
        };

        battery = {
          interval = 60;
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon}  {capacity}%";
          format-charging = " {icon}  {capacity}%";
          format-icons = ["" "" "" "" ""];
          tooltip-format = "{timeTo}, charged cylcles: {cycles}, health: {health}%";
          max-length = 25;
        };

        backlight = {
          format = "{icon} {percent}%";
          format-icons = ["" ""];
        };

        wireplumber = {
          format = "{icon}  {volume}%";
          format-muted = "";
          format-icons = ["" "" ""];
          tooltip-format = "volume: {volume}%";
        };

        disk = {
          interval = 30;
          format = "{used}";
          path = "/";
        };

        bluetooth = {
          format = " {status}";
          format-connected = " {device_alias}";
          format-connected-battery = " {device_alias} {device_battery_percentage}%";
          tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
        };

        tray = {
          icon-size = 21;
          spacing = 10;
          show-passive-items = true;
        };
      };
    };
    style = lib.mkForce ./waybar-style.css;
  };
}
