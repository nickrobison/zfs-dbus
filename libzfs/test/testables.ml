open Alcotest
open Libzfs

let zfs_err_testable = Zfs_exception.(testable pp equal)
let zfs_result t = result t zfs_err_testable
let string_result = result string zfs_err_testable
let simple_record = Simple_record.(testable pp equal)
let compression = Compression.(testable pp equal)
let compression_result = result compression zfs_err_testable
let nvpair = NVPair.NVPair.(testable pp equal)
let unit = result unit zfs_err_testable
