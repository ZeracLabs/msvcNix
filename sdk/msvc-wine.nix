{
  lib,
  stdenvNoCC,
  python3,
  fetchFromGitHub,
  nix-update-script,
  makeBinaryWrapper,
  msitools,
  git,
  cacert,
  perl,
  wine64,
}:
let
in
stdenvNoCC.mkDerivation {
  pname = "msvc-wine";
  version = "0-unstable-2025-06-09";

  src = fetchFromGitHub {
    owner = "mstorsjo";
    repo = "msvc-wine";
    rev = "cb78cc0bc91a9e3da69989b76b99d6f44a7d1a69";
    hash = "sha256-oeaM9Djlnyv3lBTPmKrPefvqaL0tnY1an6/CXpq0z1c=";
  };

  patches = [
    ./install.patch
  ];

  postPatch = ''
    substituteInPlace "vsdownload.py" \
      --replace-fail "msiexec" ${lib.getExe' msitools "msiexec"} \
      --replace-fail "msiextract" ${lib.getExe' msitools "msiextract"} \
      --replace-fail "git" ${lib.getExe git}

    substituteInPlace "install.sh" \
      --replace-fail "\$(command -v wine64 || command -v wine)" ${lib.getExe wine64}

    substituteInPlace "wrappers/wine-msvc.sh" \
      --replace-fail "\$(command -v wine64 || command -v wine || false)" ${lib.getExe wine64}

    substituteInPlace "msvcenv-native.sh" \
      --replace-fail "/usr/bin/env echo" "echo" \
      --replace-fail "# lld-link, it's recommended to use -fuse-ld=lld.)" "set -euo pipefail"
  '';

  nativeBuildInputs = [ makeBinaryWrapper ];
  buildInputs = [
    msitools
    python3
    cacert
    perl
    wine64
  ];

  dontBuild = true;
  preInstall = ''
    mkdir -p $out
    mv ./* $out
  '';
  postInstall = ''
    mv $out/vsdownload.py $out/.vsdownload.py

    makeWrapper ${python3.interpreter} "$out/vsdownload.py" \
      --add-flags "$out/.vsdownload.py" \
      --set NIX_SSL_CERT_FILE ${cacert}/etc/ssl/certs/ca-bundle.crt \
      --set SSL_CERT_FILE ${cacert}/etc/ssl/certs/ca-bundle.crt
  '';

  passthru.updateScript = nix-update-script { extraArgs = "--version=branch"; };

  meta.mainProgram = "vsdownload.py";
}
