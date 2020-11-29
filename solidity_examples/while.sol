pragma solidity ^0.4.18;

contract TestWhile {
  uint i = 10;
  uint value = 0;

  function test_while() public{
    while (i > 0) {
      i--;
      value = value + 100;
    }
  }
}
