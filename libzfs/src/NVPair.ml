(* open Ctypes *)
module C = Ctypes
module F = Libzfs_ffi.M

module rec NVPair : sig
  type typ =
    | Bool of bool
    | String of string
    | Int32 of int
    | Nvlist of NVlist.t
  (* | Byte of bytes
     | Int8 of int
     | Int16 of int
     | Double of float
     | BoolArray of bool list
     | StringArray of string list
     | NVPair of t
     | NVPairArray of t list *)

  and t = string * typ [@@deriving eq]

  val t_of_nvpair_t : F.nvpair_t -> t
  val pp : t Fmt.t
  val assoc : t -> string * string
end = struct
  type typ =
    | Bool of bool
    | String of string
    | Int32 of int
    | Nvlist of NVlist.t
  [@@deriving show]
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
        let str = allocate string "" in
        let _ = F.nvpair_string nvpair str in
        String !@str
    | `Int32 ->
        let i = allocate int 0 in
        let _ = F.nvpair_int nvpair i in
        Int32 !@i
        (* | `NVList l ->
           let l = allocate M.nvlist_t (from_voidp null) in *)
    | _ -> unsupported_type dtype

  let t_of_nvpair_t (nvpair : F.nvpair_t) =
    let nvpair = C.addr nvpair in
    let name = F.nvpair_name nvpair and dtype = F.nvpair_type nvpair in
    let typ : typ = typ_of_value nvpair dtype in
    (name, typ)

  let pp ppf t = Fmt.pf ppf "(%s: %a)" (fst t) pp_typ (snd t)

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
  let of_pairs pairs = M.of_list pairs

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

  let keys t = M.bindings t |> List.map fst
  let pairs t = M.bindings t

  let decode nvlist =
    let pairs =
      iter_pairs nvlist (fun nvpair -> NVPair.t_of_nvpair_t !@nvpair)
    in
    List.fold_left (fun m p -> M.add (fst p) (snd p) m) M.empty pairs

  let encode _ = raise (Unsupported "bad")
  let equal l r = M.equal NVPair.equal_typ l r
  let pp ppf t = Fmt.pf ppf "%a" (Fmt.list NVPair.pp) (M.bindings t)
  let show _t = ""
end
