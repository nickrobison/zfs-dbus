module M (F : Ctypes.TYPE) : sig
    type nvlist_t
  val nvlist_t : nvlist_t F.typ

  val unique_name: int F.const
end
