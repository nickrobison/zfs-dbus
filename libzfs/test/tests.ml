open Alcotest

let () = run "Unit tests" [ Lib_tests.v; Dataset_tests.v ]
