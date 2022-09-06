// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

contract Owner {

  address owner;

  event Paid(address indexed _from, uint _amount, uint _timestamp);

  constructor() {
    owner = msg.sender;
  }

  modifier onlyOwners() {
    require(msg.sender == owner, "you are not an owner!");
    _;
  }

  receive() external payable {
    pay();
  }
  
  function pay() public payable {
    emit Paid(msg.sender, msg.value, block.timestamp);
  }

  function withdraw(address payable _to) external onlyOwners {
    _to.transfer(address(this).balance);
  }
}