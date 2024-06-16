module M = Libzfs_ffi.M

type t

val name : t -> string
val of_handle : M.Zfs_handle.t -> t
val destroy : t -> ?force:bool -> unit -> unit
val dump_properties : t -> (string * string) list
