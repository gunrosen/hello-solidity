### Solidity code to send ether

Beside seftdestruct, Solidity provides 03 different methods to send an amount of ETH from an account to another

#### 1. receiverAddress.transfer(amount)
Consumes 2300 gas and send amount of Ether from the caller to `receiverAddress`.

Transfer fails and reverts on failure if 
- sender not have much ether (compare with amount)
- ether transfer rejected by receiving account (=> receiver can be an contract that rejected any ethers sent to it)

#### 2. receiverAddress.send(amount)
Consumes 2300 gas and send amount of Ether from the caller to `receiverAddress`.
Send is low-level of `transfer`. But if execution fails, the current contract will not stop with an exception, but return `false`

#### 3. (bool sent, bytes memory data) = receiverAddress.call{value: amount}("");
It is low-level function with alot flexibility but introduces also numberous possible problems like re-entrancy

By default, `call` forwards the whole gas if you don't specify it

If `call` failes, `sent = false`

Problem of re-entrancy comes because if not limit gas fee. Otherwise, `send` specifies 2300 gas to perform transaction.
That means `call` with unlimited transaction gas fee, so it can call multiple until account balance becomes 0