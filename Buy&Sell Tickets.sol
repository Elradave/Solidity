//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

contract EventTickets {
    mapping(address => uint) public ticket;
    uint public ticketPrice = 2 ether;
    uint ticketSold;

    receive() external payable{}

    function buyTicket() public payable{
        require(msg.value >= ticketPrice, "Insufficient Funds, Top up your balance with 2 ETH");
        require(ticket[msg.sender] < 5, "Max ticket reached");
        require(msg.value <= 10 ether, "You cannot buy more than 5 Tickets" );
        uint boughtTicket = msg.value/ticketPrice;
        ticket[msg.sender] += boughtTicket;
        ticketSold += boughtTicket;
    }

    function myTickets() public view returns(uint){
        return ticket[msg.sender];
    }

    function totalTicketsSold() public view returns(uint){
        return address(this).balance / ticketPrice;
    }

    function avail() public view returns(uint){
        return 5 - myTickets();
    }

    function transfer(address _adr, uint _no) public {
        require(ticket[msg.sender] >= _no, "You do not have enough tickets");
        ticket[msg.sender] -= _no;
        ticket[_adr] += _no;
    }
    function redeem(uint _numOfTickets) public {
        require(ticket[msg.sender] > 0, "You do not have any tickets to sell");
        require(ticket[msg.sender] >= _numOfTickets, "You do not have enough tickets");
        ticket[msg.sender] -= _numOfTickets;
        payable(msg.sender).transfer(_numOfTickets * ticketPrice);
    }
}
