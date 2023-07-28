// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Source: https://marduc812.com/2021/04/08/how-to-save-gas-in-your-ethereum-smart-contracts/
contract SaveGas {
    uint8 result8 = 0;
    uint256 result256 = 0;

    function UseUint() external returns (uint256) {
        uint256 selectedRange = 50;
        for (uint256 i = 0; i < selectedRange; i++) {
            result256 += 1;
        }
        return result256;
    }

    function UseUInt8() external returns (uint8) {
        uint8 selectedRange = 50;
        for (uint8 i = 0; i < selectedRange; i++) {
            result8 += 1;
        }
        return result8;
    }
}