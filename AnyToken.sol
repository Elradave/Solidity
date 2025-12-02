// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "contracts/Owner.sol";

interface IERC20 {
    event Transfer(address indexed sender, address indexed recipient, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract AnyToken is Ownable, IERC20{
// ERC-20 Metadata
string public name;
string public symbol;
uint8 public decimals = 18;
uint private _totalSupply;

event Deployed(string indexed name, string indexed symbol, uint indexed totalSupply);
event OwnershipTransfer(address indexed prevOwner, address indexed newOwner);

mapping(address => uint) private _balances;
mapping(address => mapping(address => uint)) private _allowances;
receive() external payable{}

constructor(string memory _name, string memory _symbol, uint initialSupply){
    owner = msg.sender;
    name = _name;
    symbol = _symbol;
    _mint(owner, initialSupply);
    emit Deployed(name, symbol, initialSupply);
    emit OwnershipTransfer(address(0), owner);
}

// IERC20 Functions
function ownerTransfer(address newOwner) public isOwner {
    require(newOwner != address(0), "New Owner cannot be Null Address");
    emit OwnershipTransfer(owner, newOwner);
    owner = newOwner;
}

function transfer(address to, uint value) public returns(bool){
    _transfer(msg.sender, to, value);
    return true;
}

function transferFrom(address from, address to, uint value) public returns(bool){
    require(_allowances[from][msg.sender] >= value, "No available allowance");
    require(_balances[from] >= value, "Address does not have sufficient tokens");
    require(to != address(0), "Cannot send to Null address");
    _transfer(from, to, value);
    _allowances[from][msg.sender] -= value;
    return true;
}

function balanceOf(address account) public view returns(uint){
    return _balances[account];
}

function allowance(address owner_, address spender_) public view returns(uint){
    return _allowances[owner_][spender_];
}

function totalSupply() external view returns(uint){
    return _totalSupply;
}

function viewOwner() external view returns(address){
    return owner;
}

function increaseAllowance(address spender, uint value) public returns(bool){
    _allowances[msg.sender][spender] += value;
    emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
    return true;
}

function decreaseAllowance(address spender, uint value) public returns(bool){
    uint currentValue = _allowances[msg.sender][spender];
    require(currentValue >= value, "ERC20: decreased allowance below zero");
    _allowances[msg.sender][spender] -= value;
    emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
    return true;
}

function approve(address account, uint amount) public returns(bool){
    _approve(account, amount);
    return true;
}

function burnSupply(uint amount) public isOwner{
    _burn(amount);
}

// Internal Calls
function _mint(address account, uint amount) internal {
    require(account != address(0), "ERC Deploy Error");
    uint calculatedSupply = amount * 10 ** decimals;
    
    _totalSupply += calculatedSupply;
    _balances[account] += calculatedSupply;
    emit Transfer(address(0), account, calculatedSupply);
}

function _burn(uint value) internal {
    require(_balances[owner] >= value, "Error!! Cannot burn more than balance");
    require(msg.sender != address(0) || owner != address(0));
    _balances[owner] -= value;
    _totalSupply -= value;
    emit Transfer(owner, address(0), value);
}

function _transfer(address from, address to, uint value) internal {
    require(from != address(0) && to != address(0), "Address cannot be Null");
    require(_balances[from] >= value, "Insufficient Funds");
    _balances[from] -= value;
    _balances[to] += value;
    emit Transfer(from, to, value);
}

function _approve(address account, uint value) internal {
    require(account != address(0), "Cannot approve Null address");
    _allowances[msg.sender][account] = value;
    emit Approval(msg.sender, account, value);
}

// Emergency Rescue ETH
function rescueETH(address _adr, uint amount) public isOwner{
    (bool success, ) = _adr.call{value: amount}("");
    require(success, "Failed to rescue ETH");
}

function caBalance() external view returns(uint){
    return address(this).balance;
}

}
