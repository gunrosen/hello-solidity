### We have 02 APIS to interact with a smart contract
web3 api
* eth_call
* eth_sendTransaction

### In the nutshell
* If you want to write to the blockchain (i.e data writes or updates), you should use the Transaction API to execute a non-view function.
* If you want to read data from the blockchain (read from smart contract storage or read result of a computation), you should use the Call API to execute a view function

for example
```solidity

//web3
const result = await myContractInstance.methods.foo(1).call({from: '0xAb89...'});

//Solidity smart contract

function foo(uint a) view external returns(bool) {
  //do something
  return true;
}
```

```solidity
//web3
const result = await myContractInstance.methods.bar(1).send({from: '0xAb89...'}); //send() instead of foo()

//Solidity smart contract   
function bar(uint a) external { //no "view" keyword
  //do something
  //No return statement
}
```

### Notes
non-views function will not return anything