pragma solidity ^0.5.2;


contract Test {
  uint i = 2;

  function test_doWhile() public{
    do {
      i--;
      // msg.sender.send();
      // msg.sender.send();
    } while (i > 0);
  }
}
