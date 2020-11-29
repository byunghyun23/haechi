pragma solidity^0.4.18;

contract OverflowUnderflow {
  address addr = msg.sender;
  uint zero = 0;
  uint one = 1;
  uint five = 5;
  uint six = 6;
  uint seven = 7;
  function increment() public {
    five = five + 1;
    five += 1;
    five = five - 1;
    five -= 1;
    five = five * 2;
    five *= 2;
    five ++;
    ++five;
    five --;
    --five;
    if(seven == 7) {
      seven--;
    }
    else {
      seven++;
    }
  }
  function decrement() public {
    zero -= 1;
  }
}
