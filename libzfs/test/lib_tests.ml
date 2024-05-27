open Libzfs

let version_test () =
  let version = Zfs.version () in
  Alcotest.(check string)
    "Should get version" version.kernel_version version.kernel_version

let v =
  let open Alcotest in
  ("Base library tests", [ test_case "zfs_version" `Quick version_test ])
