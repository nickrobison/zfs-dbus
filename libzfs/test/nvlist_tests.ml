open Libzfs
open NVPair
module T = Testables
module G = Generators

(* let record_testable = Alcotest.testable pp_simple_record equal_simple_record *)
let missing_field f = raise (Invalid_argument ("Cannot find field: " ^ f))

let nvpairs_of_simple_record (r : Simple_record.t) =
  let open NVPair in
  [ ("name", String r.name); ("age", Int32 r.age) ]
  @ Option.fold ~none:[] ~some:(fun f -> [ ("favorite", String f) ]) r.favorite

let simple_record_of_pairs (pairs : NVPair.t list) =
  let name =
    match List.find (fun p -> fst p = "name") pairs with
    | _, String s -> s
    | _ -> missing_field "name"
  in
  let age =
    match List.find (fun p -> fst p = "age") pairs with
    | _, Int32 i -> i
    | _ -> missing_field "age"
  in
  let favorite =
    match List.find_opt (fun p -> fst p = "favorite") pairs with
    | Some (_, String s) -> Some s
    | None -> None
    | _ -> missing_field "favorite"
  in
  Simple_record.t name age favorite

let nvlist_tests () =
  let l = NVlist.empty () in
  Alcotest.(check int) "Should be empty" 0 (NVlist.size l);
  let l' = NVlist.add_bool l "test_bool" false in
  Alcotest.(check (option bool))
    "Should have false value" (Some false)
    (NVlist.get_bool l' "test_bool");
  Alcotest.(check (option string))
    "Should not have string value" None
    (NVlist.get_string l' "test_string");
  let l' = NVlist.add_string l' "test_string" "This is not a drill" in
  Alcotest.(check (option string))
    "Should have string value" (Some "This is not a drill")
    (NVlist.get_string l' "test_string");
  let l' = NVlist.add_string l' "test_string" "" in
  Alcotest.(check (option string))
    "Should have string value" (Some "")
    (NVlist.get_string l' "test_string")

let simple_record_test () =
  let r : Simple_record.t =
    { name = "Test1"; age = 42; favorite = Some "icecream" }
  in
  let pairs = nvpairs_of_simple_record r in
  Alcotest.(check int)
    "Should have the correct number of pairs" 3 (List.length pairs);
  let nvlist = NVlist.of_pairs pairs in
  Alcotest.(check (list string))
    "Should have correct keys"
    [ "age"; "favorite"; "name" ]
    (NVlist.keys nvlist);
  Alcotest.(check int)
    "Should have correct number of pairs" 3
    (List.length (NVlist.pairs nvlist));
  let r' = NVlist.pairs nvlist |> simple_record_of_pairs in
  Alcotest.(check T.simple_record) "Should be the same" r r'

let record_marshall_test =
  QCheck2.Test.make ~name:"Record marshall" ~print:Simple_record.show
    G.simple_record (fun r ->
      let r' =
        nvpairs_of_simple_record r |> NVlist.of_pairs |> NVlist.pairs
        |> simple_record_of_pairs
      in
      Simple_record.equal r r')

let v =
  let open Alcotest in
  let to_alcotest = QCheck_alcotest.to_alcotest in
  ( "NVlist tests",
    [
      test_case "Simple NVlist operations" `Quick nvlist_tests;
      test_case "Simple record tests" `Quick simple_record_test;
      to_alcotest record_marshall_test;
    ] )
