type 'a t

val name : 'a t -> string
val pp : 'a t Fmt.t
val pp_v : 'a t -> 'a Fmt.t
val create : string -> 'a Fmt.t -> (NVPair.NVPair.t -> 'a option) -> 'a t
val of_nvpair : NVPair.NVPair.t -> 'a t -> 'a option
