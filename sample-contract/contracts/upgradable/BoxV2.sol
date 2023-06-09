// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract BoxV2 is Initializable {
    uint256 public x;
    uint256 public y;

    function __Box_init(uint256 _x) public initializer {
        x = _x;
        y = _x;
    }

    function sum() public view returns (uint256) {
        return x + y;
    }

    function reveal() public pure returns (string memory) {
        return "Hello world";
    }

    function moreWork() public pure returns (uint) {
        return 100;
    }
}