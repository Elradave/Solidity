//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

contract SmartMoney {
    
    uint public received;
    address owner;

    constructor() {
        owner = msg.sender;
    }

    function deposit() public payable{
        received = msg.value;
    }

    function contractBalance() public view returns(uint){
        return address(this).balance;
    }

    function withdraw(uint _amount, address payable to) public {
        if(msg.sender == owner){
            to.transfer(_amount);
        } else {
            revert ("Error!!! You are not the owner");
        }
        
    }

    function withdrawAll(address payable to) public {
        if(msg.sender == owner){
            to.transfer(contractBalance());
        } else {
            revert ("Error!!! You are not the owner");
        }
        
    
    }
}
