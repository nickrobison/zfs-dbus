(lang dune 3.15)
(using ctypes 0.3)

(name zfs_dbus)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name")

(maintainers "Maintainer Name")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name zfs_dbus)
 (synopsis "A DBus interface for ZFS")
 (description "DBus service for configuring and managing ZFS")
 (depends ocaml dune logs cmdliner obus)
 (tags
  (topics "to describe" your project)))

(package
  (name libzfs)
  (synopsis "ZFS bindings")
  (depends ocaml dune ctypes ctypes-foreign integers hmap ppx_deriving (alcotest-lwt :with-test) (qcheck-core :with-test) (qcheck-alcotest :with-test) (ppx_deriving_qcheck :with-test)))