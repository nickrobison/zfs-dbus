module M = Libzfs_ffi.M

type t = { handle : M.Zfs_handle.t; name : string; props : Property_map.t }

module Builder = struct
  type t = {
    name : string;
    compression : Compression.t option;
    recordsize : Recordsize.t option;
  }

  let create name = { name; compression = None; recordsize = None }
  let name t = t.name
  let id x = x
  let compression t = Option.fold ~none:Compression.Off ~some:id t.compression
  let recordsize t = t.recordsize
  let with_compression c t = { t with compression = Some c }
  let with_recordsize r t = { t with recordsize = Some r }

  let to_nvlist t =
    let module L = NVPair.NVlist in
    let l = L.empty () in
    let c = compression t in
    let ck = Property_map.Key.info Compression.key in
    let c_pair = Property_key.to_nvpair c ck in
    let r = recordsize t in
    let rk = Property_map.Key.info Recordsize.key in
    let l = L.add_nvpair l "compression" c_pair in
    Option.fold ~none:l
      ~some:(fun r ->
        let r_pair = Property_key.to_nvpair r rk in
        L.add_nvpair l "recordsize" r_pair)
      r
end

let name t = t.name

let extract_key properties k pm =
  let k2 = Property_map.Key.info k in
  let module L = NVPair.NVlist in
  let name = Property_key.name k2 in
  let prop = List.find_opt (fun p -> Zfs_property.name p = name) properties in
  match prop with
  | None -> pm
  | Some v ->
      let vv = Property_key.of_property v k2 |> Option.get in
      Property_map.add k vv pm

let get_props handle =
  let open NVPair in
  let props = M.zfs_all_properties handle |> NVlist.decode |> NVlist.pairs in
  Fmt.(pr "%a" (list NVPair.pp) props);
  List.fold_left
    (fun acc p ->
      match Zfs_property.of_nvpair p with Some p -> p :: acc | None -> acc)
    [] props

let build_properties handle =
  let module L = NVPair.NVlist in
  let properties = get_props handle in
  let props =
    Property_map.empty
    |> extract_key properties Compression.key
    |> extract_key properties Recordsize.key
  in
  props

let of_handle handle =
  Gc.finalise (fun h -> M.zfs_close h) handle;
  let name = M.zfs_get_name handle in
  let props = build_properties handle in
  { handle; name; props }

let destroy ?(force = false) t =
  match M.zfs_destroy t.handle force with
  | 0 -> Ok ()
  | _ ->
      let code = M.zfs_errno t.handle in
      let action = M.zfs_error_action t.handle in
      let description = M.zfs_error_description t.handle in
      Zfs_exception.create code description action |> Result.error

let dump_properties t =
  let open NVPair in
  let properties = get_props t.handle in
  List.map
    (fun p ->
      let p_value = NVPair.show_typ (Zfs_property.value p) in
      (Zfs_property.name p, p_value))
    properties

let identity x = x

let compression t =
  Property_map.find Compression.key t.props
  |> Option.fold ~none:Compression.Empty ~some:identity

let recordsize t = Property_map.get Recordsize.key t.props
