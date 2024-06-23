open Libzfs

let string_key name =
  Property_key.create name Fmt.string |> Property_map.Key.create

let int_key name = Property_key.create name Fmt.int |> Property_map.Key.create

let simple_tests () =
  let k1 = string_key "strings" in
  let k2 = int_key "ints" in
  let k3 = int_key "inters" in
  let p =
    Property_map.empty
    |> Property_map.add k1 "hello"
    |> Property_map.add k2 1234 |> Property_map.add k3 42
  in
  Alcotest.(check int) "Should have findings" 3 (Property_map.cardinal p);
  Alcotest.(check string) "Should have string" "hello" (Property_map.get k1 p);
  Alcotest.(check int) "Should have value" 1234 (Property_map.get k2 p);
  Alcotest.(check int) "Should have value" 42 (Property_map.get k3 p)

let v =
  let open Alcotest in
  ("Property Map tests", [ test_case "Simple tests" `Quick simple_tests ])
