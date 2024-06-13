type t
type 'a setter = t -> string -> 'a -> t
type 'a getter = t -> string -> 'a option

val empty : unit -> t
val size : t -> int
val add_string : string setter
val add_bool : bool setter
val get_string : string getter
val get_bool : bool getter