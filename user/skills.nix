{ pkgs, ... }:

let
  jujutsu-skill = pkgs.fetchFromGitHub {
    owner = "danverbraganza";
    repo = "jujutsu-skill";
    rev = "b0668317ec8b375ea3d5815d3f029f4104443a0b";
    sha256 = "00p0j28lm2b30yj84xfm8nyxfrcz2c29b9n7km800a9qg631di0i";
  };
in
{
  home.file.".agents/skills/jujutsu".source = "${jujutsu-skill}/jujutsu";
}