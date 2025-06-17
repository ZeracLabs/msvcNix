{
  lib,
  stdenvNoCC,
  makeWrapper,
  llvmPackages,
  msvc-wine,
  msvc-sdk,
}:
stdenvNoCC.mkDerivation {
  pname = "clang-cl-wrapped";
  inherit (msvc-sdk) version;

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [
    llvmPackages.clang-unwrapped
    llvmPackages.bintools-unwrapped
  ];

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${lib.getExe' llvmPackages.clang-unwrapped "clang-cl"} $out/bin/clang-cl \
      --run 'BIN="${msvc-sdk}/bin/x64" . ${msvc-wine}/msvcenv-native.sh'

    makeWrapper ${lib.getExe' llvmPackages.bintools-unwrapped "lld-link"} $out/bin/lld-link \
      --run 'BIN="${msvc-sdk}/bin/x64" . ${msvc-wine}/msvcenv-native.sh'
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    echo "compiling..."
    $out/bin/clang-cl -Fo"$TMPDIR/" -c ${./hello.c}

    echo "linking..."
    $out/bin/lld-link "$TMPDIR"/*.obj -out:hello.exe

    echo "checking..."
    if [ ! -f hello.exe ]; then
      echo "hello.exe not found!"
      exit 1
    fi
  '';

  meta.mainProgram = "clang-cl";
}
