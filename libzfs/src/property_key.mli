type 'a t

val name : 'a t -> string
val pp : 'a t Fmt.t
val pp_v : 'a t -> 'a Fmt.t
val create : string -> 'a Fmt.t -> 'a t
