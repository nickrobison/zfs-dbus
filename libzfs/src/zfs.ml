module M = Libzfs_ffi.M

let version () : Version.t =
  let kernel_version = M.zfs_kernel_version () in
  let version = M.zfs_version () in
  { version; kernel_version }
