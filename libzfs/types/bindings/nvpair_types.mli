module C = Ctypes

type nvpair
type nvpair_t = nvpair C.structure

val nvpair_t : nvpair_t C.typ
val make_nvpair : unit -> nvpair_t

module M (F : Ctypes.TYPE) : sig
  type nvlist_t

  val nvlist_t : nvlist_t F.typ
  val unique_name : int F.const

  type data_type_t =
    [ `Dont_care
    | `Unknown
    | `Bool
    | `Byte
    | `Int16
    | `Uint16
    | `Int32
    | `Uint32
    | `Int64
    | `Uint64
    | `String
    | `Byte_array
    | `Int16_array
    | `Uint16_array
    | `Int32_array
    | `Uint32_array
    | `Int64_array
    | `Uint64_array
    | `String_array
    | `Hrtime
    | `NVList
    | `NVList_array
    | `Bool_value
    | `Int8
    | `Uint8
    | `Bool_array
    | `Int8_array
    | `Uint8_array
    | `Double
    | `E of string ]

  val data_type_t : data_type_t F.typ
  val show_data_type_t : data_type_t -> string
end
