open Libzfs

let zfs = Zfs.init ()

let open_dataset name =
  match Zfs.get_dataset zfs name with
  | Ok d -> d
  | Error e -> Alcotest.fail (Zfs_exception.show e)

let create_no_pool () =
  (* Create outside of pools *)
  let ds = Zfs.create_dataset zfs ~name:"nothing/testit" |> Result.get_error in
  let code = ds |> Zfs_exception.code in
  Alcotest.(check int) "Should not be created" 2009 code;
  Alcotest.(check (option string))
    "Should have correct action" (Some "cannot create 'nothing/testit'")
    (Zfs_exception.action ds);
  Alcotest.(check string)
    "Should fail due to missing pool" "no such pool 'nothing'"
    (Zfs_exception.description ds)

let create_no_ancestor () =
  (* Create outside of pools *)
  let ds =
    Zfs.create_dataset zfs ~name:"tank/missing/hello" |> Result.get_error
  in
  let code = ds |> Zfs_exception.code in
  Alcotest.(check int) "Should not be created" 2009 code;
  Alcotest.(check (option string))
    "Should have correct action" (Some "cannot create 'tank/missing/hello'")
    (Zfs_exception.action ds);
  Alcotest.(check string)
    "Should fail due to missing pool" "parent does not exist"
    (Zfs_exception.description ds)

let simple_create () =
  let ds = Zfs.create_dataset zfs ~name:"tank/test123" |> Result.get_ok in
  Alcotest.(check string)
    "Should have correct name" "tank/test123" (Dataset.name ds);
  Dataset.destroy ds ()

let get_properties () =
  let ds = open_dataset "tiny/media/audio" in
  let props = Dataset.dump_properties ds in
  Alcotest.(check (list (pair string string))) "Should have properties" [] props

let v =
  let open Alcotest in
  ( "Dataset tests",
    [
      test_case "Dataset createion without pool" `Quick create_no_pool;
      test_case "Dataset creation without ancestor" `Quick create_no_ancestor;
      test_case "Dataset creation" `Quick simple_create;
      test_case "Dataset properties" `Quick get_properties;
    ] )
