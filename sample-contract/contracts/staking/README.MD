### 1. Inbuilt libraries, user can re-use this code

Solidity has some inbuilt libraries for the ease of the users. Some of the libraries are listed below : 

* Modular network: This includes many modular libraries that are very useful for implementation like ArrayUtils, Token, CrowdSale, Vesting, StringUtils, LinkedList, Wallet, etc.
 
[Link Modular network](https://github.com/modular-network/ethereum-libraries)

* OpenZeppelin: other supporting libraries are Roles, MerkleProof, ECDSA, Math, Address, SafeERC20, ERC165Checker, SafeMath, Arrays, etc which protects from overflow.

* Dapp-bin: Created by Ethereum includes interesting and useful libraries like DoublyLinkedList, StringUtils, IterableMapping, etc.


### 2. Use libraries

#### 2.1 Using import
Compiler will copy code in the file directly into smart contract
```solidity
pragma solidity ^0.8.6;

//if your library is in another file you can import it into the contract
import LibraryName from “./libraryfile.sol”;

or
//to import all libraries in the file use the pattern below
import "./libraryfile.sol";
```

#### 2.2 Library code directly in the contract
```solidity
 using LibraryName for type;
 ```

for Example 
```solidity
using MathLibrary for uint;
```


### 3. Deploy libraries
Embed a lib in a contract: if library only `internal` functions

Link a lib to a contract: if a library has `public` or `external` then it can be deployed separately.

