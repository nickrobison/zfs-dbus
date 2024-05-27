type t

val version : unit -> Version.t

val init: unit -> t

val pools: t -> Zpool.t list