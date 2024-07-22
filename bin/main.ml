open Lwt.Syntax

(* Setup logging *)
let setup_log () =
  Logs.set_level (Some Logs.Info);
  Logs.set_reporter (Logs_fmt.reporter ());
  ()

let () =
  Lwt_main.run
    (setup_log ();
     let* bus = OBus_bus.session () in
     Zfs_dbus.start "world" bus)
