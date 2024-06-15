open Libzfs
open QCheck2

let gen_typ : Nvpair.typ Gen.t =
  let open Gen in
  frequency
    [
      (* (1, map (fun b -> Nvpair.Bool b) bool); *)
      (1, map (fun i -> Nvpair.Int32 i) small_int);
      (1, map (fun s -> Nvpair.String s) string_printable);
    ]

let gen_name = Gen.(string_size ~gen:printable (1 -- 10))
let gen_pair : Nvpair.t Gen.t = Gen.(pair gen_name gen_typ)
let gen_pairs = Gen.list gen_pair
let show_pairs p = Fmt.str "%a" (Fmt.list Nvpair.pp) p

let dedup_list l =
  let cons e acc = if List.mem e acc then acc else e :: acc in
  List.fold_right cons l []

let nvpair_list_test =
  [
    Test.make ~name:"Arbitrary NVPair list" ~print:show_pairs gen_pairs
      (fun pairs ->
        let p' = Nvlist.t_of_pairs pairs |> Nvlist.pairs_of_t in
        let dedup = List.rev (dedup_list pairs) in
        print_endline ("P: " ^ show_pairs p');
        print_endline ("Dedup: " ^ show_pairs dedup);
        List.equal Nvpair.equal dedup p');
  ]

let v =
  let to_alcotest = List.map QCheck_alcotest.to_alcotest in
  ("NVPair tests", to_alcotest nvpair_list_test)
