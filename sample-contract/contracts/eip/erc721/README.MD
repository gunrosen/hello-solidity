### 1. Two types of account
EOA = Externally Owned Account (user account)
Contract Accounts

### 2. How we transfer assets via blockchain
#### 2.1. Native token 
Can be transferred between accounts

If a contract need to receive ETH, it should implement `receive()` or have function marked with `payable`

#### 2.2. ERC20 token 
If following to ERC20 of Openzepplin, it can be transferred without other implementation

#### 2.3. ERC721 token
User account applied transfer without other implementation

If receiver is a contract, 02 options for him

* Use function `transferFrom(address from, address to, uint256 tokenId)` , it is free to receive NFT

* Use function `safeTransferFrom(address from, address to, uint256 tokenId)` or `safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data)`, this contract must implement function `onERC721Received()`

The purpose of this function is to ensure NFT appearance in the contract. Contract will use NFT and NFT will not be locked in contract
```solidity
function onERC721Received(
                address,
                address,
                uint256,
                bytes calldata
            ) external pure returns (bytes4) {
                return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")
);
}
```

Because in `safeTransferFrom`, it has check `_checkOnERC721Received()` in that it compares hash of function name and parameters
```solidity
_ERC721_RECEIVED = bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) = 0x150b7a02
```

#### 2.4. ERC1155 token
With ERC1155, we will have 10 items of tokenId=0. Like that, 10 items with the same characteristics of tokenId=0

Same with ERC721 but we can another for batching transfer
```solidity
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external override returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            );
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external override returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                )
            );
    }
```

### 3. Other notes
#### 3.1. About receiver() and fallback()
```text
receive is a new keyword in Solidity 0.6.x that is used as a fallback function that is only able to receive ether.

receive() external payable — for empty calldata (and any value)
fallback() external payable — when no other function matches (not even the receive function). Optionally payable.
```

#### 3.2. bytes data in Received()
We can push function in `onERC721Received` to perform calldata 

For example: Make another call when receive NFT. We can make the flow that contract receive NFT from user1 then transfer it to user2 right after receiving it.
```solidity
   function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        msg.sender.call(data);
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }
```

```javascript

 let data = erc721.interface.encodeFunctionData('transferFrom', [
      receiverERC721_2.address,
      user2.address,
      tokenId
    ]);

    await erc721
      .connect(user1)
      .functions['safeTransferFrom(address,address,uint256,bytes)'](
        user1.address,
        receiverERC721_2.address,
        tokenId,
        data
      );
```





