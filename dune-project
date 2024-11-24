(lang dune 3.0)
(name ocaml_superopt)
(version 0.1.0)

(generate_opam_files true)

(package
 (name ocaml_superopt)
 (synopsis "A superoptimizer for OCaml bytecode")
 (description "Generates optimal OCaml bytecode sequences through exhaustive search and formal verification")
 (depends
  (ocaml (>= 4.14.0))
  (dune (>= 3.0))
  (core (>= v0.15.0))
  (core_bench (>= v0.15.0))
  (z3 (>= 4.8.13))
  (ppx_jane (>= v0.15.0))
  (ppx_expect (>= v0.15.0))
  (ounit2 (>= 2.2.7))))
