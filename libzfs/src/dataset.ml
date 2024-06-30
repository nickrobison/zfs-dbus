module M = Libzfs_ffi.M

type t = { handle : M.Zfs_handle.t; name : string; props : Property_map.t }

module Builder = struct
  type t = {
    name: string;
    compression: Compression.t option;
  }

  let create name = {
    name;
    compression = None;
  }

  let name t = t.name

  let id x = x
  let compression t = Option.fold ~none:Compression.Off ~some:id t.compression

  let with_compression c t = {t with compression = Some c}

  let to_nvlist _t = 
    let module L = NVPair.NVlist in
    let l = L.empty () in 
    L.add_nvpair l "compression" ("", (NVPair.NVPair.Uint64 (Unsigned.UInt64.of_int 4)))

    

end


let name t = t.name

let extract_key nvlist k pm =
  Format.printf "From list: %a\n" NVPair.NVlist.pp nvlist;
  let k2 = Property_map.Key.info k in
  let module L = NVPair.NVlist in
  let name = Property_key.name k2 in
  match L.get_nvpair nvlist name with
  | None -> pm
  | Some v ->
      let vv = Property_key.of_nvpair v k2 |> Option.get in
      Property_map.add k vv pm

let get_props handle =
  let open NVPair in
  M.zfs_all_properties handle |> NVlist.decode

let build_properties handle =
  let module L = NVPair.NVlist in
  let nvlist = get_props handle in
  let ek = extract_key nvlist in
  let props = Property_map.empty |> ek Compression.key in
  props

let of_handle handle =
  Gc.finalise (fun h -> M.zfs_close h) handle;
  let name = M.zfs_get_name handle in
  let props = build_properties handle in
  { handle; name; props }


let destroy t ?(force = false) () =
  match M.zfs_destroy t.handle force with
  | 0 -> ()
  | _ -> raise (Invalid_argument "Bad")

let dump_properties t =
  let open NVPair in
  let nvlist = get_props t.handle in
  List.map
    (fun p ->
      let d = Fmt.to_to_string NVPair.pp_typ (snd p) in
      (fst p, d))
    (NVlist.pairs nvlist)

(* let open NVPair in
   let nvlist = properties handle |> NVlist.decode in
   let ek = extract_key *)

let identity x = x

let compression t =
  Property_map.find Compression.key t.props
  |> Option.fold ~none:Compression.Empty ~some:identity
