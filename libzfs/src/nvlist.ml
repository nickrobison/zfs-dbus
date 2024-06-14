open Ctypes
module F = Libzfs_ffi.M

type t = F.nvlist_t ptr
type 'a setter = t -> string -> 'a -> t
type 'a getter = t -> string -> 'a option

let empty () =
  let ls = allocate (ptr F.nvlist_t) (from_voidp F.nvlist_t null) in
  match F.nvlist_alloc ls F.unique_name 0 with
  | 0 ->
      let handle = !@ls in
      Gc.finalise (fun v -> F.nvlist_free v) handle;
      handle
  | _ -> raise (Invalid_argument "bad")

let handle_add f k v =
  (* Handle errors here *)
  let _ = f k v in
  ()

let handle_lookup f t k v = match f t k v with 0 -> Some !@v | _ -> None

let size t =
  let open Unsigned in
  let sz = allocate PosixTypes.size_t (Size_t.of_int 0) in
  let _ = F.nvlist_size t sz 0 in
  Size_t.to_int !@sz

let add_string t k v =
  let _ = handle_add (F.nvlist_add_string t) k v in
  t

let add_bool t k v =
  let _ = handle_add (F.nvlist_add_bool t) k v in
  t

let add_nvpair t _k _v = t

let get_string t k =
  let v = allocate string "" in
  handle_lookup F.nvlist_lookup_string t k v

let get_bool t k =
  let v = allocate bool false in
  handle_lookup F.nvlist_lookup_bool t k v
