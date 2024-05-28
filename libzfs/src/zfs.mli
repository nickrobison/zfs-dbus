type t

val version : unit -> Version.t
val init : unit -> t
val pools : t -> Zpool.t list
val get_pool: t -> string -> Zpool.t
val datasets: t -> Dataset.t list