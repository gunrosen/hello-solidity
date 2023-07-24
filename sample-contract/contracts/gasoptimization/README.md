### Solidity Gas Optimization

[REF](https://gist.github.com/grGred/9bab8b9bad0cd42fc23d4e31e7347144)

#### 1. Update pragma

Safemath by default from 0.8.0 (can be more gas efficient than some library based safemath).

From v0.8.2, add simple inliner to the low level optimizer 

Use custom error function instead of revert string. 

#### 2. For loops improvement

Caching the length in for loops
```solidity
uint length = arr.length;
for (uint i = 0; i < length; i++) {
    // do something that doesn't change arr.length
}
```

i++ involves checked arithmetic, which is not required
```solidity
for (uint i = 0; i < length; i = unchecked_inc(i)) {
    // do something that doesn't change the value of i
}

function unchecked_inc(uint i) returns (uint) {
    unchecked {
        return i + 1;
    }
}
```

++i cost less than i++ because it no need to create temporary var

#### 3. Use calldata instead of memory for function parameters
Apply when arguments are read-only on external functions

#### 4. Change state variables to immutable where possible
It allows setting contract-level variables at construction time which gets stored in code rather than storage.
```solidity
contract C {
    /// The owner is set during contruction time, and never changed afterwards.
    address public immutable owner = msg.sender;
}
```

#### 5. Change constant to immutable for keccak variables
```solidity
contract Immutables is AccessControl {
    uint256 public gas;

    bytes32 public immutable MANAGER_ROLE_IMMUT;
    bytes32 public constant MANAGER_ROLE_CONST = keccak256('MANAGER_ROLE');

    constructor(){
        MANAGER_ROLE_IMMUT = keccak256('MANAGER_ROLE');
        _setupRole(MANAGER_ROLE_CONST, msg.sender);
        _setupRole(MANAGER_ROLE_IMMUT, msg.sender);
    }

    function immutableCheck() external {
        gas = gasleft();
        require(hasRole(MANAGER_ROLE_IMMUT, msg.sender), 'Caller is not in manager role'); // 24408 gas
        gas -= gasleft();
    }

    function constantCheck() external {
        gas = gasleft();
        require(hasRole(MANAGER_ROLE_CONST, msg.sender), 'Caller is not in manager role'); // 24419 gas
        gas -= gasleft();
    }
}
```
Use constant, this results in the keccak operation being performed whenever the variable is used, increasing gas costs relative to just storing the output hash

Changing to immutable will only perform hashing on contract deployment which will save gas.

#### 6. Use modifiers instead of functions to save gas

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract Inlined { //110473
    function isNotExpired(bool _true) internal view {
        require(_true == true, "Exchange: EXPIRED");
    }

    function foo(bool _test) public returns(uint){
            isNotExpired(_test);
            return 1; //21556
    }
}
```

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract Modifier {  //108727
modifier isNotExpired(bool _true) {
        require(_true == true, "Exchange: EXPIRED");
        _;
    }

function foo(bool _test) public isNotExpired(_test)returns(uint){
        return 1; //21532
    }
}
```

#### 7. Use Shift Right/Left instead of Division/Multiplication if possible
DIV opcode uses 5 gas and division-by-0 prevention, the SHR opcode only uses 3 gas.

#### 8. Use double require instead of operator &&

#### 9. Caching storage variables in memory to save gas
Anytime you are reading from storage more than once, it is cheaper in gas cost to cache the variable in memory: a SLOAD cost 100gas, while MLOAD and MSTORE cost 3 gas.

Gas savings: at least 97 gas.

#### 10. Use gasleft() to measure used gas instead of checking transatcion gas cost, in order to find gas optimization
While auditing code for gas optimization improvements it's very convinient to have hardhat gas reporter.

```solidity
contract Test {
uint256 public gas;
    
    function a() public {
        gas = gasleft();
        doStuff();
        gas -= gasleft();
    }
    
    function b() public {
        gas = gasleft();
        doStuff();
        gas -= gasleft();
    }
}
```

#### 11. Writing to an existing Storage Slot is cheaper than using a new one
EIP - 2200 changed a lot with gas, and now if you hold 1 Wei of a token it’s cheaper to use the token than if you hold 0


