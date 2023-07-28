// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol"

contract Lottery is Ownable {
    using Address for address payable;
    using SafeERC20 for IERC20;

    address public winner;
    uint256 public winnings;
    address[] private ticketHolders;
    address[] public uniqueTicketHolders;
    mapping(address => uint256) public ticketsHeld;
    uint256 public totalTicketsHeld;
    bool public isLotteryLive;

    uint256 public lotteryID;
    uint256 public maxEntries;
    uint256 public minEntriesToBeWinnable;
    uint256 public entryFee;
    uint256 public endTime;

    constructor (uint256 _lotteryID, uint256 _entryFee, uint256 _minEntriesToBeWinnable, uint256 _maxEntries, uint256 _endTime) {
        lotteryID = _lotteryID;
        entryFee = _entryFee;
        minEntriesToBeWinnable = _minEntriesToBeWinnable;
        maxEntries = _maxEntries;
        endTime = _endTime;
    }

    receive() external payable {
        winnings += msg.value;
    }

    function buyTickets (address buyer, uint256 numberOfTickets) external onlyOwner {
        if (ticketsHeld[buyer] == 0)
            uniqueTicketHolders.push (buyer);

        ticketsHeld[buyer] += numberOfTickets;
        totalTicketsHeld += numberOfTickets;

        for (uint256 i = 0; i < numberOfTickets; i++)
            ticketHolders.push (buyer);
    }

    function setEndTime (uint256 newEndTime) external onlyOwner {
        endTime = newEndTime;
    }

    function startLottery() external onlyOwner {
        isLotteryLive = true;
    }

    function declareWinner (uint256 random) external onlyOwner returns (address) {
        isLotteryLive = false;
        uint256 index = random % ticketHolders.length;
        winner = ticketHolders[index];
        payable(winner).sendValue (address(this).balance);
        return winner;
    }

    function getUniqueTicketHolders() external view onlyOwner returns (address[] memory) {
        return uniqueTicketHolders;
    }

    function withdrawTokens (address token, address account) external onlyOwner {
        require (token != address (0), "LotteryGenerator: can't withdraw token of zero address");

        uint256 tokenBalance = IERC20(token).balanceOf (address(this));

        if (tokenBalance > 0)
            IERC20(token).safeTransfer (account, tokenBalance);
    }

    function withdrawEth (address account) external onlyOwner {
        require (address(this).balance > 0, "LotteryGenerator: No Eth to withdraw");
        payable(account).sendValue (address(this).balance);
    }
}
