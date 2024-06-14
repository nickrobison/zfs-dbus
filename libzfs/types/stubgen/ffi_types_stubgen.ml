let prologue = "
#include <libnvpair.h>
"

let () =
  print_endline prologue;
  Cstubs.Types.write_c Format.std_formatter (module Nvpair_types.M)