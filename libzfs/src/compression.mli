type t =
  | Inherit
  | On
  | Off
  | LZJB
  | Empty
  | Gzip of int
  | Zstd of int
  | ZLE
  | LZ4
  | Function
[@@deriving show, eq]

val of_int : int -> t
val key : t Property_map.key
