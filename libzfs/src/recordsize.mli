type t [@@deriving show, eq]

val of_int : int -> t
val key : t Property_map.key
