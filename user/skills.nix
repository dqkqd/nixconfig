{pkgs, ...}: let
  fetchSkill = {
    owner,
    repo,
    rev,
    sha256,
    path ? null,
  }: let
    src = pkgs.fetchFromGitHub {inherit owner repo rev sha256;};
  in
    if path == null
    then src
    else "${src}/${path}";

  skills = {
    jujutsu = {
      owner = "danverbraganza";
      repo = "jujutsu-skill";
      rev = "b0668317ec8b375ea3d5815d3f029f4104443a0b";
      sha256 = "00p0j28lm2b30yj84xfm8nyxfrcz2c29b9n7km800a9qg631di0i";
      path = "jujutsu";
    };

    typescript-advanced-types = {
      owner = "wshobson";
      repo = "agents";
      rev = "2de74ac1c8f6669821dcef13153332c3168033c1";
      sha256 = "1zkx5wfcyzrj1hm1salx18dc9fbk18hvqj5sdkra3w68c9i39xw8";
      path = "plugins/javascript-typescript/skills/typescript-advanced-types";
    };

    web-design-guidelines = {
      owner = "vercel-labs";
      repo = "agent-skills";
      rev = "f8a72b9603728bb92a217a879b7e62e43ad76c81";
      sha256 = "1mk17hg6zvzn7lazjy51grgp8m0ph6mayzzfn8ibiq2wkk8l489d";
      path = "skills/web-design-guidelines";
    };

    frontend-design = {
      owner = "anthropics";
      repo = "skills";
      rev = "9d2f1ae187231d8199c64b5b762e1bdf2244733d";
      sha256 = "0360ws3km5ycpwn3w7pyzg508nx5p1n5mvlbkf226ff53bbnvcsk";
      path = "skills/frontend-design";
    };
  };
in {
  home.file =
    pkgs.lib.mapAttrs' (name: spec: {
      name = ".agents/skills/${name}";
      value.source = fetchSkill spec;
    })
    skills;
}
