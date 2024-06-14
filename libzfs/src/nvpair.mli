type typ = Bool of bool | String of string | Int32 of int
(* | Byte of bytes
   | Int8 of int
   | Int16 of int
   | Double of float
   | BoolArray of bool list
   | StringArray of string list
   | NVPair of t
   | NVPairArray of t list *)

and t = string * typ
