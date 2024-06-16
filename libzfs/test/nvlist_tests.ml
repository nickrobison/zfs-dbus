open Libzfs

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
  let open NV.NVP in
  [ ("name", String r.name); ("age", Int32 r.age) ]
  @ Option.fold ~none:[] ~some:(fun f -> [ ("favorite", String f) ]) r.favorite

let simple_record_of_pairs (pairs : NV.NVP.t list) =
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

let simple_record_test () =
  let r : simple_record =
    { name = "Test1"; age = 42; favorite = Some "icecream" }
  in
  let pairs = nvpairs_of_simple_record r in
  Alcotest.(check int)
    "Should have the correct number of pairs" 3 (List.length pairs);
  let nvlist = NV.NVL.t_of_pairs pairs in
  Alcotest.(check (list string))
    "Should have correct keys"
    [ "favorite"; "age"; "name" ]
    (NV.NVL.keys nvlist);
  Alcotest.(check int)
    "Should have correct number of pairs" 3
    (List.length (NV.NVL.pairs_of_t nvlist));
  let r' = NV.NVL.pairs_of_t nvlist |> simple_record_of_pairs in
  Alcotest.(check record_testable) "Should be the same" r r'

let record_marshall_test =
  QCheck2.Test.make ~name:"Record marshall" ~print:show_simple_record
    gen_simple_record (fun r ->
      let r' =
        nvpairs_of_simple_record r |> Nvlist.t_of_pairs |> Nvlist.pairs_of_t
        |> simple_record_of_pairs
      in
      equal_simple_record r r')

let v =
  let open Alcotest in
  let to_alcotest = QCheck_alcotest.to_alcotest in
  ( "NVList tests",
    [
      test_case "Simple NVList operations" `Quick nvlist_test;
      test_case "Simple record tests" `Quick simple_record_test;
      to_alcotest record_marshall_test;
    ] )
