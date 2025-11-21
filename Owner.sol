//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

contract ReceiveFallback {
    uint public seeValue;
    string public receivedEth;
    receive() external payable{
        seeValue = msg.value;
        receivedEth = "You have received ETH";

    }
    function withDrawEth(uint _amount) public {
        payable(msg.sender).transfer(_amount);
    }
    function getBalance() public view returns(uint){
        return address(this).balance;
    }

}
