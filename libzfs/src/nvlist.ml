open Ctypes
module F = Libzfs_ffi.M

type t = F.Nvlist.t ptr
type 'a setter = t -> string -> 'a -> t
type 'a getter = t -> string -> 'a option

let empty () =
  let ls = allocate (ptr F.Nvlist.t) (from_voidp F.Nvlist.t null) in
  (* Fixme:: Constant? *)
  match F.nvlist_alloc ls 1 0 with
  | 0 ->
      let handle = !@ls in
      Gc.finalise (fun v -> F.nvlist_free v) handle;
      handle
  | _ -> raise (Invalid_argument "bad")

let handle_add f k v =
  (* Handle errors here *)
  let _ = f k v in
  ()

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

let get_string _t _k = None

let get_bool t k =
  let v = allocate bool false in
  let _ = F.nvlist_lookup_bool t k v in
  Some !@v
