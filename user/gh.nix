{pkgsUnstable, ...}: let
  gh-image = pkgsUnstable.buildGoModule rec {
    pname = "gh-image";
    version = "d59ac2b";
    src = pkgsUnstable.fetchFromGitHub {
      owner = "drogers0";
      repo = "gh-image";
      rev = version;
      hash = "sha256-K1HKrii5BmngqM2x0yxoQYGYARtgshWmueigO2BEPn4=";
    };
    vendorHash = "sha256-TzVyLcfpa3eN9bHQJnuPuGeiOgxYbBurFdKq0EfpJL4=";
  };
in {
  programs.gh = {
    enable = true;
    extensions = [gh-image];
  };
}
