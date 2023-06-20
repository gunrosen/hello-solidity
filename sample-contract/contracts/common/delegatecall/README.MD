### Delegatecall

Says that I am a contract and I 'm allowing (delegating) you to do whatever you want to my storage

`DELEGATECALL` is security risk for sending contract which needs to trust that the receiving contract will treat the
storage well

`DELEGRATECALL` was a new opcode that was a bug fix for `CALLCODE` which did not preserve `msg.sender` and `msg.value`

When D `call` on E, the code runs in the context of E: the storage of E is used

When D `delegatecall` on E, the code runs in context of D

```solidity

contract Delegation {

    address public owner;
    Delegate delegate;

    constructor(address _delegateAddress) {
        delegate = Delegate(_delegateAddress);
        owner = msg.sender;
    }

    fallback() external {
        (bool result,) = address(delegate).delegatecall(msg.data);
        if (result) {
            this;
        }
    }
}
```

```javascript
const bytesData = web3.utils.sha3("functionName(uint, uint)").slice(0, 10) // Get 4 bytes hash as selector

// Send to fallback by not call any function of contract and have data bytes
await contract.sendTransaction({data: bytesData})

```

### Note
Be aware dangerous when use `delegatecall`

Another contract with the same order of variables can get delegation and  update each variable corresponding