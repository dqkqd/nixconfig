{...}: {
  programs.tmux = {
    enable = true;
    # https://pi.dev/docs/latest/tmux — without extended keys, Shift+Enter/Ctrl+Enter
    # collapse to plain Enter inside pi
    extraConfig = ''
      set -g extended-keys on
      set -g extended-keys-format csi-u
    '';
  };
}
