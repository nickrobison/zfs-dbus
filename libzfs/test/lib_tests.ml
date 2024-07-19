open Libzfs

let version_test () =
  let version = Zfs.version () in
  Assertions.non_empty ~msg:"Should have version" version.kernel_version;
  Assertions.non_empty ~msg:"Should have version" version.version

let list_pools () =
  let l = Zfs.init () in
  let pools = Zfs.pools l in
  Assertions.gte "Should have some pools" 1 (List.length pools)

let list_datasets () =
  let l = Zfs.init () in
  let datasets = Zfs.datasets l in
  Alcotest.(check int) "Should not have datasets" 0 (List.length datasets)

let v =
  let open Alcotest in
  ( "Base library tests",
    [
      test_case "zfs_version" `Quick version_test;
      test_case "list_pools" `Quick list_pools;
      test_case "list_datasets" `Quick list_datasets;
    ] )
