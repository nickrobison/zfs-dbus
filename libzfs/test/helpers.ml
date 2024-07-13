open Libzfs

let fail e = Alcotest.(failf "Failed to create dataset: %a" Zfs_exception.pp e)

let unwind ~protect f x =
  let module E = struct
    type 'a t = Left of 'a | Right of exn
  end in
  let res = try E.Left (f x) with e -> E.Right e in
  let () = protect x in
  match res with E.Left y -> y | E.Right e -> raise e

let destroy_ds ds =
  match Dataset.destroy ds with Ok _ -> () | Error e -> fail e

let with_dataset zfs builder f =
  match Zfs.create_dataset builder zfs with
  | Ok ds -> unwind ~protect:destroy_ds f ds
  | Error e -> fail e
