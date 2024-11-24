open Core
open OUnit2
open Types

(* Test utilities *)
let create_test_sequence instructions =
  List.map instructions ~f:(fun (opcode, operands) ->
    { opcode = opcode;
      operands = operands;
      size = 1 + List.length operands;
      cycles = 1 })

let print_sequence sequence =
  List.iter sequence ~f:(fun instr ->
    printf "Instruction: %s, Operands: [%s]\n"
      instr.opcode
      (String.concat ~sep:", " (List.map instr.operands ~f:Int.to_string)))

(* Test cases *)
let test_bytecode_generator _test_ctxt =
  let sequence = Bytecode_generator.generate_sequence 4 in
  assert_equal 4 (List.length sequence);
  assert (List.for_all sequence ~f:(fun instr ->
    String.length instr.opcode > 0))

let test_stack_balance_basic _test_ctxt =
  let valid_sequence = create_test_sequence [
    ("CONST0", []);
    ("CONST1", []);
    ("ADDINT", []);  (* Takes 2 operands, produces 1 result *)
    ("POP", []);     (* Pop the result to get empty stack *)
  ] in
  let invalid_sequence = create_test_sequence [
    ("POP", []);  (* Stack underflow *)
    ("CONST0", []);
  ] in
  printf "\nTesting basic valid sequence:\n";
  print_sequence valid_sequence;
  printf "\nTesting basic invalid sequence:\n";
  print_sequence invalid_sequence;
  let valid_result = Bytecode_generator.validate_stack_balance valid_sequence in
  let invalid_result = Bytecode_generator.validate_stack_balance invalid_sequence in
  printf "\nValid sequence result: %b\n" valid_result;
  printf "Invalid sequence result: %b\n\n" invalid_result;
  assert valid_result;
  assert (not invalid_result)

let test_stack_balance_complex _test_ctxt =
  (* Test case 1: Multiple arithmetic operations *)
  let complex_valid = create_test_sequence [
    ("CONST0", []); (* Stack: [0] *)
    ("CONST1", []); (* Stack: [1, 0] *)
    ("ADDINT", []); (* Stack: [1] *)
    ("CONST2", []); (* Stack: [2, 1] *)
    ("CONST1", []); (* Stack: [1, 2, 1] *)
    ("ADDINT", []); (* Stack: [3, 1] *)
    ("ADDINT", []); (* Stack: [4] *)
    ("POP", []);    (* Stack: [] *)
  ] in
  printf "\nTesting complex valid sequence:\n";
  print_sequence complex_valid;
  assert (Bytecode_generator.validate_stack_balance complex_valid);

  (* Test case 2: Empty sequence *)
  let empty_sequence = create_test_sequence [] in
  printf "\nTesting empty sequence:\n";
  assert (Bytecode_generator.validate_stack_balance empty_sequence);

  (* Test case 3: Multiple pops causing underflow *)
  let multi_pop_invalid = create_test_sequence [
    ("CONST0", []);
    ("POP", []);
    ("POP", []); (* Should cause underflow *)
  ] in
  printf "\nTesting multiple pop sequence:\n";
  print_sequence multi_pop_invalid;
  assert (not (Bytecode_generator.validate_stack_balance multi_pop_invalid));

  (* Test case 4: Non-empty final stack *)
  let non_empty_final = create_test_sequence [
    ("CONST0", []);
    ("CONST1", []);
    ("ADDINT", []); (* Stack has one item at the end *)
  ] in
  printf "\nTesting non-empty final stack sequence:\n";
  print_sequence non_empty_final;
  assert (not (Bytecode_generator.validate_stack_balance non_empty_final))

let test_stack_balance_edge_cases _test_ctxt =
  (* Test case 1: Maximum stack depth *)
  let deep_stack = create_test_sequence (
    List.init 100 ~f:(fun _ -> ("CONST0", [])) @ 
    List.init 100 ~f:(fun _ -> ("POP", []))
  ) in
  printf "\nTesting deep stack sequence:\n";
  assert (Bytecode_generator.validate_stack_balance deep_stack);

  (* Test case 2: Alternating push/pop *)
  let alternating = create_test_sequence (
    List.concat_map (List.range 0 10) ~f:(fun _ -> [
      ("CONST0", []);
      ("POP", []);
    ])
  ) in
  printf "\nTesting alternating push/pop sequence:\n";
  assert (Bytecode_generator.validate_stack_balance alternating);

  (* Test case 3: Complex arithmetic chain *)
  let arithmetic_chain = create_test_sequence [
    ("CONST0", []); (* Stack: [0] *)
    ("CONST1", []); (* Stack: [1, 0] *)
    ("CONST2", []); (* Stack: [2, 1, 0] *)
    ("ADDINT", []); (* Stack: [3, 0] *)
    ("CONST1", []); (* Stack: [1, 3, 0] *)
    ("ADDINT", []); (* Stack: [4, 0] *)
    ("ADDINT", []); (* Stack: [4] *)
    ("POP", []);    (* Stack: [] *)
  ] in
  printf "\nTesting arithmetic chain sequence:\n";
  print_sequence arithmetic_chain;
  assert (Bytecode_generator.validate_stack_balance arithmetic_chain)

