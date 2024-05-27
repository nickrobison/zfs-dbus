open Libzfs

let version_test () =
  let version = Zfs.version () in
  Alcotest.(check string)
    "Should get version" version.kernel_version version.kernel_version

let list_pools () = 
  let l = Zfs.init () in
  let pools = Zfs.pools l in
  Alcotest.(check int) "Should have pools" 2 (List.length pools)

let v =
  let open Alcotest in
  ("Base library tests", [ test_case "zfs_version" `Quick version_test; test_case "list_pools" `Quick list_pools ])
