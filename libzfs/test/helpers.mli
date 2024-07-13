open Libzfs

val with_dataset : Zfs.t -> Dataset.Builder.t -> (Dataset.t -> 'a) -> 'a
