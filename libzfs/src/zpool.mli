module M = Libzfs_ffi.M

type t

val of_handle : M.Libzfs_handle.t -> M.Zpool_handle.t -> t
val name : t -> string
val root_dataset: t -> Dataset.t
val child_datasets: t -> Dataset.t list
val get_dataset: t -> string -> Dataset.t

