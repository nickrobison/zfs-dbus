type t

val create : int -> string -> string option -> t
val action : t -> string option
val description : t -> string
val code : t -> int
