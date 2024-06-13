open Ctypes

module Types = Nvpair_types

module M (F: Ctypes.FOREIGN) = struct
  open F

  let nvlist_alloc =
    foreign "nvlist_alloc"
      (ptr (ptr Types.Nvlist.t) @-> int @-> int @-> returning int)

  let nvlist_free = foreign "nvlist_free" (ptr Types.Nvlist.t @-> returning void)

  let nvlist_size =
    foreign "nvlist_size"
      (ptr Types.Nvlist.t @-> ptr PosixTypes.size_t @-> int @-> returning int)

  let nvlist_add_string =
    foreign "nvlist_add_string"
      (ptr Types.Nvlist.t @-> string @-> string @-> returning int)

  let nvlist_add_bool =
    foreign "nvlist_add_boolean_value"
      (ptr Types.Nvlist.t @-> string @-> bool @-> returning int)

  let nvlist_lookup_bool =
    foreign "nvlist_lookup_boolean_value"
      (ptr Types.Nvlist.t @-> string @-> ptr bool @-> returning int)

  let nvlist_lookup_string = 
    foreign "nvlist_lookup_string" (ptr Types.Nvlist.t @-> string @-> ptr string @-> returning int)
end