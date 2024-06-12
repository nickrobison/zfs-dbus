open Ctypes

module T = C.Types
module F = C.Functions

type t = T.Nvlist.t ptr

let empty () = 
  let ls = allocate (ptr T.Nvlist.t) (from_voidp T.Nvlist.t null) in
  match F.nvlist_alloc ls 1 0 with 
  | 0 -> !@ ls
  | _ -> raise (Invalid_argument "bad")