open Core

(* Instruction type *)
type instruction = {
  opcode: string;
  operands: int list;
  size: int;
  cycles: int;
} [@@deriving show, sexp]

(* Cost model type *)
type cost_model = {
  size_weight: float;
  cycle_weight: float;
  stack_weight: float;
  locality_weight: float;
} [@@deriving show, sexp]

(* Bytecode sequence type *)
type bytecode_sequence = instruction list 

(* Verification result type *)
type verification_status = 
  | Verified
  | Failed of string
[@@deriving show, sexp]

(* Optimization result type *)
type optimization_result = {
  original_sequence: instruction list;
  optimized_sequence: instruction list;
  cost_reduction: float;
  verification_status: verification_status;
} [@@deriving show, sexp]
