# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.ts
```

# YUL
```
https://docs.soliditylang.org/en/v0.8.19/yul.html#yul
```


EVM dialect
```
https://docs.soliditylang.org/en/v0.8.19/yul.html#evm-dialect
```

Opcode can be divided into the following categories

![img.png](img/img.png)


4 opcodes related to bytecode of a contract 
```
codesize, codecopy: enable you to read/copy the bytecode of contract we are currently executing
``` 

```
extcodesize, extcodecopy: enable read/copy bytecode of another external contract from a contract
```