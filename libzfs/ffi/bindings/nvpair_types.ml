open Ctypes

(* module Nvpair = struct
  type nvp
  type t = nvp structure

  let t : t typ = structure "nvpair"
  let size t = field t "nvp_size" int
  let () =  seal t
end *)

let id x = x

module Nvlist = struct
  type nvl
  type t = nvl structure

  let struct_nvl: nvl structure typ = structure "nvlist"

  let ( -: ) ty label = field struct_nvl label ty
  let nvl_version = uint32_t -: "nvl_version"

  (* let t : t typ = structure "nvlist" *)
  (* let version t = field t "nvl_version" int32_t
  let nvflag t = field t "nvl_nvflag" uint32_t
  let priv t = field t "nvl_priv" uint64_t
  let flag t = field t "nvl_flag" uint32_t
  let pad t = field t "nvl_pad" int32_t *)
  let () = seal struct_nvl
  let nvl = view struct_nvl ~read:id ~write:id ~format_typ:(fun k fmt -> Format.pp_print_string fmt "nvlist"; k fmt)

  let t = nvl
end

type boolean_t = bool typ

let boolean_t : bool typ = bool
(* let unique_name = constant "NV_UNIQUE_NAME" int *)
