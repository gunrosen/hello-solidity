### Opcodes

[Official docs in Ethereum](https://ethereum.org/en/developers/docs/evm/opcodes/)

[Opcodes explain](https://www.evm.codes/?fork=shanghai)

[Opcodes playground](https://www.evm.codes/playground)

[Opcodes gas](https://github.com/wolflo/evm-opcodes/blob/main/gas.md)


### Example 1. Create a contract that code size should only be 10 opcodes

And solver should return number of 42

42 is 0x2A

#### Push and store value 0x2a in memory

`PUSH1` = `0x60`

`MSTORE(p, v)`  p is position or offset , v is value. `MSTORE` expect value already stored in the memory

We need to push both the value and the position (where value is stored) into memory, therefore we will need 2 PUSH1 opcodes

```text
PUSH1(0x2a)  ->    0x602a
PUSH1(0x80)  ->    0x6080
MSTORE       ->    0x52 (Store value=0x2a at position v=0x80 in memory)
```

return the stored value. It is time to return the value using `RETURN(p,s)`

`RETURN(p,s)` p is offset or position of our data stored in the memory. s is length of our stored data. Therefore, we will again need 2 PUSH1 opcodes
```text
PUSH(0x20)   ->    0x6020 (Size of value is 32 bytes)
PUSH(0x80)   ->    0x6080 (Value was stored in slot 0x80)
RETURN       ->    0xf3 (Return value at p=0x80 slot and of size s=0x20)
```

Then obtain bytecode is
```text
602a60805260206080f3
```

#### Initialize opcode
It will be responsible for loading our runtime opcodes in memory and return it to the EVM

To copy code, we use `CODECOPY(t, f, s)`

- t: The destination offset where the code will be in memory. Let's save this to 0x00 offset
- f: This is the current position of the runtime opcode which is not known as of now.
- s: This is the size of the runtime code in bytes, i.e., 602a60805260206080f3 - 10 bytes long.

```text
PUSH1(0x0a)    ->  0x600a (`s=0x0a` or 10 bytes)
PUSH(0x??)     ->  0x60?? (`f` - This is not known yet)
PUSH(0x00)     ->  0x6000 (`t=0x00` - arbitrary chosen memory location)
CODECOPY       ->  0x39 (Calling the CODECOPY with all the arguments)
```

Now, to return the runtime opcode to EVM

```text
PUSH(0x0a)    -> 0x600a (Size of opcode is 10 bytes)
PUSH(0x00)    -> 0x6000 (Value was stored in slot 0x00)
RETURN        -> 0xf3 (Return value at p=0x00 slot and of size s=0x0a)
```

Initialization opcode will be `600a60__600039600a6000f3` - 12 bytes in total.
This means the missing `f` is index 12 or `0x0c`

So, Initialization is `600a600c600039600a6000f3`

Finally, all opcodes will be 

```text
602a60805260206080f3 + 600a600c600039600a6000f3 = 600a600c600039600a6000f3602a60505260206050f3
```

```solidity
    bytes memory code = "\x60\x0a\x60\x0c\x60\x00\x39\x60\x0a\x60\x00\xf3\x60\x2a\x60\x80\x52\x60\x20\x60\x80\xf3";
    address solver;

    assembly {
        solver := create(0, add(code, 0x20), mload(code))
    }
    level18.setSolver(solver);
```

create solver contract using `create` opcodes takes 3 inputs - value, offset, length.
Returns an address of the deployed contract which pass to `setSolver` 

```text
https://mumbai.polygonscan.com/address/0xbebf41f559de2c69bbb53cfaf92a7c75378cdf45#code
```




