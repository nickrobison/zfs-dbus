module F = Libzfs_ffi.M

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

let name = "compression"

let of_int = function
  | 0 -> Inherit
  | 1 -> On
  | 2 -> Off
  | 3 -> LZJB
  | 4 -> Empty
  | l when l >= 5 && l <= 13 -> Gzip (l - 4)
  | 14 -> ZLE
  | 15 -> LZ4
  | 16 -> Zstd 1
  | 17 -> Function
  | i -> raise (Invalid_argument (Format.sprintf "Bad compress type %d" i))

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

let to_nvpair t =
  let pp_c = function
    | Gzip l -> Format.sprintf "gzip-%d" l
    | Off -> "off"
    | On -> "on"
    | c ->
        raise
          (Invalid_argument (Format.sprintf "Bad compress type: %s" (show c)))
  in
  ("compression", NVPair.NVPair.String (pp_c t))

let of_property p =
  match (Zfs_property.name p, Zfs_property.value p) with
  | n, NVPair.NVPair.Uint64 i when n = name ->
      Unsigned.UInt64.to_int i |> of_int |> Option.some
  | _ -> None

let key =
  Property_key.create "compression" pp of_nvpair to_nvpair of_property
  |> Property_map.Key.create
