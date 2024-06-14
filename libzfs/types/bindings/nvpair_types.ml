module M (F : Ctypes.TYPE) = struct
  open F

  type nvlist_t = unit
  let nvlist_t = void

  let unique_name = constant "NV_UNIQUE_NAME" int
end
