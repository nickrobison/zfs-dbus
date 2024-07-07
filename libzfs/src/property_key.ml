type 'a t = {
  name : string;
  pp_v : 'a Fmt.t;
  of_nvpair : NVPair.NVPair.t -> 'a option;
  to_nvpair : 'a -> NVPair.NVPair.t;
}

let name t = t.name
let pp ppf t = Fmt.string ppf t.name
let pp_v t = t.pp_v
let create name pp_v of_nvpair to_nvpair = { name; pp_v; of_nvpair; to_nvpair }
let of_nvpair p t = t.of_nvpair p
let to_nvpair p t = t.to_nvpair p
