module M = Libzfs_ffi.M

type t = { handle : M.Zfs_handle.t; name : string }

let name t = t.name

let of_handle handle =
  Gc.finalise (fun h -> M.zfs_close h) handle;
  let name = M.zfs_get_name handle in
  { handle; name }

let destroy t ?(force = false) () =
  match M.zfs_destroy t.handle force with
  | 0 -> ()
  | _ -> raise (Invalid_argument "Bad")

let dump_properties t =
  let open NVPair in
  let nvlist = M.zfs_all_properties t.handle |> NVlist.decode in
  List.map
    (fun p ->
      let d = Fmt.to_to_string NVPair.pp_typ (snd p) in
      (fst p, d))
    (NVlist.pairs nvlist)
