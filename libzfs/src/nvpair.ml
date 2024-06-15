module M = Libzfs_ffi.M
open Ctypes

type typ = Bool of bool | String of string | Int32 of int [@@deriving show]
(* | Byte of bytes
   | Int8 of int
   | Int16 of int
   | Double of float
   | BoolArray of bool list
   | StringArray of string list
   | NVPair of t
   | NVPairArray of t list *)

and t = string * typ [@@deriving eq]

let typ_of_value nvpair dtype =
  match dtype with
  | `String ->
      let str = allocate string "" in
      let _ = M.nvpair_string nvpair str in
      String !@str
  | `Int32 ->
      let i = allocate int 0 in
      let _ = M.nvpair_int nvpair i in
      Int32 !@i
  | _ -> raise (Invalid_argument "Bad type")

let t_of_nvpair_t (nvpair : M.nvpair_t) =
  let nvpair = addr nvpair in
  let name = M.nvpair_name nvpair and dtype = M.nvpair_type nvpair in
  let typ : typ = typ_of_value nvpair dtype in
  (name, typ)

let pp ppf t = Fmt.pf ppf "(%s: %a)" (fst t) pp_typ (snd t)
