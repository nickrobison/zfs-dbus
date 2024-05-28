
let zfs_iterator iter_fn create_fn =
  let result = ref [] in
  let handler handle _ = 
    result := !result @ [ (create_fn handle)];
    0
  in
  let u = Ctypes.allocate Ctypes.int 1 in
  let _ = iter_fn handler (Ctypes.to_voidp u) in
  !result
