# Fuzzing and Invariants

**Stateless fuzzing (fuzz tests)**

- state of the previous run is discarded for each new run
- random data to one function

**Stateful fuzzing (invariant tests)**

- final state of previous run is starting state for new run
- random data and random function calls to many functions

**Invariant & Properties** 

- something in the system that cannot be broken (https://github.com/crytic/properties - Trail of Bits)
- sometimes protocol will give you the invariants, sometimes you have to figure them out
- TSwap has listed *Core Invariant* as `x * y = k`  formula.

**Stateful and Stateless Fuzzing** 

- invariant - something in the system that should always hold and not be broken
- learn how fuzz tests choose the random data (seed?)
- best fuzzer - Trail of Bits Echidna, second is Foundry
- amount of runs can be changed in `foundry.toml` - [fuzz] runs = 1000

*Stateless Fuzzing: Where the state of the previous run is discarded for every new run.*

*Stateful Fuzzing: Where the final state of the previous run is the starting state of the next run.*

- `import {StdInvariant} from “forge-std/StdInvariant.sol";`
- `contract MyContractTest is StdInvariant, Test {}` order matters
- set `targetContract` in setUp()

*Fuzz Tests (Stateless): Random data to one function.*

*Invariant Tests (Stateful): Random data and random function calls to many functions.*

