// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract SmartWallet{
    address payable public owner;
    constructor(){
        owner = payable(msg.sender);
    }
    
    uint public spenders;
    mapping(address => bool) canSpend;
    mapping(address => uint) spendLimit;
    address[] public guardians;
    uint public guardianNum;

    mapping(address => uint) public guardianApprovals;
    mapping(address => mapping(address => bool)) public hasVoted;

    receive() external payable{}

    function checkBalance() public view returns(uint){
        return address(this).balance;
    }

    function sendETH(address payable _to, uint _amount) public {
        require(msg.sender == owner || canSpend[msg.sender] == true, "You are not the owner/spender");
        require(_amount <= checkBalance(), "Insufficient funds");
        if(msg.sender != owner){
            require(_amount <= spendLimit[msg.sender], "Amount exceeds your limit");
            spendLimit[msg.sender] -= _amount;
        }
        
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Transaction failed, Aborting...");
        
        
    }

    function setSpender(address payable _adr, uint _limit) public {
        require(msg.sender == owner, "You are not the owner");
        require(spenders < 5, "Max number of spenders reached");
        spendLimit[_adr] = _limit;
        canSpend[_adr] = true;
        spenders ++;
    }

    function removeSpender(address payable _adr) public {
        require(msg.sender == owner, "You are not the owner");
        require(canSpend[_adr] == true, "This wallet is not a spender");
        canSpend[_adr] = false;
        spendLimit[_adr] = 0;
        spenders --;
    }

    function setGuardian(address payable _adr) public {
        require(msg.sender == owner, "You are not the owner");
        if(guardians.length < 5){
            guardians.push(_adr);
            guardianNum ++;
    
        } else {
            revert("Max Guardian Reached");
        }
    }
    function isGuardian(address _adr) internal view returns (bool) {
        for (uint i = 0; i < guardians.length; i++) {
            if (guardians[i] == _adr) {
            return true;
            }
        }
        return false;
    }

    function removeGuardian(address payable _adr) public {
        require(msg.sender == owner, "You are not the owner");
        if (isGuardian(_adr) == true){
            for (uint i = 0; i < guardians.length; i++) {
                if (guardians[i] == _adr) {
                    guardians[i] = guardians[guardians.length - 1];
                    guardians.pop();
                    guardianNum --;
                }

            }
        } else {
            revert("This address is not a guardian");
        }
    }


    function setNewOwner(address payable _adr) public {
        
        require(msg.sender == owner || isGuardian(msg.sender) == true, "You are not the owner or a guardian");
        require(hasVoted[msg.sender][_adr] == false, "You have already voted");
        guardianApprovals[_adr] ++;
        hasVoted[msg.sender][_adr] = true;
        
        if(guardianApprovals[_adr] >= 3 ){
            owner = _adr;
            guardianApprovals[_adr] = 0;

            for(uint i = 0; i < guardians.length; i++){
                hasVoted[guardians[i]][_adr] = false;
            }
        } 
    }

}

// To test if it can send to contracts and not only EOA
contract ReceiveETH{
    function checkBal() public view returns(uint){
        return address(this).balance;
    }
    receive() external payable{}
}
