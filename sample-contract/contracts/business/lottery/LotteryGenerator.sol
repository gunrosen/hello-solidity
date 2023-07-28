// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
// REF: https://bscscan.com/address/0xd0b2EBA539642f54Ea2fbd77e56ec31741C6c413#code
import "@openzeppelin/contracts/access/Ownable.sol";
import " @chainlink/contracts/src/v0.8/dev/VRFConsumerBase.sol"
impport Lottery from "./Lottery.sol"

contract LotteryGenerator is VRFConsumerBase, Ownable {
    using Address for address payable;
    using SafeERC20 for IERC20;

    Lottery[] public lotteries;

    uint256 public entryFee = 1 ether / 100; // 0.01 BNB
    uint256 public maxEntries = 25;
    uint256 public minEntriesToBeWinnable = 26;
    address public treasuryWallet = address(0xF5eE9E042C58dBDA507E831EA1e2e581F435669a); //Receives Lottery Fee

    enum LotteryState { NOT_STARTED, STARTED, ENDED }
    LotteryState currentLotteryState = LotteryState.NOT_STARTED;
    uint256 public currentLotteryID;
    Lottery public currentLottery;

    uint256 public lastLotteryResultReturned;
    bytes32 public keyHash = 0xc251acd21ec4fb7f31bb8868288bfdbaeb4fbfec2df3735ddbd4f7dc8d60103c;
    bytes32 public latestRequestId;
    uint256 public linkFee = 200000000000000000;
    uint256 public lotteryResult;

    event LotteryCreated (address lotteryAddress, uint256 lotteryID);
    event EntryFeeUpdated (uint256 oldFee, uint256 newFee);
    event TreasuryWalletUpdated (address oldTreasuryWallet, address newTreasuryWallet);
    event MaxEntriesUpdated (uint256 oldMaxEntries, uint256 newMaxEntries);
    event MinEntriesToBeWinnableUpdated (uint256 oldMinEntriesToBeWinnable, uint256 newMinEntriesToBeWinnable);
    event LotteryWon (address indexed winner);

    constructor (address _vrfCoordinator, address _linkToken) VRFConsumerBase (_vrfCoordinator, _linkToken) {
        //
    }

    receive() external payable { }

    function createLottery (uint256 endTime) external payable onlyOwner {
        require (currentLotteryState == LotteryState.NOT_STARTED, "LotteryGenerator: Can't start a lottery whilst one is still in progress");
        //require (endTime > block.timestamp + 15 minutes, "LotteryGenerator: Lottery must last longer than 15 minutes"); //CHANGEME removed for testing
        require (endTime < block.timestamp + 1 weeks, "LotteryGenerator: Lottery must last less than one week");

        currentLotteryID = lotteries.length;
        currentLottery = new Lottery (currentLotteryID, entryFee, minEntriesToBeWinnable, maxEntries, endTime);
        lotteries.push(currentLottery);

        payable(address(currentLottery)).sendValue (msg.value);

        // event
        emit LotteryCreated (address(currentLottery), currentLotteryID);
    }

    function startLottery() external onlyOwner returns (bool) {
        require (currentLotteryState == LotteryState.NOT_STARTED, "LotteryGenerator: Can't start a lottery whilst one is still in progress");

        currentLotteryState = LotteryState.STARTED;
        currentLottery.startLottery();
        return true;
    }

    function endLottery (uint256 newEndTimeForFailedLottery) external onlyOwner returns (bool){
        require (currentLottery.endTime() < block.timestamp, "LotteryGenerator: Cannot end a lottery before its end time");
        require (currentLotteryState != LotteryState.ENDED, "LotteryGenerator: Lottery already ended and waiting for result");
        currentLotteryState = LotteryState.ENDED;

        if (currentLottery.totalTicketsHeld() < currentLottery.minEntriesToBeWinnable()) {
            //require (newEndTimeForFailedLottery > block.timestamp + 15 minutes, "LotteryGenerator: Lottery must last longer than 15 minutes"); //CHANGEME removed for testing
            require (newEndTimeForFailedLottery < block.timestamp + 1 weeks, "LotteryGenerator: Lottery must last less than one week");
            currentLottery.setEndTime (newEndTimeForFailedLottery);
            currentLotteryState = LotteryState.STARTED;
            return false;
        }

        getRandomNumber (uint256(keccak256 (abi.encodePacked (currentLotteryID, currentLottery.totalTicketsHeld(), address(currentLottery), block.timestamp))));
        return true;
    }

    function declareLottery() external onlyOwner {
        require (lastLotteryResultReturned == currentLotteryID, "LotteryGenerator: no result returned for current lottery yet");
        require (currentLotteryState == LotteryState.ENDED, "LotteryGenerator: cannot declare winner until lottery has ended");

        currentLotteryState = LotteryState.NOT_STARTED;
        address winner = currentLottery.declareWinner (lotteryResult);
        emit LotteryWon (winner);
    }

    function setEntryFee (uint256 newEntryFee) external onlyOwner {
        require (newEntryFee > 0, "LotteryGenerator: fee must be > 0");
        emit EntryFeeUpdated (entryFee, newEntryFee);
        entryFee = newEntryFee;
    }

    function setMinEntriesToBeWinnable (uint256 newMinEntriesToBeWinnable) external onlyOwner {
        emit MinEntriesToBeWinnableUpdated (minEntriesToBeWinnable, newMinEntriesToBeWinnable);
        minEntriesToBeWinnable = newMinEntriesToBeWinnable;
    }

    function setMaxEntries (uint256 newMaxEntries) external onlyOwner {
        require (newMaxEntries > 0, "LotteryGenerator: max entries per user must be > 0");
        emit MaxEntriesUpdated (maxEntries, newMaxEntries);
        maxEntries = newMaxEntries;
    }

    function setTreasuryWallet (address newTreasuryWallet) external onlyOwner {
        require (newTreasuryWallet != address(0), "LotteryGenerator: treasury wallet can't be the zero address");
        emit TreasuryWalletUpdated (treasuryWallet, newTreasuryWallet);
        treasuryWallet = newTreasuryWallet;
    }

    function getLotteryStats (uint256 lotteryID) public view returns (address lotteryAddress, address[] memory entrants, address winner, uint256 winnings, uint256 ticketsHeld, uint256 endTime, bool isLive) {
        require (lotteryID < lotteries.length, "LotteryGenerator: No lottery with that ID exists");
        lotteryAddress = address(lotteries[lotteryID]);
        winner = lotteries[lotteryID].winner();
        winnings = lotteries[lotteryID].winnings();
        ticketsHeld = lotteries[lotteryID].totalTicketsHeld();
        isLive = lotteries[lotteryID].isLotteryLive();
        endTime = lotteries[lotteryID].endTime();
        entrants = lotteries[lotteryID].getUniqueTicketHolders();
    }

    function enterLottery() public payable returns (uint256 numberOfTicketsBought) {
        require (currentLottery.endTime() >= block.timestamp, "LotteryGenerator: Lottery has expired");
        require (currentLotteryState == LotteryState.STARTED, "LotteryGenerator: Lottery can't be entered");
        uint256 maxTickets = currentLottery.maxEntries();
        uint256 feePerTicket = currentLottery.entryFee();
        numberOfTicketsBought = msg.value / feePerTicket;

        if (numberOfTicketsBought > maxTickets)
            numberOfTicketsBought = maxTickets;


        require (currentLottery.ticketsHeld(msg.sender) + numberOfTicketsBought <= maxTickets, "LotteryGenerator: user has bought too many tickets");

        uint256 rrp = feePerTicket * numberOfTicketsBought;

        // return any overpayment
        if (rrp < msg.value)
            payable(msg.sender).sendValue (msg.value - rrp);

        payable(treasuryWallet).sendValue (rrp);
        currentLottery.buyTickets (msg.sender, numberOfTicketsBought);
    }


    function getRandomNumber (uint256 seed) internal {
        require (keyHash != bytes32(0), "LotteryGenerator: Must have valid key hash");
        require (LINK.balanceOf (address(this)) >= linkFee, "LotteryGenerator: Not enough LINK tokens");

        latestRequestId = requestRandomness (keyHash, linkFee, seed);
    }

    function fulfillRandomness (bytes32 requestId, uint256 randomness) internal override {
        require (latestRequestId == requestId, "LotteryGenerator: Wrong requestID");
        lotteryResult = randomness;
        lastLotteryResultReturned = currentLotteryID;
    }

    function withdrawTokens (address token) external onlyOwner {
        require (token != address (0), "LotteryGenerator: can't withdraw token of zero address");

        uint256 tokenBalance = IERC20(token).balanceOf (address(this));

        if (tokenBalance > 0)
            IERC20(token).safeTransfer (owner(), tokenBalance);
    }

    function withdrawEth() external onlyOwner {
        require (address(this).balance > 0, "LotteryGenerator: No Eth to withdraw");
        payable(owner()).sendValue (address(this).balance);
    }

    function withdrawTokens (address token, uint256 lotteryID) external onlyOwner {
        require (lotteryID < lotteries.length, "LotteryGenerator: Lottery ID does not exist");
        lotteries[lotteryID].withdrawTokens (token, owner());
    }

    function withdrawEth (uint256 lotteryID) external onlyOwner {
        require (lotteryID < lotteries.length, "LotteryGenerator: Lottery ID does not exist");
        lotteries[lotteryID].withdrawEth (owner());
    }
}
