final: prev: {

  bambu-studio = prev.bambu-studio.overrideAttrs (oldAttrs: {
    version = "01.00.01.50";
    src = prev.fetchFromGitHub {
      owner = "bambulab";
      repo = "BambuStudio";
      rev = "v01.00.01.50";
      hash = "sha256-7mkrPl2CQSfc1lRjl1ilwxdYcK5iRU//QGKmdCicK30=";
    };
  });


  sc-im = prev.sc-im.overrideAttrs (old: {
    hardeningDisable = [ "fortify" ];
    src = prev.fetchFromGitHub {
      version = "0.8.5";
      owner = "mipmip";
      repo = "sc-im";
      rev = "pimsMain";
      hash = "sha256-8KwGDEmr182ippdoeNVvNMFN6+iJu83xkX7xMbI5/No=";
    };
  });

  quarto = prev.quarto.override {
    extraRPackages = [
      prev.rPackages.reticulate
    ];
    extraPythonPackages = ps: with ps; [
      plotly
      numpy
      pandas
      matplotlib
      tabulate
    ];
  };

}
