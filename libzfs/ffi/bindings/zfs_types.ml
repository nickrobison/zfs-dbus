open Ctypes

module Libzfs_handle = struct
  type t = unit ptr

  let t : t typ = ptr void
end

module Zpool_handle = struct
  type t = unit ptr

  let t : t typ = ptr void
end

module Zfs_handle = struct
  type t = unit ptr

  let t : t typ = ptr void
end

type zpool_iter_f = Zpool_handle.t -> unit ptr -> int

let zpool_iter_f : zpool_iter_f typ =
  Foreign.funptr (Zpool_handle.t @-> ptr void @-> returning int)

type zfs_iter_f = Zfs_handle.t -> unit ptr -> int

let zfs_iter_f : zfs_iter_f typ =
  Foreign.funptr (Zfs_handle.t @-> ptr void @-> returning int)

type dataset_type = FILESYSTEM | VOLUME | SNAPSHOT | BOOKMARK

let dataset_type_of_int = function
  | 1 -> FILESYSTEM
  | 2 -> VOLUME
  | 3 -> SNAPSHOT
  | 4 -> BOOKMARK
  | _ -> invalid_arg "dataset_type"

let int_of_dataset_type = function
  | FILESYSTEM -> 1
  | VOLUME -> 2
  | SNAPSHOT -> 3
  | BOOKMARK -> 4
