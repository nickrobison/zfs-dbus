module M (F : Ctypes.FOREIGN) = struct
  include Zfs_types
  include Libnvpair_bindings.M (F)

  let foreign = F.foreign
  let foreign_value = F.foreign_value
  let funptr = Foreign.funptr
  let const x = x

  module C = struct
    include Ctypes

    let ( @-> ) = F.( @-> )
    let returning = F.returning
  end

  (* Library init*)
  let libzfs_init = foreign "libzfs_init" C.(void @-> returning Libzfs_handle.t)

  let libfzs_close =
    foreign "libzfs_fini" C.(Libzfs_handle.t @-> returning void)

  (* Handle functions *)
  let zfs_open =
    foreign "zfs_open"
      C.(Libzfs_handle.t @-> string @-> int @-> returning Zfs_handle.t)

  let zfs_close = foreign "zfs_close" C.(Zfs_handle.t @-> returning void)

  let zfs_get_name =
    foreign "zfs_get_name" C.(Zfs_handle.t @-> returning string)

  (* Zpool functions*)

  let zpool_open =
    foreign "zpool_open"
      C.(Libzfs_handle.t @-> string @-> returning Zpool_handle.t)

  let zpool_close = foreign "zpool_close" C.(Zpool_handle.t @-> returning void)

  let zpool_iter =
    foreign "zpool_iter"
      C.(Libzfs_handle.t @-> zpool_iter_f @-> ptr void @-> returning int)

  let zpool_name =
    foreign "zpool_get_name" C.(Zpool_handle.t @-> returning string)

  (* Iterator functions*)
  let zfs_iter_root =
    foreign "zfs_iter_root"
      C.(Libzfs_handle.t @-> zfs_iter_f @-> ptr void @-> returning int)

  let zfs_iter_filesystems =
    foreign "zfs_iter_children"
      C.(Zfs_handle.t @-> zfs_iter_f @-> ptr void @-> returning int)

  (* ZFS version functions *)
  let zfs_version =
    foreign "zfs_version_userland" C.(void @-> returning (const string))

  let zfs_kernel_version =
    foreign "zfs_version_kernel" C.(void @-> returning string)

  (* Error handling *)
  let zfs_error_init = foreign "libzfs_error_init" C.(int @-> returning string)

  let zfs_error_description =
    foreign "libzfs_error_description" C.(Libzfs_handle.t @-> returning string)

  let zfs_error_action =
    foreign "libzfs_error_action" C.(Libzfs_handle.t @-> returning string_opt)

  let zfs_errno = foreign "libzfs_errno" C.(Libzfs_handle.t @-> returning int)

  (* ZFS dataset functions *)
  let zfs_create =
    foreign "zfs_create"
      C.(Libzfs_handle.t @-> string @-> int @-> ptr nvlist_t @-> returning int)

  let zfs_destroy =
    foreign "zfs_destroy" C.(Zfs_handle.t @-> bool @-> returning int)

  let zfs_all_properties =
    foreign "zfs_get_all_props" C.(Zfs_handle.t @-> returning (ptr nvlist_t))
end
