open Ctypes
module M = Libzfs_ffi.M

type t
type 'a setter = t -> string -> 'a -> t
type 'a getter = t -> string -> 'a option

val empty : unit -> t
val size : t -> int
val add_string : string setter
val add_bool : bool setter

(* val add_nvpair : Nvpair.t setter *)
val add_int : int setter
val get_string : string getter
val get_bool : bool getter
val get_int : int getter
val keys : t -> string list
val t_of_pairs : NV.NVP.t list -> t
val pairs_of_t : t -> NV.NVP.t list
val t_of_nvlist_t : M.nvlist_t ptr -> t
val equal : t -> t -> bool
