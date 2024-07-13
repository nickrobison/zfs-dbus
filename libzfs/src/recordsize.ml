type t = int64 [@@deriving eq, show]

let name = "recordsize"
let of_int = Int64.of_int

let get_value l =
  let open NVPair in
  match NVlist.get_nvpair l "value" with
  | None -> None
  | Some p -> (
      match snd p with
      | Uint64 i -> Unsigned.UInt64.to_int64 i |> Option.some
      | _ -> None)

let of_nvpair p =
  let open NVPair in
  match snd p with NVPair.Nvlist l -> get_value l | _ -> None

let to_nvpair t = (name, NVPair.NVPair.Uint64 (Unsigned.UInt64.of_int64 t))

let of_property p =
  match (Zfs_property.name p, Zfs_property.value p) with
  | n, NVPair.NVPair.Uint64 i when name = n -> Some (Unsigned.UInt64.to_int64 i)
  | _ -> None

let key =
  Property_key.create name Fmt.int64 of_nvpair to_nvpair of_property
  |> Property_map.Key.create
