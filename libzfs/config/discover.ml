module C = Configurator.V1

let flags c =
  let cc = Configurator.V1.Pkg_config.get c in
  match cc with
  | Some c' -> Configurator.V1.Pkg_config.query c' ~package:"libzfs"
  | None -> raise (Invalid_argument "Need pkg-config, because I'm lazy")

let () =
  let cstubs = ref "" in
  let args = Arg.[ ("-cstubs", Set_string cstubs, "cstubs loc") ] in
  C.main ~args ~name:"libzfs" (fun c ->
      let cstubs_cflags = Printf.sprintf "-I%s" (Filename.dirname !cstubs) in
      let cfg =
        match flags c with
        | Some c -> c
        | None -> raise (Invalid_argument "Need pkg_config")
      in
      C.Flags.write_lines "cflags" cfg.cflags;
      (* Temporarily disabling some warnings so we can build under GCC14. It's gross, but I'm not sure what else to do. *)
      C.Flags.write_sexp "cflags.sexp" (cfg.cflags @ [ "-D_LARGEFILE64_SOURCE"; "-Wno-discarded-qualifiers"; "-Wno-incompatible-pointer-types" ]);
      C.Flags.write_sexp "c_library_flags.sexp"
        ([ cstubs_cflags ] @ cfg.libs @ cfg.cflags);
      C.Flags.write_lines "ctypes-cflags" ([ cstubs_cflags ] @ cfg.cflags);
      C.Flags.write_lines "c_library_flags" cfg.libs)
