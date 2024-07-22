
let src = Logs.Src.create "zdbus" ~doc:"ZDBus service"

module Log = (val Logs.src_log src: Logs.LOG)

let start msg = 
  Log.info (fun f ->f  "Hello %s" msg);