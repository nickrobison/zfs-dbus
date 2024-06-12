type t = { action : string option; description : string; code : int }

let create code description action = { code; action; description }
let action t = t.action
let description t = t.description
let code t = t.code
