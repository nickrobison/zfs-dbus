open Libzfs
open NVPair

let printable_gen = QCheck2.Gen.(option string_printable)
let age_gen = QCheck2.Gen.(0 -- 1)

type simple_record = { name : string; age : int; favorite : string option }
[@@deriving show, eq]

let simple_record name age favorite = { name; age; favorite }

let gen_simple_record =
  QCheck2.Gen.(simple_record <$> string_printable <*> age_gen <*> printable_gen)

let record_testable = Alcotest.testable pp_simple_record equal_simple_record
let missing_field f = raise (Invalid_argument ("Cannot find field: " ^ f))

let nvpairs_of_simple_record r =
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
  { name; age; favorite }

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
  let r : simple_record =
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
  Alcotest.(check record_testable) "Should be the same" r r'

let record_marshall_test =
  QCheck2.Test.make ~name:"Record marshall" ~print:show_simple_record
    gen_simple_record (fun r ->
      let r' =
        nvpairs_of_simple_record r |> NVlist.of_pairs |> NVlist.pairs
        |> simple_record_of_pairs
      in
      equal_simple_record r r')

let v =
  let open Alcotest in
  let to_alcotest = QCheck_alcotest.to_alcotest in
  ( "NVlist tests",
    [
      test_case "Simple NVlist operations" `Quick nvlist_tests;
      test_case "Simple record tests" `Quick simple_record_test;
      to_alcotest record_marshall_test;
    ] )
