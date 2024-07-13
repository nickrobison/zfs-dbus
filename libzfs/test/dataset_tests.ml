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
  let ds' = Result.bind ds Dataset.destroy in
  Alcotest.(check T.unit) "Should have destroyed the dataset" (Ok ()) ds'

let create_no_pool () =
  (* Create outside of pools *)
  let b = Dataset.Builder.create "nothing/testit" in
  let ds = Zfs.create_dataset b zfs |> Result.map Dataset.name in
  Alcotest.(check T.string_result)
    "Should failed to create in missing pool" (Error missing_pool) ds

let create_no_ancestor () =
  (* Create outside of pools *)
  let b = Dataset.Builder.create "tank/missing/hello" in
  let ds = Zfs.create_dataset b zfs |> Result.map Dataset.name in
  Alcotest.(check T.string_result)
    "Should fail due to missing ancestor" (Error missing_ancestor) ds

let simple_create () =
  let name = "tiny/test123" in
  let b = Dataset.Builder.create name in
  let ds = Zfs.create_dataset b zfs in
  let res = Result.map Dataset.name ds in
  Alcotest.(check T.string_result) "Should have correct name" (Ok name) res;
  maybe_cleanup ds

let create_compress () =
  let rs = Recordsize.of_int 1024 in
  let b =
    Dataset.Builder.create "tiny/cc"
    |> Dataset.Builder.with_compression (Compression.Gzip 7)
    |> Dataset.Builder.with_recordsize rs
  in
  let ds = Zfs.create_dataset b zfs in
  let res = ds |> Result.map Dataset.compression in
  Alcotest.(check T.compression_result)
    "Should have correct compression" (Ok (Compression.Gzip 7)) res;
  Alcotest.(check T.recordsize_result)
    "Should have custom recordsize" (Ok rs)
    (Result.map Dataset.recordsize ds);

  maybe_cleanup ds

let get_properties () =
  let ds = open_dataset "tank/media/audio" in
  let props = Dataset.dump_properties ds in
  Alcotest.(check int) "Should have properties" 32 (List.length props);
  Alcotest.(check T.compression)
    "Should have correct compression compressed" Compression.LZ4
    (Dataset.compression ds);
  Alcotest.(check T.recordsize)
    "Should have default record size"
    (Recordsize.of_int 1048576)
    (Dataset.recordsize ds)

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
