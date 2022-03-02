{ lib, stdenv, fetchFromGitHub, cmake, ninja
, fetchpatch
, secureBuild ? false
}:

let
  soext = stdenv.hostPlatform.extensions.sharedLibrary;
in
stdenv.mkDerivation rec {
  pname   = "mimalloc";
  version = "2.0.5";

  src = fetchFromGitHub {
    owner  = "microsoft";
    repo   = pname;
    rev    = "v${version}";
    sha256 = "sha256-q3W/w1Ofqt6EbKF/Jf9wcC+7jAxh59B3cOGxudWQXlA=";
  };
  patches = [
    (fetchpatch {
      name = "older-macos-fixes.patch";
      url = "https://github.com/microsoft/mimalloc/commit/40e0507a5959ee218f308d33aec212c3ebeef3bb.patch";
      sha256 = "15qx2a3axhhwbfzxdis98b8j14y9cfgca0i484aj2pjpqnm0pb8c";
    })
  ];

  doCheck = true;
  preCheck = let
    ldLibraryPathEnv = if stdenv.isDarwin then "DYLD_LIBRARY_PATH" else "LD_LIBRARY_PATH";
  in ''
    export ${ldLibraryPathEnv}="$(pwd)/build:''${${ldLibraryPathEnv}}"
  '';

  nativeBuildInputs = [ cmake ninja ];
  cmakeFlags = [ "-DMI_INSTALL_TOPLEVEL=ON" ] ++ lib.optional secureBuild [ "-DMI_SECURE=ON" ];

  postInstall = let
    rel = lib.versions.majorMinor version;
    suffix = if stdenv.isLinux then "${soext}.${rel}" else ".${rel}${soext}";
  in ''
    # first, move headers and cmake files, that's easy
    mkdir -p $dev/lib
    mv $out/lib/cmake $dev/lib/

    find $dev $out -type f
  '' + (lib.optionalString secureBuild ''
    # pretend we're normal mimalloc
    ln -sfv $out/lib/libmimalloc-secure${suffix} $out/lib/libmimalloc${suffix}
    ln -sfv $out/lib/libmimalloc-secure${suffix} $out/lib/libmimalloc${soext}
    ln -sfv $out/lib/libmimalloc-secure.a $out/lib/libmimalloc.a
    ln -sfv $out/lib/mimalloc-secure.o $out/lib/mimalloc.o
  '');

  outputs = [ "out" "dev" ];

  meta = with lib; {
    description = "Compact, fast, general-purpose memory allocator";
    homepage    = "https://github.com/microsoft/mimalloc";
    license     = licenses.bsd2;
    platforms   = platforms.unix;
    maintainers = with maintainers; [ kamadorueda thoughtpolice ];
  };
}
