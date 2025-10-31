//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

contract MiniBank {
    receive() external payable{}
    mapping(address => uint256) public checkBalance;
    address public userID;

    function deposit() public payable{
        
        if(msg.value > 0){
            checkBalance[msg.sender] += msg.value;
            userID = msg.sender;
            
            
        } else {
            revert ("Insufficient Funds, Please fund your wallet with ETH");
        }
        
    }

    function withdraw(uint _amount) public{
        if(_amount <= walletBalance()){
            checkBalance[msg.sender] -= _amount;
            userID = msg.sender;
            payable(msg.sender).transfer(_amount);
        } else {
            revert ("Insufficient funds");
            }
       
    }

    function walletBalance() public view returns(uint){
        return checkBalance[msg.sender];
    }

    function contractBalance() public view returns(uint){
        return address(this).balance;
    }
}
