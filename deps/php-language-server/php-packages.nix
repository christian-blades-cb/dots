{composerEnv, fetchurl, fetchgit ? null, fetchhg ? null, fetchsvn ? null, noDev ? false}:

let
  packages = {
    "felixfbecker/advanced-json-rpc" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "felixfbecker-advanced-json-rpc-5311a31400f31c5a993ade410cdb41178aa56346";
        src = fetchurl {
          url = https://api.github.com/repos/felixfbecker/php-advanced-json-rpc/zipball/5311a31400f31c5a993ade410cdb41178aa56346;
          sha256 = "1z368v16s9ch56v61zvz80c1dw33mp5shwmvzldazksaz3nm08hk";
        };
      };
    };
    "felixfbecker/language-server" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "felixfbecker-language-server-0c758ec815468c64947cf2242dcdb7e17419280a";
        src = fetchurl {
          url = https://api.github.com/repos/felixfbecker/php-language-server/zipball/0c758ec815468c64947cf2242dcdb7e17419280a;
          sha256 = "0shpcmp9654k6x5mic7f9w0r0xkzpipiq07rh3by7rs6gd5mb75s";
        };
      };
    };
    "netresearch/jsonmapper" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "netresearch-jsonmapper-979abda4b128415c642b06f07db615e75cfd3173";
        src = fetchurl {
          url = https://api.github.com/repos/cweiske/jsonmapper/zipball/979abda4b128415c642b06f07db615e75cfd3173;
          sha256 = "1s26cszs4flnwlxda0nfrh1r0pl8baldjnpzkxa4ylqxizrkkns5";
        };
      };
    };
    "nikic/php-parser" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "nikic-php-parser-bb87e28e7d7b8d9a7fda231d37457c9210faf6ce";
        src = fetchurl {
          url = https://api.github.com/repos/nikic/PHP-Parser/zipball/bb87e28e7d7b8d9a7fda231d37457c9210faf6ce;
          sha256 = "1fa8sc081bjl170984ax0p0yqqwwjvpsd9d20nkdbcvy7dphs3k3";
        };
      };
    };
    "phpdocumentor/reflection-common" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpdocumentor-reflection-common-21bdeb5f65d7ebf9f43b1b25d404f87deab5bfb6";
        src = fetchurl {
          url = https://api.github.com/repos/phpDocumentor/ReflectionCommon/zipball/21bdeb5f65d7ebf9f43b1b25d404f87deab5bfb6;
          sha256 = "1yaf1zg9lnkfnq2ndpviv0hg5bza9vjvv5l4wgcn25lx1p8a94w2";
        };
      };
    };
    "phpdocumentor/reflection-docblock" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpdocumentor-reflection-docblock-bf329f6c1aadea3299f08ee804682b7c45b326a2";
        src = fetchurl {
          url = https://api.github.com/repos/phpDocumentor/ReflectionDocBlock/zipball/bf329f6c1aadea3299f08ee804682b7c45b326a2;
          sha256 = "1sk0la8k0d4adi149ghbs37cbli158j9xb2qd17b1wjlp5lriw0a";
        };
      };
    };
    "phpdocumentor/type-resolver" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "phpdocumentor-type-resolver-9c977708995954784726e25d0cd1dddf4e65b0f7";
        src = fetchurl {
          url = https://api.github.com/repos/phpDocumentor/TypeResolver/zipball/9c977708995954784726e25d0cd1dddf4e65b0f7;
          sha256 = "0h888r2iy2290yp9i3fij8wd5b7960yi7yn1rwh26x1xxd83n2mb";
        };
      };
    };
    "sabre/event" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "sabre-event-92857c7282da90d3de2b7b5a50447bb2f0d13323";
        src = fetchurl {
          url = https://api.github.com/repos/sabre-io/event/zipball/92857c7282da90d3de2b7b5a50447bb2f0d13323;
          sha256 = "0hybcqar0fnlf301q6dv4nznahbamydqfm8ky3ib23mm8lbhiijc";
        };
      };
    };
    "symfony/polyfill-ctype" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "symfony-polyfill-ctype-2edd75b8b35d62fd3eeabba73b26b8f1f60ce13d";
        src = fetchurl {
          url = https://api.github.com/repos/symfony/polyfill-ctype/zipball/2edd75b8b35d62fd3eeabba73b26b8f1f60ce13d;
          sha256 = "0gixj9117cv2bc858fphc4vqgyp57g9srg063l7f103zfwhq3vmn";
        };
      };
    };
    "webmozart/assert" = {
      targetDir = "";
      src = composerEnv.buildZipPackage {
        name = "webmozart-assert-bafc69caeb4d49c39fd0779086c03a3738cbb389";
        src = fetchurl {
          url = https://api.github.com/repos/webmozart/assert/zipball/bafc69caeb4d49c39fd0779086c03a3738cbb389;
          sha256 = "0wd0si4c9r1256xj76vgk2slxpamd0wzam3dyyz0g8xgyra7201c";
        };
      };
    };
  };
  devPackages = {};
in
composerEnv.buildPackage {
  inherit packages devPackages noDev;
  name = "felixfbecker-language-server";
  src = ./.;
  executable = false;
  symlinkDependencies = false;
  meta = {};
}