type t = { name : string; age : int; favorite : string option }
[@@deriving show, eq]

let t name age favorite = { name; age; favorite }
