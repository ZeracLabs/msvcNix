{
  lib,
  stdenvNoCC,
  msvc-wine,
  writableTmpDirAsHomeHook,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "msvc-sdk";
  version = "17.14.5";

  src = stdenvNoCC.mkDerivation {
    inherit (finalAttrs) version;
    pname = "msvc-download";

    dontUnpack = true;
    dontBuild = true;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-iGy9PTNyz/8uqZomOcliIIrJ2CveYWrhyoedS3U5n0k=";

    installPhase = ''
      mkdir -p "$out"

      ${msvc-wine}/vsdownload.py --accept-license --dest "$out"
    '';
  };

  dontBuild = true;

  nativeBuildInputs = [ writableTmpDirAsHomeHook ];

  preInstall = ''
    mkdir -p $out
    cp -a ./ $out
  '';

  postInstall = ''
    ${msvc-wine}/install.sh $out
  '';
})
