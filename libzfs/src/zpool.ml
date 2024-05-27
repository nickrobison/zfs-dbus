module M = Libzfs_ffi.M
type t = {
  _handle: M.Zpool_handle.t;
  name: string;
}

let of_handle handle =
  let name = M.zpool_name handle in
   {_handle = handle; name}

let name t = t.name