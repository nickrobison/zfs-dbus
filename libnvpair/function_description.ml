open Ctypes

module Types = Types_generated

module Functions(F: Ctypes.FOREIGN) = struct 
  open F

  let nvlist_alloc = foreign "nvlist_alloc" (ptr (ptr Types.Nvlist.t) @-> int @-> int @-> returning int)

end