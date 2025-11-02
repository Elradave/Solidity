//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

contract Whitelist {
    uint public wlCount;
    mapping(address => bool) public checkWhiteList;
    mapping(address => uint) nftCount; 
    uint public totalSupply = 10;
    uint private mintPrice = 2 ether;
    address private deployer;

    receive() external payable{}

    constructor() {
        deployer = msg.sender;
    }

    function whiteList(address _adr) public {
        require(msg.sender == deployer, "You are not the owner");
        require(checkWhiteList[_adr] == false, "Error!! Wallet already whitelisted");
        checkWhiteList[_adr] = true;
        wlCount++;
    }
    function removeWhiteList(address _adr) public {
        require(msg.sender == deployer, "You are not the owner");
        require(checkWhiteList[_adr] == true, "Error!! Wallet not Whitelisted");
        checkWhiteList[_adr] = false;
        wlCount--;
    }

    function withdrawETH() public {
        require(msg.sender == deployer, "Only Deployer can withdraw");
        require(address(this).balance != 0, "No ETH to sell");
        payable(msg.sender).transfer(address(this).balance);
    }

    function mintNFT() public payable{
        require(checkWhiteList[msg.sender] == true, "Error!! You are not whitelisted");
        require(msg.value == 2 ether, "You need to pay 2 ETH to Mint");
        require(nftCount[msg.sender] < 1, "You already own this NFT");
        require(totalSupply > 0, "No NFTS left to mint");
        totalSupply --;
        nftCount[msg.sender]++;
    }

    function transferNFT(address _adr) public {
        require(nftCount[msg.sender] > 0, "You don't have the NFT");
        nftCount[msg.sender]--;
        nftCount[_adr]++;
    }

    function sellNFT() public {
        require(nftCount[msg.sender] > 0, "Error!! No NFT found to sell");
        nftCount[msg.sender]--;
        totalSupply ++;
        payable(msg.sender).transfer(mintPrice);
    }

    function myNFT() public view returns(uint){
        return nftCount[msg.sender];
    }

}
