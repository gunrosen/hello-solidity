### ERC-1271 standard signature validation method for contracts
Standard way to verify a signature when the account is a smart contract

```text
EOA user account can sign messages with private key. But contract cannot
```


[EIP-1271](https://eips.ethereum.org/EIPS/eip-1271) propose a standard way for any contracts to verify a signature on a behalf of a given contract is valid

Should implement `isValidSignature(hash, signature)` function on the signing contract, which can be called to validate a signature

### Reality example
An application that requires signatures to be provided would be decentralized with off-chain orderbook 
where buy/sell orders are signed messages.

EOA sign orders that they want to buy/sell a given asset

EOA give explicit permission to the exchange smart contract to conclude a trade via as signature

When it comes to contracts, however, regular signature are not possible since contract do not process a private key

Or
```text
You want to logging into a dapp using the smart contract.
```
![img.png](contracts/common/signing/eip1271/img.png)

### Implementation

```solidity
pragma solidity ^0.5.0;

contract ERC1271 {

  // bytes4(keccak256("isValidSignature(bytes32,bytes)")
  bytes4 constant internal MAGIC_VALUE = 0x1626ba7e;

  /**
   * @dev Should return whether the signature provided is valid for the provided hash
   * @param _hash      Hash of the data to be signed
   * @param _signature Signature byte array associated with _hash
   *
   * MUST return the bytes4 magic value 0x1626ba7e when function passes.
   * MUST NOT modify state (using STATICCALL for solc < 0.5, view modifier for solc > 0.5)
   * MUST allow external calls
   */ 
  function isValidSignature(
    bytes32 _hash, 
    bytes memory _signature)
    public
    view 
    returns (bytes4){
      // Omitted the implementation of recoverSigner
      if (recoverSigner(_hash, _signature) == owner) {
          return MAGIC_VALUE;
      } else {
          return 0xffffffff;
      }
  }
}
```


### SignatureChecker.sol [Openzepplin](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/SignatureChecker.sol#L24-L29) that fits for EOA and AA 

```solidity
    /**
     * @dev Checks if a signature is valid for a given signer and data hash. If the signer is a smart contract, the
     * signature is validated against that smart contract using ERC1271, otherwise it's validated using `ECDSA.recover`.
     *
     * NOTE: Unlike ECDSA signatures, contract signatures are revocable, and the outcome of this function can thus
     * change through time. It could return true at block N and false at block N+1 (or the opposite).
     */
    function isValidSignatureNow(address signer, bytes32 hash, bytes memory signature) internal view returns (bool) {
        (address recovered, ECDSA.RecoverError error, ) = ECDSA.tryRecover(hash, signature);
        return
            (error == ECDSA.RecoverError.NoError && recovered == signer) ||
            isValidERC1271SignatureNow(signer, hash, signature);
    }

    /**
     * @dev Checks if a signature is valid for a given signer and data hash. The signature is validated
     * against the signer smart contract using ERC1271.
     *
     * NOTE: Unlike ECDSA signatures, contract signatures are revocable, and the outcome of this function can thus
     * change through time. It could return true at block N and false at block N+1 (or the opposite).
     */
    function isValidERC1271SignatureNow(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal view returns (bool) {
        (bool success, bytes memory result) = signer.staticcall(
            abi.encodeCall(IERC1271.isValidSignature, (hash, signature))
        );
        return (success &&
        result.length >= 32 &&
        abi.decode(result, (bytes32)) == bytes32(IERC1271.isValidSignature.selector));
    }
```

Permit1155
```solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "./EIP712WithNonce.sol";

abstract contract Permit1155 is EIP712WithNonce {
    bytes32 private immutable _PERMIT1155_TYPEHASH = keccak256("Permit1155(address registry,uint256 tokenid,address to,uint256 value,uint256 nonce,uint256 deadline,address relayer,bytes data)");

    function transfer1155WithSign(
        IERC1155 registry,
        uint256 tokenId,
        address from,
        address to,
        uint256 value,
        uint256 nonce,
        uint256 deadline,
        address relayer,
        bytes memory data,
        bytes memory signature
    )
        external
    {
        require(block.timestamp <= deadline, "NFTPermit::transfer1155WithSign: Expired deadline");
        require(relayer == address(0) || relayer == msg.sender);
        _verifyAndConsumeNonce(from, nonce);
        require(
            SignatureChecker.isValidSignatureNow(
                from,
                _hashTypedDataV4(keccak256(abi.encode(
                    _PERMIT1155_TYPEHASH,
                    registry,
                    tokenId,
                    to,
                    value,
                    nonce,
                    deadline,
                    relayer,
                    keccak256(data)
                ))),
                signature
            ),
            "NFTPermit::transfer1155WithSign: Invalid signature"
        );

        registry.safeTransferFrom(from, to, tokenId, value, data);
    }
}

```


### Piece of javascript code  to verify signatures works both EOA and Smart contract wallet
```javascript

// importing the required modules from ethers.js
const { providers, utils, Contract } = require("ethers");

// importing ABI for interface of ERC1271 so we can call the `isValidSignature` function
const IERC1271Abi = [{"inputs":[{"internalType":"address[]","name":"addrs","type":"address[]"}],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"to","type":"address"},{"indexed":false,"internalType":"uint256","name":"value","type":"uint256"},{"indexed":false,"internalType":"bytes","name":"data","type":"bytes"},{"indexed":false,"internalType":"bytes","name":"returnData","type":"bytes"}],"name":"LogErr","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"addr","type":"address"},{"indexed":false,"internalType":"bytes32","name":"priv","type":"bytes32"}],"name":"LogPrivilegeChanged","type":"event"},{"stateMutability":"payable","type":"fallback"},{"inputs":[{"components":[{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"value","type":"uint256"},{"internalType":"bytes","name":"data","type":"bytes"}],"internalType":"struct Identity.Transaction[]","name":"txns","type":"tuple[]"},{"internalType":"bytes","name":"signature","type":"bytes"}],"name":"execute","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"components":[{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"value","type":"uint256"},{"internalType":"bytes","name":"data","type":"bytes"}],"internalType":"struct Identity.Transaction[]","name":"txns","type":"tuple[]"}],"name":"executeBySelf","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"components":[{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"value","type":"uint256"},{"internalType":"bytes","name":"data","type":"bytes"}],"internalType":"struct Identity.Transaction[]","name":"txns","type":"tuple[]"}],"name":"executeBySender","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes32","name":"hash","type":"bytes32"},{"internalType":"bytes","name":"signature","type":"bytes"}],"name":"isValidSignature","outputs":[{"internalType":"bytes4","name":"","type":"bytes4"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"nonce","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"privileges","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"addr","type":"address"},{"internalType":"bytes32","name":"priv","type":"bytes32"}],"name":"setAddrPrivilege","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes4","name":"interfaceID","type":"bytes4"}],"name":"supportsInterface","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"pure","type":"function"},{"inputs":[{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"tipMiner","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"value","type":"uint256"},{"internalType":"bytes","name":"data","type":"bytes"}],"name":"tryCatch","outputs":[],"stateMutability":"nonpayable","type":"function"},{"stateMutability":"payable","type":"receive"}]

// This is a constant magic value defined in EIP-1271 that's returned when the signature is valid
const MAGICVALUE = 0x1626ba7e;

// function to check if a signature is valid
const isValidSignature = async (signingAddress, message, signature) => {
  const hash = utils.hashMessage(message); // hash the message
  const apiKey = "demo" // replace with your Alchemy API key for the network you are verifying the signature for, in this case Polygon Mainnet
  const provider = new providers.JsonRpcProvider(
    `https://polygon-mainnet.g.alchemy.com/v2/${apiKey}`
  ); // get your provider
  const bytecode = await provider.getCode(signingAddress); // get the bytecode
  const isSmartContract = bytecode && utils.hexStripZeros(bytecode) !== "0x"; // check if it is a smart contract wallet

  if (isSmartContract) {
    // verify the message for a decentralized account (contract wallet)
    const contractWallet = new Contract(signingAddress, IERC1271Abi, provider); // make an instance for the contact wallet
    const verification = await contractWallet.isValidSignature(hash, signature); // verify if the signature is valid using the `isValidSignature` function
    console.log("Message is verified?", verification === MAGICVALUE); // log if the signature is valid
    return verification === MAGICVALUE; // return true or false based on if the signature is valid or not
  } else {
    // verify the message for an externally owned account (EOA) using the recovery algorithm
    const sig = ethers.utils.splitSignature(signature);
    const recovered = await contract.verifyHash(hash, sig.v, sig.r, sig.s);
    console.log("Message is verified?", recovered === signingAddress);
    return recovered === signingAddress;
  }
};

async function main() {
  let isValid = await isValidSignature(
    "0x4836a472ab1dd406ecb8d0f933a985541ee3921f",
    "0x787177",
    "0xc0f8db6019888d87a0afc1299e81ef45d3abce64f63072c8d7a6ef00f5f82c1522958ff110afa98b8c0d23b558376db1d2fbab4944e708f8bf6dc7b977ee07201b00"
  );

  console.log(isValid);
}

main();
```


