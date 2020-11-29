pragma solidity^0.4.18;

contract OverflowUnderflow {
  address addr = msg.sender;
  uint value = 1;
  function increment() public {
    value = value + 1;
  }
  function decrement() public {
    value = value - 1;
  }
}

