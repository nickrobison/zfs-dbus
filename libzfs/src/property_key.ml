type 'a t = { name : string; pp_v : 'a Fmt.t }

let name t = t.name
let pp ppf t = Fmt.string ppf t.name
let pp_v t = t.pp_v
let create name pp_v = { name; pp_v }
