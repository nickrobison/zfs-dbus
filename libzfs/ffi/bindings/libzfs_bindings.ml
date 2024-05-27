module M (F : Ctypes.FOREIGN) = struct
  let foreign = F.foreign
  let const x = x

  module C = struct
    include Ctypes

    let ( @-> ) = F.( @-> )
    let returning = F.returning
  end

  (* ZFS version functions *)
  let zfs_version =
    foreign "zfs_version_userland" C.(void @-> returning (const string))

  let zfs_kernel_version =
    foreign "zfs_version_kernel" C.(void @-> returning string)
end
