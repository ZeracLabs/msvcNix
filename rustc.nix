{
  lib,
  stdenvNoCC,
  makeWrapper,
  msvc-wine,
  msvc-sdk,
  clang-cl,
  rustc,
}:
stdenvNoCC.mkDerivation {
  inherit (rustc) version;
  pname = "rustc-wrapped";

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [
    rustc
  ];

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${lib.getExe' rustc "rustc"} $out/bin/rustc \
      --set CC ${lib.getExe clang-cl} \
      --suffix PATH : ${lib.makeBinPath [ clang-cl ]} \
      --add-flag "--target=x86_64-pc-windows-msvc" \
      --add-flag "-Clinker=lld-link" \
      --run 'BIN="${msvc-sdk}/bin/x64" . ${msvc-wine}/msvcenv-native.sh'
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    echo "compiling..."
    $out/bin/rustc ${./hello.rs} -o hello.exe

    echo "Checking..."
    if [ ! -f hello.exe ]; then
      echo "hello.exe not found!"
      exit 1
    fi
  '';

  meta.mainProgram = "rustc";
}
