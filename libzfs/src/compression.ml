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

let key = Property_map.Key.create Inherit

(* module Key: Property_key.K with type 'a t = c = struct
     type 'a t = c
     let name = "compression"

   end *)
