open Libzfs

let name pool _obj =
  let n = Zpool.name pool in
  Lwt_react.S.const n

let interface pool =
  Zfs_interfaces.Com_nickrobison_dbus_ZFS1_Pool.make
    { Zfs_interfaces.Com_nickrobison_dbus_ZFS1_Pool.p_name = name pool }

let create pool =
  let name = Zpool.name pool in
  let obj =
    OBus_object.make
      ~interfaces:[ interface pool ]
      [ "/com/nickrobison/dbus/zfs1"; name ]
  in
  obj
