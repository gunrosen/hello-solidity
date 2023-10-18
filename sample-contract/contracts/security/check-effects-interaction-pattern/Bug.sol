// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// THIS CONTRACT CONTAINS A BUG - DO NOT USE
contract Bug {
    /// Mapping of ether shares of the contract.
    mapping(address => uint) shares;
    /// Withdraw your share.
    function withdraw() public {
        var share = shares[msg.sender];
        shares[msg.sender] = 0;  // effects before interact
        msg.sender.transfer(share);
    }
}
