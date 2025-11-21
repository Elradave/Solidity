//SPDX-License-Identifier: MIT
// People can buy $REAL, $RL
// Token supply 100_000_000
// Tax 50% at start, can be reduced manually by contract deployer
pragma solidity ^0.8.14;
import "contracts/Owner.sol";

contract Token$RL is Ownable {
    receive() external payable{}
    string constant public tokenName = "$REAL";
    string constant public tokenSymbol = "$RL";
    uint public tokenPrice = 2 ether;
    uint public buyTax = 50;
    mapping(address => uint) balance;
    mapping(address => uint) taxCollected;
    event tokenBuy(address _adr, uint _amount, uint _received);
    event taxUpdate(uint _tax);
    event tokenSale(address _adr, uint _amount);
    address alpha = 0x583031D1113aD414F02576BD6afaBfb302140225;
    address beta = 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB;
    address omega = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C;
    

    function buyToken() public payable {
        require(msg.value >= tokenPrice, "Please fund your wallet with eth");
        if(msg.value == 0){
            revert("Please enter a valid amount of ETH");
        }
        uint token = msg.value / tokenPrice;
        uint taxAmount = (token * buyTax) / 100;
        taxCollected[msg.sender] += taxAmount;
        uint tokensToReceive = token - taxAmount;
        balance[msg.sender] += tokensToReceive;
        emit tokenBuy(msg.sender, token, tokensToReceive);
    }

    function sellTokens(uint _unit) public{
        require(balance[msg.sender] >= _unit, "Amount Exceeded!!, Buy Tokens");
        require(address(this).balance >= _unit * tokenPrice, "Contract lacks ETH");
        balance[msg.sender] -= _unit; 
        (bool success, ) = msg.sender.call{value: _unit * tokenPrice}("");
        require(success, "Transaction failed");
        emit tokenSale(msg.sender, _unit);
        
        
        uint usrTaxBal = taxCollected[msg.sender];
        if (usrTaxBal > 0) {
            uint taxEth = usrTaxBal * tokenPrice;
            (bool alpha1, ) = alpha.call{value: (taxEth * 45) / 100}("");
            require(alpha1, "Failed");
            (bool beta1, ) = beta.call{value: (taxEth * 45) / 100}("");
            require(beta1, "Failed");
            (bool omega1, ) = omega.call{value: (taxEth * 10) / 100}("");
            require(omega1, "Failed");

            taxCollected[msg.sender] = 0;
        }
    }

    function checkBalance() public view returns(uint) {
        return balance[msg.sender];
    }

    function setTax(uint _newTax) public isOwner(){
        require(_newTax < buyTax, "You cannot increase the Tax");
        require(_newTax <= 100, "Tax too high");
        buyTax = _newTax;
        emit taxUpdate(_newTax);
    }

}
