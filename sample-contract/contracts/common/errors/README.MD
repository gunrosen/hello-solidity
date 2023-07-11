### Errors 

`revert("Insufficient funds.");` rather expensive, especially it comes to deploy cost

```solidity
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;
    
error InsufficientBalance(uint256 available, uint256 required);

contract TestToken {
    mapping(address => uint) balance;
    function transfer(address to, uint256 amount) public {
        if (amount > balance[msg.sender])
        // Error call using named parameters. Equivalent to
        // revert InsufficientBalance(balance[msg.sender], amount);
            revert InsufficientBalance({
            available: balance[msg.sender],
            required: amount
            });
        balance[msg.sender] -= amount;
        balance[to] += amount;
    }
    // ...
}
```

The error data would be encoded as the ABI encoding for function call
`abi.encodeWithSignature("InsufficientBalance(uint256,uint256)", balance[msg.sender], amount)`

We can decode error data 

```javascript
import { ethers } from "ethers";

// As a workaround, we have a function with the
// same name and parameters as the error in the abi.
const abi = [
    "function InsufficientBalance(uint256 available, uint256 required)"
];

const interface = new ethers.utils.Interface(abi);
const error_data =
    "0xcf479181" +
    "0000000000000000000000000000000000000000000000000000000000000100" +
    "0000000000000000000000000000000000000000000000000000000100000000";

const decoded = interface.decodeFunctionData(
    interface.functions["InsufficientBalance(uint256,uint256)"],
    error_data
);
// Contents of decoded:
// [
//   BigNumber { _hex: '0x0100', _isBigNumber: true },
//   BigNumber { _hex: '0x0100000000', _isBigNumber: true },
//   available: BigNumber { _hex: '0x0100', _isBigNumber: true },
//   required: BigNumber { _hex: '0x0100000000', _isBigNumber: true }
// ]
console.log(
    "Insufficient balance for transfer. " +
    `Needed ${decoded.required.toString()} but only ` +
    `${decoded.available.toString()} available.`
);
```

### Error in depth
This is the same as the ABI encoding of a function call with the name Unauthorized(). Here 0x82b42900 is the ‘selector’ for Unauthorized()

`revert Unauthorized();` equals to 

```solidity
let free_mem_ptr := mload(64)
mstore(free_mem_ptr, 0x82b4290000000000000000000000000000000000000000000000000000000000)
revert(free_mem_ptr, 4)
```

revert("Unauthorized"); leads to the following Yul code:

```solidity
let free_mem_ptr := mload(64)
mstore(free_mem_ptr, 0x08c379a000000000000000000000000000000000000000000000000000000000)
mstore(add(free_mem_ptr, 4), 32)
mstore(add(free_mem_ptr, 36), 12)
mstore(add(free_mem_ptr, 68), "Unauthorized")
revert(free_mem_ptr, 100)
```
Here `0x08c379a0` is the ‘selector’ of Error(string)

In this comparison, one can see that custom errors decrease both deploy and runtime gas costs. 