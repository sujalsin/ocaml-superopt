# OCaml Bytecode Superoptimizer

A tool for generating optimal OCaml bytecode sequences through exhaustive search and formal verification.

## Overview

This superoptimizer works by:
1. Taking an input bytecode sequence
2. Generating equivalent candidate sequences
3. Verifying their equivalence using symbolic execution and the Z3 SMT solver
4. Evaluating their efficiency using a comprehensive cost model
5. Selecting the most efficient verified sequence

## Features

- Exhaustive search for optimal bytecode sequences
- Symbolic execution-based verification
- Formal verification using Z3 SMT solver
- Advanced cost model considering:
  - Instruction size and cycles
  - Stack balance validation
  - Instruction locality
  - Configurable weights for each factor
- Parallel search and verification capabilities
- Command-line interface for easy integration
- Comprehensive test suite with edge case coverage
- Support for processing both individual sequences and bytecode files

## Requirements

- OCaml (>= 4.14.0)
- Dune (>= 3.0)
- Core (>= v0.15.0)
- Core_bench (>= v0.15.0)
- Z3 (>= 4.8.13)
- PPX extensions (ppx_jane, ppx_expect, ppx_deriving)

## Installation

1. Install dependencies:
```bash
opam install dune core core_bench z3 ppx_jane ppx_expect ppx_deriving
```

2. Build the project:
```bash
dune build
```

3. Run tests:
```bash
dune runtest
```

## Usage

Basic usage with default parameters:
```bash
dune exec ocaml-superopt
```

Optimize a specific bytecode file:
```bash
dune exec ocaml-superopt -- -input bytecode.txt
```

Configure optimization parameters:
```bash
dune exec ocaml-superopt -- -max-length 6 -size-weight 1.5 -cycle-weight 2.0 -stack-weight 1.0 -locality-weight 1.0
```

## Cost Model

The cost model evaluates sequences based on multiple factors:

1. **Instruction Size**: Physical size of instructions in bytes
2. **CPU Cycles**: Estimated execution cycles
3. **Stack Balance**: Ensures proper stack manipulation
   - Validates stack depth at each step
   - Prevents stack underflow
   - Ensures empty stack at sequence end
4. **Instruction Locality**: Rewards sequences with good instruction locality
   - Higher scores for consecutive similar instructions
   - Improves instruction cache utilization

Each factor can be weighted using command-line flags to customize optimization priorities.

## Implementation Details

- `src/types.ml`: Core data structures and type definitions
- `src/bytecode_generator.ml`: 
  - Instruction sequence generation
  - Stack balance validation
  - Cost model implementation
- `src/verification.ml`: 
  - Symbolic execution engine
  - Z3-based equivalence checking
  - Path condition tracking
- `src/main.ml`: Command-line interface and optimization logic
- `src/test/test_superopt.ml`: Comprehensive test suite

## Testing

The project includes extensive tests covering:
- Stack balance validation
  - Basic sequences
  - Complex arithmetic chains
  - Deep stack operations
  - Edge cases (empty sequences, underflow)
- Cost model evaluation
  - Size and cycle costs
  - Locality scoring
  - Stack balance impact
- Verification
  - Simple equivalence
  - Complex arithmetic equivalence
- Optimization
  - Basic sequence optimization
  - Empty and single instruction cases
  - Parallel optimization

Run tests with:
```bash
dune runtest
```

## Contributing

Contributions are welcome! Areas for improvement include:
- Adding support for more bytecode instructions
- Enhancing symbolic execution capabilities
- Improving cost model accuracy with real-world benchmarks
- Optimizing parallel search algorithms
- Adding more verification techniques
- Expanding test coverage

## License

MIT License
