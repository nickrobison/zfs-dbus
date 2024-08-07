(* open Ctypes *)
module C = Ctypes
module F = Libzfs_ffi.M
module U = Unsigned

module rec NVPair : sig
  type typ =
    | Bool of bool
    | String of string
    | Int32 of int
    | Uint64 of U.UInt64.t
    | Nvlist of NVlist.t
  [@@deriving show, eq]
  (* | Byte of bytes
     | Int8 of int
     | Int16 of int
     | Double of float
     | BoolArray of bool list
     | StringArray of string list
     | NVPair of t
     | NVPairArray of t list *)

  and t = string * typ [@@deriving show, eq]

  val t_of_nvpair_t : F.nvpair_t -> t
  val assoc : t -> string * string
end = struct
  type typ =
    | Bool of bool
    | String of string
    | Int32 of int
    | Uint64 of U.UInt64.t
    | Nvlist of NVlist.t
  [@@deriving eq]
  (* | Byte of bytes
     | Int8 of int
     | Int16 of int
     | Double of float
     | BoolArray of bool list
     | StringArray of string list
     | NVPair of t
     | NVPairArray of t list *)

  and t = string * typ [@@deriving eq]

  let unsupported_type d =
    raise
      (Invalid_argument
         (Format.sprintf "Unsupported type: %s" (F.show_data_type_t d)))

  let typ_of_value nvpair dtype =
    let open C in
    match dtype with
    | `String ->
        let str = allocate_n string ~count:1 in
        let _ = F.nvpair_string nvpair str in
        String !@str
    | `Int32 ->
        let i = allocate_n int ~count:1 in
        let _ = F.nvpair_int nvpair i in
        Int32 !@i
    | `Uint64 -> Uint64 (F.fnvpair_uint64 nvpair)
    | `NVList ->
        let nvl = F.fnvpair_nvlist nvpair in
        Nvlist (NVlist.decode nvl)
    | _ -> unsupported_type dtype

  let t_of_nvpair_t (nvpair : F.nvpair_t) =
    let nvpair = C.addr nvpair in
    let name = F.nvpair_name nvpair and dtype = F.nvpair_type nvpair in
    let typ : typ = typ_of_value nvpair dtype in
    (name, typ)

  let pp_typ ppf (dtype : typ) =
    match dtype with
    | String s -> Fmt.string ppf s
    | Int32 i -> Fmt.int ppf i
    | Bool b -> Fmt.bool ppf b
    | Nvlist l -> NVlist.pp ppf l
    | Uint64 l -> U.UInt64.pp ppf l

  let show_typ dtype = Fmt.to_to_string pp_typ dtype
  let pp ppf t = Fmt.pf ppf "(%s: %a)" (fst t) pp_typ (snd t)
  let show t = Fmt.to_to_string pp t

  let assoc t =
    let k = fst t in
    (k, "noppe")
end

and NVlist : sig
  type t
  type 'a setter = t -> string -> 'a -> t
  type 'a getter = t -> string -> 'a option

  val empty : unit -> t
  val size : t -> int
  val add_string : string setter
  val add_bool : bool setter
  val add_nvpair : NVPair.t setter
  val encode : t -> F.nvlist_t C.ptr
  val decode : F.nvlist_t C.ptr -> t
  val add_int : int setter
  val get_string : string getter
  val get_bool : bool getter
  val get_int : int getter
  val get_nvpair : NVPair.t getter
  val keys : t -> string list
  val of_pairs : NVPair.t list -> t
  val pairs : t -> NVPair.t list
  val equal : t -> t -> bool
  val pp : t Fmt.t
  val show : t -> string
end = struct
  open C
  module M = Map.Make (String)

  type t = NVPair.typ M.t
  type 'a setter = t -> string -> 'a -> t
  type 'a getter = t -> string -> 'a option

  let empty () = M.empty
  let size t = M.cardinal t
  let add_string t k v = M.add k (NVPair.String v) t
  let add_bool t k v = M.add k (NVPair.Bool v) t
  let add_int t k v = M.add k (NVPair.Int32 v) t
  let add_nvpair t k v = M.add k (snd v) t

  let get_string k t =
    M.find_opt t k
    |> Option.map (fun v ->
           match v with NVPair.String s -> Some s | _ -> None)
    |> Option.join

  let get_bool k t =
    M.find_opt t k
    |> Option.map (fun v -> match v with NVPair.Bool b -> Some b | _ -> None)
    |> Option.join

  let get_int k t =
    M.find_opt t k
    |> Option.map (fun v -> match v with NVPair.Int32 i -> Some i | _ -> None)
    |> Option.join

  let get_nvpair k t = M.find_opt t k |> Option.map (fun v -> (t, v))
  let of_pairs pairs = List.to_seq pairs |> M.of_seq

  let iter_pairs t fn =
    let rec iter p acc =
      if Ctypes.is_null p then acc
      else
        let vv = fn p in
        let acc = vv :: acc in
        iter (F.nvlist_next t p) acc
    in
    iter (F.nvlist_next t (from_voidp F.nvpair_t null)) []

  let keys t = M.bindings t |> List.map fst
  let pairs t = M.bindings t

  let decode nvlist =
    let pairs =
      iter_pairs nvlist (fun nvpair -> NVPair.t_of_nvpair_t !@nvpair)
    in
    List.fold_left (fun m p -> M.add (fst p) (snd p) m) M.empty pairs

  let rec encode_pair nvl (pair : NVPair.t) =
    let name, dtype = pair in
    match dtype with
    | Bool b -> F.fnvlist_add_bool nvl name b
    | String s -> F.fnvlist_add_string nvl name s
    | Int32 i -> F.fnvlist_add_int32 nvl name (Int32.of_int i)
    | Uint64 i -> F.fnvlist_add_uint64 nvl name i
    | Nvlist l ->
        let pairs = NVlist.pairs l in
        F.fnvlist_add_nvlist nvl name (encode_nvlist pairs)

  and encode_nvlist pairs =
    let nvlist = allocate_n F.(ptr nvlist_t) ~count:1 in
    let _ = F.nvlist_alloc nvlist F.unique_name 0 in
    let encode_pair = encode_pair !@nvlist in
    List.iter encode_pair pairs;
    !@nvlist

  let encode t = encode_nvlist (pairs t)
  let equal l r = M.equal NVPair.equal_typ l r
  let pp ppf t = Fmt.pf ppf "%a" (Fmt.list NVPair.pp) (M.bindings t)
  let show t = Fmt.to_to_string pp t
end
