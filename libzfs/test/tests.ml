open Alcotest

let () = run "Unit tests" [ Lib_tests.v; Zpool_tests.v ]
