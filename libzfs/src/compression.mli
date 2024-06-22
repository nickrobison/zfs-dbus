type c =
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

val key : c Property_map.key

(* module Key: Property_key.K with type 'a t = c *)
