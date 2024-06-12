module M = Libzfs_ffi.M

type t = { handle : M.Zfs_handle.t; name : string }

let name t = t.name

let of_handle handle =
  Gc.finalise (fun h -> M.zfs_close h) handle;
  let name = M.zfs_get_name handle in
  { handle; name }

let destroy t ?(force = false) () =
  match M.zfs_destroy t.handle force with
  | 0 -> ()
  | _ -> raise (Invalid_argument "Bad")
