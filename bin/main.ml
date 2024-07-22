
(* Setup logging *)
let setup_log () = 
  Logs.set_level (Some Logs.Info);
  Logs.set_reporter (Logs_fmt.reporter ());
  ()

let () = 
setup_log ();
Zfs_dbus.start "world"
