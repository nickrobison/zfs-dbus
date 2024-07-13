type 'a t

val name : 'a t -> string
val pp : 'a t Fmt.t
val pp_v : 'a t -> 'a Fmt.t

val create :
  string ->
  'a Fmt.t ->
  (NVPair.NVPair.t -> 'a option) ->
  ('a -> NVPair.NVPair.t) ->
  (Zfs_property.t -> 'a option) ->
  'a t

val of_nvpair : NVPair.NVPair.t -> 'a t -> 'a option
val to_nvpair : 'a -> 'a t -> NVPair.NVPair.t
val of_property : Zfs_property.t -> 'a t -> 'a option
