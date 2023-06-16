### Signed data standard
[ERC-191](https://eips.ethereum.org/EIPS/eip-191)

A `presigned` transaction called `RLPdata<nonce, gasPrice, startGas, to, value, data>, r,s and v`

ERC191 propose the following format for `signed_data`

```text
0x19 <1 byte version> <version specific data> <data to sign>.
initial 0x19 byte is intended to ensure that the signed_data is not valid RLP
```

```text
That means that any signed_data cannot be one RLP-structure
Thus, any EIP-191 signed_data can never be an Ethereum transaction.
```

The following is prepended before hashing in personal_sign:
```text
"\x19Ethereum Signed Message:\n" + len(message).
```

### Version byte
![img.png](contracts/common/signing/eip191/img.png)

Version `0x00`
```text
0x19 <0x00> <intended validator address> <data to sign>
```

Version `0x01`
```text
The version 0x01 is for structured data as defined in EIP-712
```

Version `0x45` **(E)**
```text
0x19 <0x45 (E)> <thereum Signed Message:\n" + len(message)> <data to sign>
The data to sign can be any arbitrary data.

```

### Example code
Version `0x00`
```solidity
function signatureBasedExecution(address target, uint256 nonce, bytes memory payload, uint8 v, bytes32 r, bytes32 s) public payable {
        
    // Arguments when calculating hash to validate
    // 1: byte(0x19) - the initial 0x19 byte
    // 2: byte(0) - the version byte
    // 3: address(this) - the validator address
    // 4-6 : Application specific data

    bytes32 hash = keccak256(abi.encodePacked(byte(0x19), byte(0), address(this), msg.value, nonce, payload));

    // recovering the signer from the hash and the signature
    addressRecovered = ecrecover(hash, v, r, s);
   
    // logic of the wallet
    // if (addressRecovered == owner) executeOnTarget(target, payload);
}
```