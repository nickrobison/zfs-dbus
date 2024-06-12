open Libnvpair

let simple () =
  let ls = Nvlist.empty () in
  Alcotest.(check int) "Should be empty" 0 (Nvlist.size ls);
  let ls' = Nvlist.add_bool ls "test" true in
  Alcotest.(check int) "Should no be empty" 1 (Nvlist.size ls');
  Alcotest.(check (option bool))
    "Should have value" (Some true)
    (Nvlist.get_bool ls' "test")

let v =
  let open Alcotest in
  ("NVList tests", [ test_case "alloc_free" `Quick simple ])
