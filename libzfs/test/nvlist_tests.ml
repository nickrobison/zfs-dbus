open Libzfs

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

let v =
  let open Alcotest in
  ("NVList tests", [ test_case "Simple NVList operations" `Quick nvlist_test ])
