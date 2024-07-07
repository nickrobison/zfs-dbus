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

  let nvlist_add_int =
    foreign "nvlist_add_int32"
      (ptr T.nvlist_t @-> string @-> int @-> returning int)

  let nvlist_lookup_bool =
    foreign "nvlist_lookup_boolean_value"
      (ptr T.nvlist_t @-> string @-> ptr bool @-> returning int)

  let nvlist_lookup_string =
    foreign "nvlist_lookup_string"
      (ptr T.nvlist_t @-> string @-> ptr string @-> returning int)

  let nvlist_lookup_int =
    foreign "nvlist_lookup_int32"
      (ptr T.nvlist_t @-> string @-> ptr int @-> returning int)

  let nvlist_next =
    foreign "nvlist_next_nvpair"
      (ptr T.nvlist_t @-> ptr T.nvpair_t @-> returning (ptr T.nvpair_t))

  (* NVpair functions *)

  let nvpair_name = foreign "nvpair_name" (ptr T.nvpair_t @-> returning string)

  let nvpair_type =
    foreign "nvpair_type" (ptr T.nvpair_t @-> returning T.data_type_t)

  let nvpair_string =
    foreign "nvpair_value_string"
      (ptr T.nvpair_t @-> ptr string @-> returning int)

  let nvpair_bool_value =
    foreign "nvpair_value_boolean_value"
      (ptr T.nvpair_t @-> ptr bool @-> returning int)

  let nvpair_int =
    foreign "nvpair_value_int32" (ptr T.nvpair_t @-> ptr int @-> returning int)

  let nvpair_nvlist =
    foreign "nvpair_value_nvlist"
      (ptr T.nvpair_t @-> ptr (ptr T.nvlist_t) @-> returning int)

  let fnvpair_nvlist =
    foreign "fnvpair_value_nvlist"
      (ptr T.nvpair_t @-> returning (ptr T.nvlist_t))

  let fnvpair_uint64 =
    foreign "fnvpair_value_uint64" (ptr T.nvpair_t @-> returning uint64_t)

  (* FNVList functions *)

  let fnvlist_add_bool =
    foreign "fnvlist_add_boolean_value"
      (ptr T.nvlist_t @-> string @-> bool @-> returning void)

  let fnvlist_add_string =
    foreign "fnvlist_add_string"
      (ptr T.nvlist_t @-> string @-> string @-> returning void)

  let fnvlist_add_int32 =
    foreign "fnvlist_add_int32"
      (ptr T.nvlist_t @-> string @-> int32_t @-> returning void)

  let fnvlist_add_uint64 =
    foreign "fnvlist_add_uint64"
      (ptr T.nvlist_t @-> string @-> uint64_t @-> returning void)

  let fnvlist_add_nvlist =
    foreign "fnvlist_add_nvlist"
      (ptr T.nvlist_t @-> string @-> ptr T.nvlist_t @-> returning void)
end
