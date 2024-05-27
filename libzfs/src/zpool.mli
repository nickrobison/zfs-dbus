module M = Libzfs_ffi.M
type t

val of_handle: M.Zpool_handle.t -> t

val name: t -> string