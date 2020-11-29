pragma solidity ^0.5.2;

contract TestFor {
  uint i = 2;
  uint j = 3;

  function test_for() public{
    for(uint k=0; k<10; k++) {
      i++;
      // msg.sender.send();
    }
    j = j + 1;
  }
}
