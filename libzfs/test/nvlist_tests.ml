open Libzfs

type simple_record = { name : string; age : int; favorite : string option }

let nvpairs_of_simple_record r =
  let open Nvpair in
  [ ("name", String r.name); ("age", Int32 r.age) ]
  @ Option.fold ~none:[] ~some:(fun f -> [ ("favorite", String f) ]) r.favorite
(* let simple_record_of_nvlist l = () *)

let nvlist_test () =
  let l = Nvlist.empty () in
  Alcotest.(check int) "Should be empty" 16 (Nvlist.size l);
  let _ = Nvlist.add_bool l "test_bool" false in
  Alcotest.(check (option bool))
    "Should have false value" (Some false)
    (Nvlist.get_bool l "test_bool");
  Alcotest.(check (option string))
    "Should not have string value" None
    (Nvlist.get_string l "test_string");
  let _ = Nvlist.add_string l "test_string" "This is not a drill" in
  Alcotest.(check (option string))
    "Should have string value" (Some "This is not a drill")
    (Nvlist.get_string l "test_string");
  let _ = Nvlist.add_string l "test_string" "" in
  Alcotest.(check (option string))
    "Should have string value" (Some "")
    (Nvlist.get_string l "test_string")

let marshalling_test () =
  let r : simple_record =
    { name = "Test1"; age = 42; favorite = Some "icecream" }
  in
  let pairs = nvpairs_of_simple_record r in
  Alcotest.(check int)
    "Should have the correct number of pairs" 3 (List.length pairs);
  let nvlist = Nvlist.encode pairs in
  Alcotest.(check (list string)) "Should have correct keys" ["favorite"; "age"; "name"] (Nvlist.keys nvlist)

let v =
  let open Alcotest in
  ( "NVList tests",
    [
      test_case "Simple NVList operations" `Quick nvlist_test;
      test_case "Simple record tests" `Quick marshalling_test;
    ] )
