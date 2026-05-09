// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/* This is Just a Dumb contract to show you that you should never relay on any other user/contract 
 * to behave expectedly. If you give the other person/contract control of the execution then they can definitely
 * do some malicious activity. 
 * Instead of this, allow the user to withdraw funds by themselves individually.
 */

contract victim {
    address[] public account;
    address owner;
    constructor(address _owner){
        owner = _owner;
    }
    function withdrawAll() public onlyOwner {
        uint256 max = account.length;
        for(uint i = 0; i < max; i++){ 
           (bool success, ) = payable(account[i]).call{value: 0.01 ether}("");
        
           require(success, "Withdrawal Fail");
        }
        delete account;
    }

    function deposit() public payable  {
        require(msg.value >= 0.01 ether, "Only 0.01 ether allowed");
        account.push(msg.sender);
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner Function");
        _;
    }
}
