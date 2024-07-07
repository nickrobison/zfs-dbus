open Libzfs
open QCheck2
open NVPair
module T = Testables

let gen_typ : NVPair.typ Gen.t =
  let open Gen in
  frequency
    [
      (* (1, map (fun b -> Nvpair.Bool b) bool); *)
      (1, map (fun i -> NVPair.Int32 i) small_int);
      (1, map (fun s -> NVPair.String s) string_printable);
    ]

let gen_name = Gen.(string_size ~gen:printable (1 -- 10))
let gen_pair : NVPair.t Gen.t = Gen.(pair gen_name gen_typ)
let gen_pairs = Gen.list gen_pair
let show_pairs p = Fmt.str "%a" (Fmt.list NVPair.pp) p

let dedup_list l =
  let cons e acc = if List.mem e acc then acc else e :: acc in
  List.fold_right cons l []

let nvpair_roundtrip () =
  let p = ("test", NVPair.String "hello world") in
  let roundtrip =
    NVlist.of_pairs [ p ] |> NVlist.encode |> NVlist.decode |> NVlist.pairs
    |> List.hd
  in
  Alcotest.(check T.nvpair) "Should have same value" p roundtrip

let nvpair_list_test =
  [
    Test.make ~name:"Arbitrary NVPair list" ~print:show_pairs gen_pairs
      (fun pairs ->
        let p' = NVlist.of_pairs pairs |> NVlist.pairs in
        let dedup = List.rev (dedup_list pairs) in
        print_endline ("P: " ^ show_pairs p');
        print_endline ("Dedup: " ^ show_pairs dedup);
        List.equal NVPair.equal dedup p');
  ]

let v =
  let open Alcotest in
  (* let to_alcotest = List.map QCheck_alcotest.to_alcotest in *)
  ("NVPair tests", [ test_case "Simple roundtrip" `Quick nvpair_roundtrip ])
