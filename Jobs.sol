//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

contract Jobs {

    struct Job {
        string description;
        address client;
        address freelancer;
        uint amount;
        bool completed;
        bool exists;
    }
    
    mapping(uint => Job) public jobsInfo;
    mapping(address => uint) private clientsJob;
    mapping(address => uint) private wallet;

    event JobPosted(uint jobId, address client);
    event JobAssigned(uint jobId, address freelancer);
    event JobCompleted(uint jobId);
    event PaymentReleased(uint jobId, address freelancer, uint amount);

    receive() external payable{}

    function depositETH() public payable{
        require(msg.value != 0, "Please Deposit some ETH");
        wallet[msg.sender] += msg.value;
    }

    function postJob(string memory _desc, uint _jobId, uint _amount) public{
        assert(wallet[msg.sender] >= _amount);
        require(jobsInfo[_jobId].exists == false, "This job already exists");
        jobsInfo[_jobId].description = _desc;
        jobsInfo[_jobId].client = msg.sender;
        jobsInfo[_jobId].amount = _amount;
        jobsInfo[_jobId].completed = false;
        jobsInfo[_jobId].exists = true;
        emit JobPosted(_jobId, msg.sender);
        clientsJob[jobsInfo[_jobId].client]++;
        wallet[msg.sender] = wallet[msg.sender] - _amount;

    }

    function assignFreelancer(uint _jobId, address _freelancer) public {
        assert(jobsInfo[_jobId].exists == true);
        require(msg.sender == jobsInfo[_jobId].client, "You did not post this Job");
        jobsInfo[_jobId].freelancer = _freelancer;
        emit JobAssigned(_jobId, _freelancer);
        clientsJob[jobsInfo[_jobId].client]--;

    }

    function markCompleted(uint _jobId) public {
        assert(jobsInfo[_jobId].exists == true);
        require(msg.sender == jobsInfo[_jobId].freelancer || msg.sender == jobsInfo[_jobId].client, "You are not assigned this Job");
        jobsInfo[_jobId].completed = true;
        emit JobCompleted(_jobId);

    }

    function releasePayment(uint _jobId) public {
        assert(jobsInfo[_jobId].exists == true && jobsInfo[_jobId].completed == true);
        require(msg.sender == jobsInfo[_jobId].client, "Only the client can pay freelancer! Please contact Client");
        jobsInfo[_jobId].exists = false;
        payable(jobsInfo[_jobId].freelancer).transfer(jobsInfo[_jobId].amount);
        emit PaymentReleased(_jobId, jobsInfo[_jobId].freelancer, jobsInfo[_jobId].amount);
    }

    function searchJob(address _adr) public view returns(uint){
        return clientsJob[_adr];
    
    }

    function myBal() public view returns(uint){
        return wallet[msg.sender];
    }
}
