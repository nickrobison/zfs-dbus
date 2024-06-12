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
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends ocaml dune)
 (tags
  (topics "to describe" your project)))

(package
  (name libzfs)
  (synopsis "ZFS bindings")
  (depends ocaml dune ctyes (alcotest-lwt :with-test)))

(package
  (name libnvpair)
  (synopsis "Libnvpair bindings")
  (depends ocaml dune ctypes))