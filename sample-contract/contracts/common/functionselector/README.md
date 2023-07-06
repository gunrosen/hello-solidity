### Function Selector
[Link](https://docs.soliditylang.org/en/v0.8.15/abi-spec.html#abi)

It is the first (left, high-order in big-endian) four bytes of the Keccak-256 hash of the signature of the function.

The signature is defined as the canonical expression of the basic prototype without data location specifier, i.e. the function name with the parenthesised list of parameter types. 

Parameter types are split by a single comma - no spaces are used. The return type of a function is not part of this signature

```javascript
web3.utils.sha3("handleTransaction(address,bytes)")
```


### Function selector and argument encoding

```solidity
contract Foo {
    function bar(bytes3[2] memory) public pure {}
    function baz(uint32 x, bool y) public pure returns (bool r) { r = x > 32 || y; }
    function sam(bytes memory, bool, uint[] memory) public pure {}
}
```

```text
CALL baz(69,true)
we would pass 68 bytes total = 
0xcdcd77c0  METHOD_ID 4 bytes signature of `baz(uint32,bool)`
0x0000000000000000000000000000000000000000000000000000000000000045 values 69 but in 32 bytes padded
0x0000000000000000000000000000000000000000000000000000000000000001 values true with 32 bytes padded
```

```text
CALL bar(["abc", "def"])
we would pass 68 bytes total
0xfce353f6  METHOD_ID 4 bytes signature of `bar(bytes3[2])`
0x6162630000000000000000000000000000000000000000000000000000000000  a bytes3 value "abc" (left-aligned).
0x6465660000000000000000000000000000000000000000000000000000000000  a bytes3 value "def" (left-aligned).
```

```text
CALL sam("dave", true, [1,2,3])
we would pass 292 bytes
0xa5643bf2  METHOD_ID 4 bytes signature of `sam(bytes,bool,uint256[])` unit replaced by uint256

0x0000000000000000000000000000000000000000000000000000000000000060   location of the data part of the first parameter (dynamic type)  measured in bytes from the start
```