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
[@@deriving show]

let key = Property_key.create "compression" pp_c |> Property_map.Key.create
