type t
type 'a setter = t -> string -> 'a -> t
type 'a getter = t -> string -> 'a option

val empty : unit -> t
val size : t -> int
val add_string : string setter
val add_bool : bool setter
val add_nvpair : Nvpair.t setter
val add_int : int setter
val get_string : string getter
val get_bool : bool getter
val get_int : int getter
val encode : Nvpair.t list -> t
val keys: t -> string list
(* val pairs_of_t: t -> Nvpair.t list *)
