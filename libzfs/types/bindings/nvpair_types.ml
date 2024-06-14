module M (F : Ctypes.TYPE) = struct
  open F

  type nvlist_t = unit

  let nvlist_t = void
  let unique_name = constant "NV_UNIQUE_NAME" int

  let mk_enum prefix typedef vals =
    enum ~typedef:true
      ~unexpected:(fun i ->
        `E (Printf.sprintf "Unexpected enum code: %d" (Int64.to_int i)))
      typedef
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
end
