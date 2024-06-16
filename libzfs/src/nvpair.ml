module M = Libzfs_ffi.M
open Ctypes

type typ = Bool of bool | String of string | Int32 of int | Nvlist of NV.NVL.t
(* | Byte of bytes
   | Int8 of int
   | Int16 of int
   | Double of float
   | BoolArray of bool list
   | StringArray of string list
   | NVPair of t
   | NVPairArray of t list *)

and t = string * typ [@@deriving eq]

(* let unsuported_type d =
   raise
     (Invalid_argument
        (Format.sprintf "Unsupported type: %s" (M.show_data_type_t d))) *)

let unsupported_type _ = raise (Invalid_argument "bad")

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
      (* | `NVList l ->
         let l = allocate M.nvlist_t (from_voidp null) in *)
  | e -> unsupported_type e

let t_of_nvpair_t (nvpair : M.nvpair_t) =
  let nvpair = addr nvpair in
  let name = M.nvpair_name nvpair and dtype = M.nvpair_type nvpair in
  let typ : typ = typ_of_value nvpair dtype in
  (name, typ)

(* let pp ppf t = Fmt.pf ppf "(%s: %a)" (fst t) pp_typ (snd t) *)
let pp ppf t = Fmt.pf ppf "(%s)" (fst t)

let assoc t =
  let k = fst t in
  (* let k = fst t and v = show_typ (snd t) in *)
  (k, "noppe")
