// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// Sell the token and later comeback to buy
contract FixedPriceMarket {
    using SafeERC20 for IERC20;

    IERC20 tradingToken = 0x1234;
    uint256 price = 128;

    mapping(address => uint256) selling;

    function sell(uint256 tokenValue) {
        tradingToken.safeTransferFrom(msg.sender, this, tokenValue);
        selling[msg.sender] = selling[msg.sender].add(tokenValue);
    }

    function buy(address seller, uint256 tokenValue) {
        require(msg.value == tokenValue.mul(price));
        selling[seller] = selling[seller].sub(tokenValue);
        tradingToken.safeTransfer(msg.sender, tokenValue);
        seller.transfer(msg.value);
    }
}
