open Libzfs

let gen_typ : Nvpair.typ QCheck2.Gen.t =
  let open QCheck2.Gen in
  frequency
    [
      (* (1, map (fun b -> Nvpair.Bool b) bool); *)
      (1, map (fun i -> Nvpair.Int32 i) small_int);
      (1, map (fun s -> Nvpair.String s) string_printable);
    ]

let gen_name = QCheck2.Gen.(string_size ~gen:printable (1 -- 10))
let gen_pair : Nvpair.t QCheck2.Gen.t = QCheck2.Gen.(pair gen_name gen_typ)
let gen_pairs = QCheck2.Gen.list gen_pair
let show_pairs p = Fmt.str "%a" (Fmt.list Nvpair.pp) p

let nvpair_qcheck_test =
  [
    QCheck2.Test.make ~name:"Arbitrary NVPair list" ~print:show_pairs gen_pairs
      (fun pairs ->
        let p' = Nvlist.t_of_pairs pairs |> Nvlist.pairs_of_t in
        List.length pairs = List.length p');
  ]

let v =
  let to_alcotest = List.map QCheck_alcotest.to_alcotest in
  ("NVPair tests", to_alcotest nvpair_qcheck_test)
