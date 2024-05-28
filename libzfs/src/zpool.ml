module M = Libzfs_ffi.M

type t = { root: M.Libzfs_handle.t; handle : M.Zpool_handle.t; name : string }

let of_handle root handle =
  let name = M.zpool_name handle in
  { root; handle; name }

let name t = t.name

let root t = M.zfs_open t.root t.name (M.int_of_dataset_type FILESYSTEM)

let root_dataset t = 
  let handle = root t in
  Dataset.of_handle handle

let child_datasets t = 
  let root = root t in
  let iter_fn = M.zfs_iter_filesystems root in
  Utils.zfs_iterator iter_fn Dataset.of_handle

let get_dataset t name = 
  let handle = M.zfs_open t.handle name (M.int_of_dataset_type FILESYSTEM) in
  Dataset.of_handle handle