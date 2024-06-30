module M = Libzfs_ffi.M

(** {2:builder Builder} *)

module Builder : sig
  type t

  val create: string -> t

  val with_compression : Compression.t -> t -> t
  val name: t -> string
  val compression: t -> Compression.t
  val to_nvlist: t -> NVPair.NVlist.t
end

type t

val name : t -> string
val of_handle : M.Zfs_handle.t -> t
val destroy : t -> ?force:bool -> unit -> unit
val dump_properties : t -> (string * string) list

(** {2:properties Properties} *)

val compression : t -> Compression.t
