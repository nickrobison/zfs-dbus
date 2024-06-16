(* open Ctypes *)
module C = Ctypes
module M = Libzfs_ffi.M

module rec NVP : sig
  type typ = Bool of bool | String of string | Int32 of int | Nvlist of NVL.t
  (* | Byte of bytes
     | Int8 of int
     | Int16 of int
     | Double of float
     | BoolArray of bool list
     | StringArray of string list
     | NVPair of t
     | NVPairArray of t list *)

  and t = string * typ [@@deriving eq]

  val t_of_nvpair_t : M.nvpair_t -> t
  val pp : t Fmt.t
  val assoc : t -> string * string
end = struct
  type typ = Bool of bool | String of string | Int32 of int | Nvlist of NVL.t
  (* | Byte of bytes
     | Int8 of int
     | Int16 of int
     | Double of float
     | BoolArray of bool list
     | StringArray of string list
     | NVPair of t
     | NVPairArray of t list *)

  and t = string * typ [@@deriving eq]

  (* let unsuported_type d =
     raise
       (Invalid_argument
          (Format.sprintf "Unsupported type: %s" (M.show_data_type_t d))) *)

  let unsupported_type _ = raise (Invalid_argument "bad")

  let typ_of_value nvpair dtype =
    let open C in
    match dtype with
    | `String ->
        let str = allocate string "" in
        let _ = M.nvpair_string nvpair str in
        String !@str
    | `Int32 ->
        let i = allocate int 0 in
        let _ = M.nvpair_int nvpair i in
        Int32 !@i
        (* | `NVList l ->
           let l = allocate M.nvlist_t (from_voidp null) in *)
    | e -> unsupported_type e

  let t_of_nvpair_t (nvpair : M.nvpair_t) =
    let nvpair = C.addr nvpair in
    let name = M.nvpair_name nvpair and dtype = M.nvpair_type nvpair in
    let typ : typ = typ_of_value nvpair dtype in
    (name, typ)

  (* let pp ppf t = Fmt.pf ppf "(%s: %a)" (fst t) pp_typ (snd t) *)
  let pp ppf t = Fmt.pf ppf "(%s)" (fst t)

  let assoc t =
    let k = fst t in
    (* let k = fst t and v = show_typ (snd t) in *)
    (k, "noppe")
end

and NVL : sig
  type t
  type 'a setter = t -> string -> 'a -> t
  type 'a getter = t -> string -> 'a option

  val empty : unit -> t
  val size : t -> int
  val add_string : string setter
  val add_bool : bool setter

  (* val add_nvpair : Nvpair.t setter *)
  val add_int : int setter
  val get_string : string getter
  val get_bool : bool getter
  val get_int : int getter
  val keys : t -> string list
  val t_of_pairs : NVP.t list -> t
  val pairs_of_t : t -> NVP.t list
  val t_of_nvlist_t : M.nvlist_t C.ptr -> t
  val equal : t -> t -> bool
end = struct
  open C

  type t = M.nvlist_t C.ptr
  type 'a setter = t -> string -> 'a -> t
  type 'a getter = t -> string -> 'a option

  let empty () =
    let ls = allocate (ptr M.nvlist_t) (from_voidp M.nvlist_t null) in
    match M.nvlist_alloc ls M.unique_name 0 with
    | 0 ->
        let handle = !@ls in
        Gc.finalise (fun v -> M.nvlist_free v) handle;
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
    let _ = M.nvlist_size t sz 0 in
    Size_t.to_int !@sz

  let add_string t k v =
    let _ = handle_add (M.nvlist_add_string t) k v in
    t

  let add_bool t k v =
    let _ = handle_add (M.nvlist_add_bool t) k v in
    t

  let add_int t k v =
    let _ = handle_add (M.nvlist_add_int t) k v in
    t

  (* let add_nvpair t _k _v = t *)

  let get_string t k =
    let v = allocate string "" in
    handle_lookup M.nvlist_lookup_string t k v

  let get_bool t k =
    let v = allocate bool false in
    handle_lookup M.nvlist_lookup_bool t k v

  let get_int t k =
    let v = allocate int 0 in
    handle_lookup M.nvlist_lookup_int t k v

  let encode_nvpair nvlist key (nvp_value : NVP.typ) =
    match nvp_value with
    | String s -> add_string nvlist key s
    | Bool b -> add_bool nvlist key b
    | Int32 i -> add_int nvlist key i
    | _ -> raise (Invalid_argument "bad")

  let t_of_pairs pairs =
    let ls = empty () in
    List.fold_left (fun vlist (k, v) -> encode_nvpair vlist k v) ls pairs

  let iter_pairs t fn =
    let nvp_a = addr (M.make_nvpair ()) in
    let nvp = ref nvp_a in
    nvp := M.nvlist_next t (from_voidp M.nvpair_t null);
    let rec iter t acc =
      if Ctypes.is_null !nvp then acc
      else
        let n = !nvp in
        let vv = fn n in
        let acc = vv :: acc in
        nvp := M.nvlist_next t !nvp;
        iter t acc
    in
    iter t []

  let keys t = iter_pairs t (fun nvpair -> M.nvpair_name nvpair)
  let pairs_of_t t = iter_pairs t (fun nvpair -> NVP.t_of_nvpair_t !@nvpair)
  let t_of_nvlist_t handle = handle
  let equal _ _ = false
end
