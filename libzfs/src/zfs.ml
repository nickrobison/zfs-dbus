open Ctypes
module M = Libzfs_ffi.M

type t = M.Libzfs_handle.t

let version () : Version.t =
  let kernel_version = M.zfs_kernel_version () in
  let version = M.zfs_version () in
  { version; kernel_version }

let init () =
  let handle = M.libzfs_init () in
  Gc.finalise (fun v -> M.libfzs_close v) handle;
  handle

let last_error t =
  let code = M.zfs_errno t in
  let ii = M.zfs_error_init code in
  let action = M.zfs_error_action t in
  let description = M.zfs_error_description t in
  print_endline ii;
  Zfs_exception.create code description action |> Option.some

let handle_err t p f =
  let err = if is_null p then last_error t else None in
  match err with Some e -> Error e | None -> Ok (f p)

let pools t =
  let pool_ref = ref [] in
  let handler pool _ =
    let p = Zpool.of_handle t pool in
    pool_ref := !pool_ref @ [ p ];
    0
  in
  let u = allocate int 1 in
  let _d = M.zpool_iter t handler (to_voidp u) in
  !pool_ref

let get_pool t name =
  let pool_handle = M.zpool_open t name in
  Some (Zpool.of_handle t pool_handle)

let get_dataset t name =
  let handle = M.zfs_open t name 1 in
  handle_err t handle Dataset.of_handle

let datasets t =
  let handler _h _ =
    print_endline "Something!!!!";
    0
  in
  let u = allocate int 1 in
  let _d = M.zfs_iter_root t handler (to_voidp u) in
  []

let create_dataset t ~name =
  let fs_int = M.int_of_dataset_type FILESYSTEM in
  match M.zfs_create t name fs_int null with
  | 0 ->
      let handle = M.zfs_open t name fs_int in
      Ok (Dataset.of_handle handle)
  | _ -> last_error t |> Option.get |> Result.error
