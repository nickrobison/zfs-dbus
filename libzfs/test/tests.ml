open Alcotest

let () =
  run "Unit tests"
    [
      Lib_tests.v;
      Nvlist_tests.v;
      Property_map_tests.v;
      Dataset_tests.v;
      Nvpair_tests.v;
    ]
