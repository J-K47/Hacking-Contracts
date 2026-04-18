// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

contract Victum {
    mapping(address => uint256) public balances;

    function depositETH() public payable {
        require(msg.value > 0, "Enter Enough Amount");
        balances[msg.sender] += msg.value;
    }

    function withdrawETH(uint256 amount) public {
        require(amount <= balances[msg.sender], "Not Enough Amount");
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Call Failed");
        balances[msg.sender] -= amount;
    }
}
