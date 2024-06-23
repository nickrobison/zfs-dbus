type 'a t = {
  name : string;
  pp_v : 'a Fmt.t;
  of_nvpair : NVPair.NVPair.t -> 'a option;
}

let name t = t.name
let pp ppf t = Fmt.string ppf t.name
let pp_v t = t.pp_v
let create name pp_v of_nvpair = { name; pp_v; of_nvpair }
let of_nvpair p t = t.of_nvpair p
