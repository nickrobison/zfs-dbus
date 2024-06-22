open QCheck2

let printable_gen = Gen.(option string_printable)
let age_gen = Gen.(0 -- 1)

let simple_record =
  Gen.(Simple_record.t <$> string_printable <*> age_gen <*> printable_gen)
