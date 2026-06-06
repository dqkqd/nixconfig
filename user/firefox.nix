{
  programs.firefox = {
    enable = true;
    languagePacks = ["en-US" "ja"];

    policies = {
      # Updates & Background Services
      AppAutoUpdate = false;
      BackgroundAppUpdate = false;
      DisableTelemetry = true;

      ExtensionSettings = let
        moz = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";
      in {
        "*".installation_mode = "blocked";
        "uBlock0@raymondhill.net" = {
          install_url = moz "ublock-origin";
          installation_mode = "force_installed";
          updates_disabled = true;
        };
        "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
          install_url = moz "vimium-ff";
          installation_mode = "force_installed";
          updates_disabled = true;
        };
        "addon@darkreader.org" = {
          install_url = moz "darkreader";
          installation_mode = "force_installed";
          updates_disabled = true;
        };
      };
    };

    profiles.default = {
      settings = {
        "browser.startup.page" = 3;
      };
      search = {
        force = true;
        default = "ddg";
        privateDefault = "ddg";
      };
    };
  };
}
