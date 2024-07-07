module C = Ctypes

module M (F : Ctypes.TYPE) : sig
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
  val size_data_type_t : data_type_t -> int

  type nvlist
  type nvlist_t = nvlist C.structure

  val nvlist_t : nvlist_t F.typ

  type nvpair
  type nvpair_t = nvpair C.structure

  val name : nvpair_t -> string
  val size : nvpair_t -> int
  val set_name : string -> nvpair_t -> unit
  val name_size : nvpair_t -> int
  val elements : nvpair_t -> int
  val set_elements : int -> nvpair_t -> unit
  (* val dtype: nvpair_t -> data_type_t
     val set_dtype: nvpair_t -> data_type_t -> nvpair_t *)

  val nvpair_t : nvpair_t C.typ

  type zio_compress =
    [ `Inherit
    | `On
    | `Off
    | `Lzjb
    | `Empty
    | `Gzip_1
    | `Gzip_2
    | `Gzip_3
    | `Gzip_4
    | `Gzip_5
    | `Gzip_6
    | `Gzip_7
    | `Gzip_8
    | `Gzip_9
    | `Zle
    | `LZ4
    | `Zstd
    | `Function
    | `E of string ]

  val zio_compress : zio_compress F.typ
end
