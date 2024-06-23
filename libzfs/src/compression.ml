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

let of_int = function
  | 0 -> Inherit
  | 1 -> On
  | 2 -> Off
  | _ -> raise (Invalid_argument "Bad compress type")

let get_value l =
  let open NVPair in
  match NVlist.get_nvpair l "value" with
  | None -> None
  | Some p -> (
      match snd p with
      | Uint64 i -> Unsigned.UInt64.to_int i |> of_int |> Option.some
      | _ -> None)

let of_nvpair p =
  let open NVPair in
  Format.printf "Pair: %a\n" NVPair.pp p;
  match snd p with NVPair.Nvlist l -> get_value l | _ -> None

let key =
  Property_key.create "compression" pp of_nvpair |> Property_map.Key.create
