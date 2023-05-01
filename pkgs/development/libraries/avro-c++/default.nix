{ lib, stdenv, fetchurl, cmake, boost, python3 }:

stdenv.mkDerivation rec {
  pname = "avro-c++";
  version = "1.11.1";

  src = fetchurl {
    url = "mirror://apache/avro/avro-${version}/cpp/avro-cpp-${version}.tar.gz";
    sha256 = "sha256-LuxeWnCDULUP3slja5aKPjGBcDE+8tReyQmSEIdXGYw=";
  };

  nativeBuildInputs = [ cmake python3 ];
  buildInputs = [ boost ];

  preConfigure = ''
    substituteInPlace test/SchemaTests.cc --replace "BOOST_CHECKPOINT" "BOOST_TEST_CHECKPOINT"
    substituteInPlace test/buffertest.cc --replace "BOOST_MESSAGE" "BOOST_TEST_MESSAGE"
  '';

  meta = {
    description = "A C++ library which implements parts of the Avro Specification";
    homepage = "https://avro.apache.org/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ rasendubi ];
    platforms = lib.platforms.all;
  };
}
