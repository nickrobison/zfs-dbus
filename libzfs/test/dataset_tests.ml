open Libzfs
module T = Testables

let missing_pool =
  Zfs_exception.create 2009 "no such pool 'nothing'"
    (Some "cannot create 'nothing/testit'")

let missing_ancestor =
  Zfs_exception.create 2009 "parent does not exist"
    (Some "cannot create 'tank/missing/hello'")

let zfs = Zfs.init ()

let open_dataset name =
  match Zfs.get_dataset zfs name with
  | Ok d -> d
  | Error e -> Alcotest.fail (Zfs_exception.show e)

let maybe_cleanup ds =
  Result.fold ~ok:(fun d -> Dataset.destroy d ()) ~error:(fun _ -> ()) ds

let create_no_pool () =
  (* Create outside of pools *)
  let b = Dataset.Builder.create "nothing/testit" in
  let ds =
    Zfs.create_dataset b zfs |> Result.map Dataset.name
  in
  Alcotest.(check T.string_result)
    "Should failed to create in missing pool" (Error missing_pool) ds

let create_no_ancestor () =
  (* Create outside of pools *)
  let b = Dataset.Builder.create "tank/missing/hello" in
  let ds =
    Zfs.create_dataset b zfs |> Result.map Dataset.name
  in
  Alcotest.(check T.string_result)
    "Should fail due to missing ancestor" (Error missing_ancestor) ds

let simple_create () =
  let name = "tank/test123" in
  let b = Dataset.Builder.create name in
  let ds = Zfs.create_dataset b zfs in
  let res = Result.map Dataset.name ds in
  Alcotest.(check T.string_result) "Should have correct name" (Ok name) res;
  maybe_cleanup ds

let create_compress () =
  let b = Dataset.Builder.create "tank/cc" |> Dataset.Builder.with_compression Compression.LZ4 in
  let ds = Zfs.create_dataset b zfs in
  let res = ds |> Result.map Dataset.compression in
  Alcotest.(check T.compression_result) "Should have correct compression" (Ok Compression.LZ4) res;
  maybe_cleanup ds

let get_properties () =
  let ds = open_dataset "tank/media/music" in
  let props = Dataset.dump_properties ds in
  Alcotest.(check int) "Should have properties" 28 (List.length props);
  Alcotest.(check T.compression)
    "Should not be compressed" Compression.Off (Dataset.compression ds)

let v =
  let open Alcotest in
  ( "Dataset tests",
    [
      test_case "Dataset creation without pool" `Quick create_no_pool;
      test_case "Dataset creation without ancestor" `Quick create_no_ancestor;
      test_case "Dataset creation" `Quick simple_create;
      test_case "Dataset properties" `Quick get_properties;
      test_case "Dataset creation with compression" `Quick create_compress;
    ] )