let test_verification _test_ctxt =
  let ctx = Verification.create_context () in
  (* Test case 1: Simple addition equivalence *)
  let seq1 = create_test_sequence [
    ("CONST1", []);
    ("CONST1", []);
    ("ADDINT", []);
  ] in
  let seq2 = create_test_sequence [
    ("CONST2", []);
  ] in
  let input_state = Verification.create_state () in
  assert (Verification.verify_equivalence ctx seq1 seq2 input_state);

  (* Test case 2: More complex equivalence *)
  let seq3 = create_test_sequence [
    ("CONST1", []);
    ("CONST1", []);
    ("ADDINT", []);
    ("CONST2", []);
    ("ADDINT", []);
  ] in
  let seq4 = create_test_sequence [
    ("CONST4", []);
  ] in
  assert (Verification.verify_equivalence ctx seq3 seq4 input_state)

let test_cost_model _test_ctxt =
  let cost_model = {
    size_weight = 1.0;
    cycle_weight = 1.0;
    stack_weight = 1.0;
    locality_weight = 1.0;
  } in
  
  (* Test case 1: Empty sequence *)
  let empty_seq = create_test_sequence [] in
  let empty_cost = Bytecode_generator.evaluate_sequence_extended ~cost_model empty_seq in
  assert (Float.compare empty_cost 0.0 = 0);

  (* Test case 2: Single instruction *)
  let single_instr = create_test_sequence [("CONST0", [])] in
  let single_cost = Bytecode_generator.evaluate_sequence_extended ~cost_model single_instr in
  assert (Float.compare single_cost 0.0 > 0);

  (* Test case 3: Sequence with good locality *)
  let good_locality = create_test_sequence [
    ("CONST0", []);
    ("CONST0", []);
    ("CONST0", []);
  ] in
  let good_locality_cost = Bytecode_generator.evaluate_sequence_extended ~cost_model good_locality in
  
  (* Test case 4: Sequence with poor locality *)
  let poor_locality = create_test_sequence [
    ("CONST0", []);
    ("CONST1", []);
    ("CONST2", []);
  ] in
  let poor_locality_cost = Bytecode_generator.evaluate_sequence_extended ~cost_model poor_locality in
  
  (* Good locality should have lower cost than poor locality *)
  assert (Float.compare good_locality_cost poor_locality_cost < 0)

let test_parallel_optimization _test_ctxt =
  let sequence = create_test_sequence [
    ("CONST0", []);
    ("CONST1", []);
    ("ADDINT", []);
  ] in
  let cost_model = {
    size_weight = 1.0;
    cycle_weight = 1.0;
    stack_weight = 1.0;
    locality_weight = 1.0;
  } in
  let result = Bytecode_generator.optimize_sequence ~cost_model sequence in
  assert (Float.compare result.cost_reduction 0.0 >= 0);
  
  (* Test optimization with empty sequence *)
  let empty_seq = create_test_sequence [] in
  let empty_result = Bytecode_generator.optimize_sequence ~cost_model empty_seq in
  assert (List.length empty_result.optimized_sequence = 0);
  
  (* Test optimization with single instruction *)
  let single_instr = create_test_sequence [("CONST0", [])] in
  let single_result = Bytecode_generator.optimize_sequence ~cost_model single_instr in
  assert (List.length single_result.optimized_sequence = 1)

(* Test suite *)
let suite =
  "superopt_suite" >::: [
    "test_bytecode_generator" >:: test_bytecode_generator;
    "test_stack_balance_basic" >:: test_stack_balance_basic;
    "test_stack_balance_complex" >:: test_stack_balance_complex;
    "test_stack_balance_edge_cases" >:: test_stack_balance_edge_cases;
    "test_verification" >:: test_verification;
    "test_cost_model" >:: test_cost_model;
    "test_parallel_optimization" >:: test_parallel_optimization;
  ]

let () = run_test_tt_main suite
