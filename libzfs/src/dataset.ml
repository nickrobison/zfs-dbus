module M = Libzfs_ffi.M

type t ={ _handle: M.Zfs_handle.t; name: string}

let name t = t.name

let of_handle handle = 
  Gc.finalise (fun h -> M.zfs_close h) handle;
  let name = M.zfs_get_name handle in
  {_handle = handle; name}