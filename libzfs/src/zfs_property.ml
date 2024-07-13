module Source = struct
  type t = string

  let of_string s = s
  let to_string t = t
end

type t = { name : string; source : Source.t option; value : NVPair.NVPair.typ }

let source t = t.source
let name t = t.name
let value t = t.value

let of_nvpair nvpair =
  let open NVPair in
  let name = fst nvpair in
  Fmt.(pr "\nName: %s. Value:%a\n" name NVPair.pp_typ (snd nvpair));
  print_endline name;
  match snd nvpair with
  | NVPair.Nvlist l -> (
      let source =
        NVlist.get_string l "source" |> Option.map Source.of_string
      in
      match NVlist.get_nvpair l "value" with
      | Some value -> Some { name; source; value = snd value }
      | None -> None)
  | _ -> None
