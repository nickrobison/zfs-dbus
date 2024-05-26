module C = Configurator.V1

let ocamlopt_lines c =
  let cflags =
    try C.ocaml_config_var_exn c "ocamlopt_cflags"
    with _ -> "-O3 -fno-strict-aliasing -fwrapv"
  in
  C.Flags.extract_blank_separated_words cflags

let link_flags _c =
  let libs = [ "zfs" ] in
  List.map (fun l -> "-l" ^ l) libs

let () =
  let cstubs = ref "" in
  let args = Arg.[ ("-cstubs", Set_string cstubs, "cstubs loc") ] in
  C.main ~args ~name:"libzfs" (fun c ->
      let cstubs_cflags = Printf.sprintf "-I%s" (Filename.dirname !cstubs) in
      let lines = ocamlopt_lines c in
      let link_flags = link_flags c in
      C.Flags.write_lines "cflags" lines;
      C.Flags.write_lines "ctypes-cflags" [ cstubs_cflags ];
      C.Flags.write_sexp "c_library_flags.sexp" link_flags;
      C.Flags.write_lines "c_library_flags" link_flags)
