open Ctypes

module Types (F : Ctypes.TYPE) = struct
  open F

  module Nvpair = struct
    type nvp
    type t = nvp structure

    let t : t typ = structure "nvpair"
    let size t = field t "nvp_size" int
    let () = seal t
  end

  module Nvlist = struct
    type nvl
    type t = nvl structure

    let t : t typ = structure "nvlist"
    let version t = field t "nvl_version" int
    let flag t = field t "nvl_nvflag" int
    let () = seal t
  end

  type boolean_t = bool typ

  let boolean_t : bool typ = bool
  let unique_name = constant "NV_UNIQUE_NAME" int
end
