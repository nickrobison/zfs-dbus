open Ctypes


module M (F : Ctypes.FOREIGN) = struct
  let foreign = F.foreign
  let foreign_value = F.foreign_value

  let funptr = Foreign.funptr

  let const x = x

  module C = struct
    include Ctypes

    let ( @-> ) = F.( @-> )
    let returning = F.returning
  end

  module Zfs_handle  = struct
    type t = unit C.ptr
    let t: t C.typ = C.ptr C.void
  end

  module Zpool_handle  = struct
    type t = unit ptr
    let t: t C.typ = C.ptr C.void
  end

  type zpool_iter_f = Zpool_handle.t -> unit ptr -> int
  let zpool_iter_f: zpool_iter_f C.typ = Foreign.funptr (Zpool_handle.t @-> ptr void @-> returning int)

  (* Library init*)
  let libzfs_init = foreign "libzfs_init" C.(void @-> returning Zfs_handle.t )

  let libfzs_close = foreign "libzfs_fini" C.(Zfs_handle.t @-> returning void)

  let zpool_iter = foreign "zpool_iter" C.(Zfs_handle.t @-> zpool_iter_f @-> ptr void @-> returning int)

  (* Zpool functions*)

  let zpool_name = foreign "zpool_get_name" C.(Zpool_handle.t @-> returning string)

  (* ZFS version functions *)
  let zfs_version =
    foreign "zfs_version_userland" C.(void @-> returning (const string))

  let zfs_kernel_version =
    foreign "zfs_version_kernel" C.(void @-> returning string)
end
