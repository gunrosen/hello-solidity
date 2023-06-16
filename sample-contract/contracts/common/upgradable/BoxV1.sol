// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract BoxV1 is Initializable {
    uint256 public x;

    function __Box_init(uint256 _x) public initializer {
        x = _x;
    }

    function sum() public view returns(uint256) {
        return x;
    }
}