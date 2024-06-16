type t

val version : unit -> Version.t
val init : unit -> t
val pools : t -> Zpool.t list
val get_pool : t -> string -> Zpool.t option
val get_dataset : t -> string -> (Dataset.t, Zfs_exception.t) result
val datasets : t -> Dataset.t list
val create_dataset : t -> name:string -> (Dataset.t, Zfs_exception.t) result
