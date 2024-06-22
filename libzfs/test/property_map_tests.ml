open Libzfs

let string_key = Property_map.Key.create "hello"

(* module StringKey = struct
     let key = Property_key.create "strings"
   end

   module IntKey = struct
     let key = Property_key.create "ints"
   end *)

let simple_tests () =
  let k1 = Property_map.Key.create "hello" in
  let k2 = Property_map.Key.create 0 in
  let p =
    Property_map.empty
    |> Property_map.add k1 "hello"
    |> Property_map.add k2 1234
  in
  Alcotest.(check int) "Should have findings" 2 (Property_map.cardinal p);
  Alcotest.(check string) "Should have string" "hello" (Property_map.get k1 p)

let v =
  let open Alcotest in
  ("Property Map tests", [ test_case "Simple tests" `Quick simple_tests ])
