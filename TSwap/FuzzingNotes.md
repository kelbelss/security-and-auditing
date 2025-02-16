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

### **SC Exploits Minimised - Invariant Break**

1. ***Stateless Fuzzing*** (my example in invariant-break tests)
    - Stateless fuzzing (often known as just "fuzzing") is when you provide random data to a function to get some invariant or property to break.
    - It is "stateless" because after every fuzz run, it resets the state, or it starts over.
    - If a property is broken by calling different functions, it won’t find the issue.
    - Stateless fuzzing is especially good if you have a function that has an invariant.
        - Code example
            
            ```jsx
            // myContract
              // Invariant: This function should never return 0
              function doMath(uint128 myNumber) public pure returns (uint256) {
                  if (myNumber == 2) {
                      return 0;
                  }
                  return 1;
              }
            
            // Fuzz test that will (likely) catch the invariant break
              function testFuzzPassesEasyInvariant(uint128 randomNumber) public view {
                  assert(myContract.doMath(randomNumber) != 0);
              }
            ```
            


2. ***Stateful Fuzzing - Open Method***
    - Stateful fuzzing is when you provide random data to your system, and for 1 fuzz run your system starts from the resulting state of the previous input data.
    - Or more simply, you keep doing random stuff to *the same* contract.
    - Could result in path explosion as there are too many routes
    - Set fail_on_revert to false to ignore shit that is not the actual invariant issue
        - Code example
            
            ```jsx
            // myContract
            
                uint256 public myValue = 1;
                uint256 public storedValue = 100;
                
                // Invariant: This function should never return 0
                function doMoreMathAgain(uint128 myNumber) public returns (uint256) {
                    uint256 response = (uint256(myNumber) / 1) + myValue;
                    storedValue = response;
                    return response;
                }
                function changeValue(uint256 newValue) public {
                    myValue = newValue;
                }
            
            // Test
            
                // Setup
                function setUp() public {
                    sfc = new StatefulFuzzCatches();
                    targetContract(address(sfc));
                }
            
                // Stateful fuzz that will (likely) catch the invariant break
                function statefulFuzz_testMathDoesntReturnZero() public view {
                    assert(sfc.storedValue() != 0);
                }
            ```
            

3. ***Stateful Fuzzing - Handler Method: restricts different paths*** 
    - Handler based stateful fuzzing is the same as open stateful fuzzing, except we restrict the number of "random" things we can do.
    - If we have too many options, we may never randomly come across something that will actually break our invariant. So we restrict our random inputs to a set of specific random actions that can be called.
    - Example in invariant-break tests
    - Restricts the "path explosion" problem where there are too many possible paths, so the fuzzer is more likely to find issues

4. ***Formal Verification (part 2 of course)***
    - Formal verification is the process of mathematically proving that a program does a specific thing, or proving it doesn't do a specific thing.
    - One of the most popular ways to do Formal Verification is through [Symbolic Execution](https://ethereum.stackexchange.com/questions/145411/is-the-solidity-built-in-smt-checker-a-form-of-symbolic-execution).
    - It converts your functions to math, and then tries to prove some property on that math. Math can be proved. Math can be solved. Functions can not (unless they are transformed into math).