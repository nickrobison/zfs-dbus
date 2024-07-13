module Source : sig
  type t

  val of_string : string -> t
  val to_string : t -> string
end

type t

val source : t -> Source.t option
val name : t -> string
val value : t -> NVPair.NVPair.typ
val of_nvpair : NVPair.NVPair.t -> t option
