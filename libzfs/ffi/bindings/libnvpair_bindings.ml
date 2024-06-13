module M (F : Ctypes.FOREIGN) = struct
  include Nvpair_types

  let foreign = F.foreign

  module C = struct
    include Ctypes

    let ( @-> ) = F.( @-> )
    let returning = F.returning
  end

  open C

  let nvlist_alloc =
    foreign "nvlist_alloc" (ptr (ptr Nvlist.t) @-> int @-> int @-> returning int)

  let nvlist_free = foreign "nvlist_free" (ptr Nvlist.t @-> returning void)

  let nvlist_size =
    foreign "nvlist_size"
      (ptr Nvlist.t @-> ptr PosixTypes.size_t @-> int @-> returning int)

  let nvlist_add_string =
    foreign "nvlist_add_string"
      (ptr Nvlist.t @-> string @-> string @-> returning int)

  let nvlist_add_bool =
    foreign "nvlist_add_boolean_value"
      (ptr Nvlist.t @-> string @-> bool @-> returning int)

  let nvlist_lookup_bool =
    foreign "nvlist_lookup_boolean_value"
      (ptr Nvlist.t @-> string @-> ptr bool @-> returning int)

  let nvlist_lookup_string =
    foreign "nvlist_lookup_string"
      (ptr Nvlist.t @-> string @-> ptr string @-> returning int)
end
