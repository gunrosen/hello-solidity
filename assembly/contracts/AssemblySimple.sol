// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// The language used for inline assembly in Solidity is called Yul
// https://docs.soliditylang.org/en/v0.8.19/yul.html#yul

contract AssemblySimple {
    // Yul haves for, if , switch  and function calls
    // currently, have only EVM dialect
    constructor(){

    }

    function addAssembly(uint x, uint y) public pure returns (uint) {
        assembly {
        // Add some code here
            let result := add(x, y)
            mstore(0x0, result)
            return (0x0, 32)
        }
    }

    function addSolidity(uint x, uint y) public pure returns (uint) {
        return x + y;
    }

    function add(uint x, uint y) public pure returns (uint) {
        assembly{
            let result := add(x, y)   // x+ y
            mstore(0x0, result)
            return (0x0, 32)
        }
    }

    function exponentialFunction(uint n, uint value) public pure returns (uint) {
        assembly{
            for {let i := 0} lt(i, n) {i := add(i, 1)} {
                value := mul(2, value)
            }
            mstore(0x0, value)
            return (0x0, 32)
        }
    }
}
