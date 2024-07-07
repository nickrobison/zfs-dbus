let prologue = "\n#include <libnvpair.h>\n#include <sys/zio_compress.h>\n"

let () =
  print_endline prologue;
  Cstubs.Types.write_c Format.std_formatter (module Nvpair_types.M)
