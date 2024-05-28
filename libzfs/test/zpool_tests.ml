open Libzfs

let open_pool name = 
  let lib = Zfs.init () in
  Zfs.get_pool lib name

let root_dataset () =
  let tank = open_pool "tank" in
  let tankDs = Zpool.root_dataset tank in
  Alcotest.(check string)
    "Should have root dataset name" "tank" (Dataset.name tankDs)

let child_datasets () = 
  let tank = open_pool "tank" in
  let children = Zpool.child_datasets tank in
  Alcotest.(check int) "Should have children" 5 (List.length children)

let open_child () = 
  let tank = open_pool "tank" in
  let child = Zpool.get_dataset tank "tank/media" in
  Alcotest.(check string)
    "Should have child dataset name" "tanks" (Dataset.name child)

let v = 
  let open Alcotest in
  ("ZPool tests",
  [
    test_case "Get Root Dataset" `Quick root_dataset;
    test_case "Get child datasets" `Quick child_datasets;
    test_case "Open child dataset" `Quick open_child;
  ])