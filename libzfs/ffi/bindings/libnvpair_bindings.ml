module M (F : Ctypes.FOREIGN) = struct
  module T = Libzfs_types.M
  include T
  (* include Nvpair_types *)

  let foreign = F.foreign

  module C = struct
    include Ctypes

    let ( @-> ) = F.( @-> )
    let returning = F.returning
  end

  open C

  let nvlist_alloc =
    foreign "nvlist_alloc"
      (ptr (ptr T.nvlist_t) @-> int @-> int @-> returning int)

  let nvlist_free = foreign "nvlist_free" (ptr T.nvlist_t @-> returning void)

  let nvlist_size =
    foreign "nvlist_size"
      (ptr T.nvlist_t @-> ptr PosixTypes.size_t @-> int @-> returning int)

  let nvlist_add_string =
    foreign "nvlist_add_string"
      (ptr T.nvlist_t @-> string @-> string @-> returning int)

  let nvlist_add_bool =
    foreign "nvlist_add_boolean_value"
      (ptr T.nvlist_t @-> string @-> bool @-> returning int)

  let nvlist_lookup_bool =
    foreign "nvlist_lookup_boolean_value"
      (ptr T.nvlist_t @-> string @-> ptr bool @-> returning int)

  let nvlist_lookup_string =
    foreign "nvlist_lookup_string"
      (ptr T.nvlist_t @-> string @-> ptr string @-> returning int)
end
