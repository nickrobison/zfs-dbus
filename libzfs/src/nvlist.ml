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

let add_int t k v =
  let _ = handle_add (F.nvlist_add_int t) k v in
  t

let add_nvpair t _k _v = t

let get_string t k =
  let v = allocate string "" in
  handle_lookup F.nvlist_lookup_string t k v

let get_bool t k =
  let v = allocate bool false in
  handle_lookup F.nvlist_lookup_bool t k v

let get_int t k =
  let v = allocate int 0 in
  handle_lookup F.nvlist_lookup_int t k v

let encode_nvpair nvlist key (nvp_value : Nvpair.typ) =
  match nvp_value with
  | String s -> add_string nvlist key s
  | Bool b -> add_bool nvlist key b
  | Int32 i -> add_int nvlist key i

let t_of_pairs pairs =
  let ls = empty () in
  List.fold_left (fun vlist (k, v) -> encode_nvpair vlist k v) ls pairs

let iter_pairs t fn =
  let nvp_a = addr (F.make_nvpair ()) in
  let nvp = ref nvp_a in
  nvp := F.nvlist_next t (from_voidp F.nvpair_t null);
  let rec iter t acc =
    if Ctypes.is_null !nvp then acc
    else
      let n = !nvp in
      let vv = fn n in
      let acc = vv :: acc in
      nvp := F.nvlist_next t !nvp;
      iter t acc
  in
  iter t []

let keys t = iter_pairs t (fun nvpair -> F.nvpair_name nvpair)
let pairs_of_t t = iter_pairs t (fun nvpair -> Nvpair.t_of_nvpair_t !@nvpair)
