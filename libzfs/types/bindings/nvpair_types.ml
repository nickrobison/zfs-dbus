module C = Ctypes

module M (F : Ctypes.TYPE) = struct
  open F

  let unique_name = constant "NV_UNIQUE_NAME" int

  let mk_enum prefix ?(typedef = true) name vals =
    enum ~typedef
      ~unexpected:(fun i ->
        `E (Printf.sprintf "Unexpected enum code: %d" (Int64.to_int i)))
      name
      (List.map (fun (a, b) -> (a, F.constant (prefix ^ b) F.int64_t)) vals)

  type data_type_t =
    [ `Dont_care
    | `Unknown
    | `Bool
    | `Byte
    | `Int16
    | `Uint16
    | `Int32
    | `Uint32
    | `Int64
    | `Uint64
    | `String
    | `Byte_array
    | `Int16_array
    | `Uint16_array
    | `Int32_array
    | `Uint32_array
    | `Int64_array
    | `Uint64_array
    | `String_array
    | `Hrtime
    | `NVList
    | `NVList_array
    | `Bool_value
    | `Int8
    | `Uint8
    | `Bool_array
    | `Int8_array
    | `Uint8_array
    | `Double
    | `E of string ]

  let show_data_type_t = function
    | `Dont_care -> "Don't care"
    | `Unknown -> "Unknown"
    | `Bool -> "Bool"
    | `Byte -> "Byte"
    | `Int16 -> "Int16"
    | `Uint16 -> "Uint16"
    | `Int32 -> "Int32"
    | `Uint32 -> "Uint32"
    | `Int64 -> "Int64"
    | `Uint64 -> "Uint64"
    | `String -> "String"
    | `Byte_array -> "Byte array"
    | `Int16_array -> "Int16 array"
    | `Uint16_array -> "Uint16 array"
    | `Int32_array -> "Int32 array"
    | `Uint32_array -> "Uint32 array"
    | `Int64_array -> "Int64 array"
    | `Uint64_array -> "Uint64 array"
    | `String_array -> "String array"
    | `Hrtime -> "HRtime"
    | `NVList -> "NVList"
    | `NVList_array -> "NVList array"
    | `Bool_value -> "Bool (value)"
    | `Int8 -> "Int8"
    | `Uint8 -> "Uint8"
    | `Bool_array -> "Bool array"
    | `Int8_array -> "Int8 array"
    | `Uint8_array -> "Uint8 array"
    | `Double -> "Double"
    | `E s -> s

  let data_type_t : data_type_t typ =
    mk_enum "DATA_TYPE_" "data_type_t"
      [
        (`Dont_care, "DONTCARE");
        (`Unknown, "UNKNOWN");
        (`Bool, "BOOLEAN");
        (`Byte, "BYTE");
        (`Int16, "INT16");
        (`Uint16, "UINT16");
        (`Int32, "INT32");
        (`Uint32, "UINT32");
        (`Int64, "INT64");
        (`Uint64, "UINT64");
        (`String, "STRING");
        (`Byte_array, "BYTE_ARRAY");
        (`Int16_array, "INT16_ARRAY");
        (`Uint16_array, "UINT16_ARRAY");
        (`Int32_array, "INT32_ARRAY");
        (`Uint32_array, "UINT32_ARRAY");
        (`Int64_array, "INT64_ARRAY");
        (`Uint64_array, "UINT64_ARRAY");
        (`String_array, "STRING_ARRAY");
        (`Hrtime, "HRTIME");
        (`NVList, "NVLIST");
        (`NVList_array, "NVLIST_ARRAY");
        (`Bool_value, "BOOLEAN_VALUE");
        (`Int8, "INT8");
        (`Uint8, "UINT8");
        (`Bool_array, "BOOLEAN_ARRAY");
        (`Int8_array, "INT8_ARRAY");
        (`Uint8_array, "UINT8_ARRAY");
        (`Double, "DOUBLE");
      ]

  let size_data_type_t = function
    | `Int32 -> C.sizeof C.int32_t
    | _ -> raise (Invalid_argument "Cannot size this")

  (* NVList *)
  type nvlist
  type nvlist_t = nvlist C.structure

  let nvlist_t : nvlist C.structure typ = structure "nvlist"
  let _ = field nvlist_t "nvl_version" int32_t
  let _ = field nvlist_t "nvl_nvflag" uint32_t
  let _ = field nvlist_t "nvl_priv" uint64_t
  let _ = field nvlist_t "nvl_flag" uint32_t
  let _ = field nvlist_t "nvl_pad" int32_t
  let () = seal nvlist_t

  (* NVPair *)

  type nvpair
  type nvpair_t = nvpair C.structure

  let nvpair_t : nvpair C.structure C.typ = C.structure "nvpair"
  let nvp_size = C.(field nvpair_t "nvp_size" int32_t)
  let nvp_name_sz = C.(field nvpair_t "nvp_name_sz" int16_t)
  let _ = C.(field nvpair_t "nvp_reserve" int16_t)
  let nvp_elements = C.(field nvpair_t "nvp_value_elem" int32_t)
  let _ = C.(field nvpair_t "nvp_type" int64_t)
  let nvp_name = C.(field nvpair_t "nvp_name" (array 0 char))
  let () = C.seal nvpair_t

  let string_to_char_array s =
    let len = String.length s in
    let buf = C.CArray.make C.char ~initial:'\x00' (len + 1) in
    String.iteri (fun idx c -> C.CArray.set buf idx c) s;
    buf

  let size t = C.(getf t nvp_size) |> Int32.to_int

  let name t =
    let open C in
    let len = getf t nvp_name_sz in
    let name_start = getf t nvp_name |> CArray.start in
    let name = CArray.from_ptr name_start len |> CArray.to_list in
    let buf = Buffer.create len in
    List.iter (Buffer.add_char buf) name;
    Buffer.contents buf

  let set_name name t =
    let name_len = String.length name + 1 in
    C.setf t nvp_name_sz name_len;
    let name_arry = string_to_char_array name in
    C.(setf t nvp_name name_arry);
    ()

  let name_size t = C.(getf t nvp_name_sz)
  let elements t = C.(getf t nvp_elements) |> Int32.to_int

  let set_elements elems t =
    let elems = Int32.of_int elems in
    C.(setf t nvp_elements elems)

  type zio_compress =
    [ `Inherit
    | `On
    | `Off
    | `Lzjb
    | `Empty
    | `Gzip_1
    | `Gzip_2
    | `Gzip_3
    | `Gzip_4
    | `Gzip_5
    | `Gzip_6
    | `Gzip_7
    | `Gzip_8
    | `Gzip_9
    | `Zle
    | `LZ4
    | `Zstd
    | `Function
    | `E of string ]

  let zio_compress : zio_compress typ =
    mk_enum ~typedef:false "ZIO_COMPRESS_" "zio_compress"
      [
        (`Inherit, "INHERIT");
        (`On, "ON");
        (`Off, "OFF");
        (`Lzjb, "LZJB");
        (`Empty, "EMPTY");
        (`Gzip_1, "GZIP_1");
        (`Gzip_2, "GZIP_2");
        (`Gzip_3, "GZIP_3");
        (`Gzip_4, "GZIP_4");
        (`Gzip_5, "GZIP_5");
        (`Gzip_6, "GZIP_6");
        (`Gzip_7, "GZIP_7");
        (`Gzip_8, "GZIP_8");
        (`Gzip_9, "GZIP_9");
        (`Zle, "ZLE");
        (`LZ4, "LZ4");
        (`Zstd, "ZSTD");
        (`Function, "FUNCTIONS");
      ]
end
