open Lwt.Syntax
module L = Libzfs

let src = Logs.Src.create "zdbus" ~doc:"ZDBus service"

module Log = (val Logs.src_log src : Logs.LOG)

let info msg = Log.info (fun f -> f "%s" msg)

let version _obj =
  let v = L.Zfs.version () in
  Lwt_react.S.const v.version

let path_of_pool pool =
  let name = L.Zpool.name pool in
  OBus_path.of_string ("/com/nickrobison/dbus/zfs1/pool/" ^ name)

let pools zfs _obj () =
  let pools = L.Zfs.pools zfs in
  Lwt.return (List.map path_of_pool pools)

let interface zfs =
  Zfs_interfaces.Com_nickrobison_dbus_ZFS1.make
    {
      Zfs_interfaces.Com_nickrobison_dbus_ZFS1.p_Version = version;
      Zfs_interfaces.Com_nickrobison_dbus_ZFS1.m_Pools = pools zfs;
    }

let zpool_handler zfs _ctx path =
  let path' = OBus_path.to_string path in
  let p' = String.sub path' 1 (String.length path' - 1) in
  Log.info (fun f -> f "Attempting to open pool: %s" p');

  let pool = L.Zfs.get_pool zfs p' |> Option.get in
  let obj = Zfs_pool.create pool in
  Log.info (fun f ->
      f "Finally created pool object with path %s"
        (OBus_object.path obj |> OBus_path.to_string));
  Lwt.return obj

let start msg bus =
  info msg;
  info "Initializing ZFS";
  let* bus_id = OBus_bus.get_id bus in
  Log.info (fun f -> f "Connecting to bus %s" (OBus_uuid.to_string bus_id));
  let zfs = L.Zfs.init () in
  (* Request the name. Handle error here *)
  let* _ = OBus_bus.request_name bus "com.nickrobison.dbus.zfs1" in
  let pth = OBus_path.of_string "/com/nickrobison/dbus/zfs1" in
  Log.info (fun f -> f "With path %s" (OBus_path.to_string pth));

  (* Create the object *)
  let obj = OBus_object.make ~interfaces:[ interface zfs ] pth in
  OBus_object.dynamic ~connection:bus
    ~prefix:(OBus_path.of_string "/com/nickrobison/dbus/zfs1/pool")
    ~handler:(zpool_handler zfs);
  OBus_object.attach obj ();
  OBus_object.export bus obj;

  fst (Lwt.wait ())
