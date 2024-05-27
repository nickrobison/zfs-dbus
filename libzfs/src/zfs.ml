open Ctypes
module M = Libzfs_ffi.M

type t = M.Zfs_handle.t


let version () : Version.t =
  let kernel_version = M.zfs_kernel_version () in
  let version = M.zfs_version () in
  { version; kernel_version }

let init () = 
let handle = M.libzfs_init () in
Gc.finalise (fun v -> M.libfzs_close v) handle;
handle


let pools t = 
  let pool_ref = ref [] in
  let handler pool _ = 
    let p = Zpool.of_handle pool in
    pool_ref := !pool_ref @ [p];
    0
  in
  let u = allocate int 1 in
  let _d = M.zpool_iter t handler (to_voidp u) in
  !pool_ref
