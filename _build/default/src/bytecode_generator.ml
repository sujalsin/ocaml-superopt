open Core
open Types

let generate_sequence length =
  List.init length ~f:(fun _ ->
    { opcode = "CONST0";  (* Placeholder - expand with more instructions *)
      operands = [];
      size = 1;
      cycles = 1 })

let validate_stack_balance sequence =
  let rec check_stack depth sequence =
    match sequence with
    | [] -> 
        printf "End of sequence, final depth: %d\n" depth;
        depth = 0
    | instr :: rest ->
        printf "Processing %s with depth %d\n" instr.opcode depth;
        let new_depth = match instr.opcode with
          | "CONST0" | "CONST1" | "CONST2" -> 
              printf "  Push constant, new depth: %d\n" (depth + 1);
              depth + 1
          | "POP" -> 
              if depth <= 0 then (
                printf "  Pop with empty stack!\n";
                -1  (* Stack underflow *)
              ) else (
                printf "  Pop, new depth: %d\n" (depth - 1);
                depth - 1
              )
          | "ADDINT" -> 
              if depth < 2 then (
                printf "  Add with insufficient operands!\n";
                -1  (* Stack underflow *)
              ) else (
                printf "  Add, new depth: %d\n" (depth - 2 + 1);
                depth - 2 + 1  (* Consumes 2 operands, produces 1 result *)
              )
          | _ -> 
              printf "  Unknown instruction\n";
              depth
        in
        printf "  After instruction, depth: %d\n" new_depth;
        if new_depth < 0 then (
          printf "  Stack underflow detected!\n";
          false
        ) else check_stack new_depth rest
  in
  let result = check_stack 0 sequence in
  printf "Final validation result: %b\n" result;
  result

let calculate_locality_score sequence =
  let n = List.length sequence in
  if n <= 1 then 1.0
  else
    let pairs = List.zip_exn (List.drop_last_exn sequence) (List.tl_exn sequence) in
    let locality_sum = List.fold pairs ~init:0.0 ~f:(fun acc (instr1, instr2) ->
      if String.equal instr1.opcode instr2.opcode then
        acc +. 1.0
      else
        acc) in
    locality_sum /. Float.of_int (n - 1)

let evaluate_sequence_extended ?(cost_model={
    size_weight = 1.0;
    cycle_weight = 1.0;
    stack_weight = 1.0;
    locality_weight = 1.0;
  }) sequence =
  let total_size = List.fold sequence ~init:0 ~f:(fun acc instr -> acc + instr.size) in
  let total_cycles = List.fold sequence ~init:0 ~f:(fun acc instr -> acc + instr.cycles) in
  let locality = calculate_locality_score sequence in
  let stack_score = if validate_stack_balance sequence then 1.0 else 0.0 in
  
  cost_model.size_weight *. Float.of_int total_size +.
  cost_model.cycle_weight *. Float.of_int total_cycles +.
  cost_model.stack_weight *. stack_score -.  (* Better locality should reduce cost *)
  cost_model.locality_weight *. locality

let optimize_sequence ?(cost_model={
    size_weight = 1.0;
    cycle_weight = 1.0;
    stack_weight = 1.0;
    locality_weight = 1.0;
  }) sequence =
  let _original_cost = evaluate_sequence_extended ~cost_model sequence in
  
  (* For now, just return the original sequence - optimization logic to be added *)
  { original_sequence = sequence;
    optimized_sequence = sequence;
    cost_reduction = 0.0;
    verification_status = Verified }
