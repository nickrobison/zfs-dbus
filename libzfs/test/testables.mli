open Alcotest
open Libzfs

val zfs_result : 'a testable -> ('a, Zfs_exception.t) result testable
val string_result : (string, Zfs_exception.t) result testable
val simple_record : Simple_record.t testable
val compression : Compression.t testable
val compression_result: (Compression.t, Zfs_exception.t) result testable
