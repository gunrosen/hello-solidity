// SPDX-License-Identifier: MIT
pragma solidity 0.5.0;

contract MultiSigWalletSimple {
    uint256 public nonce;     // (only) mutable state
    address[] public owners;  // immutable state

    constructor(address[] memory owners_) public {
        owners = owners_;
    }

    function transfer(
        address payable destination,
        uint256 value,
        bytes32[] calldata sigR,
        bytes32[] calldata sigS,
        uint8[] calldata sigV
    )
    external
    {
        bytes32 hash = prefixed(keccak256(abi.encodePacked(
                address(this), destination, value, nonce
            )));

        for (uint256 i = 0; i < owners.length; i++) {
            address recovered = ecrecover(hash, sigV[i], sigR[i], sigS[i]);
            require(recovered == owners[i]);
        }

        // If we make it here, all signatures are accounted for.
        nonce += 1;
        destination.transfer(value);
    }

    function () payable external {}

    // Builds a prefixed hash to mimic the behavior of eth_sign.
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(
                "\x19Ethereum Signed Message:\n32", hash));
    }
}
