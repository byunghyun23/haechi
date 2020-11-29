pragma solidity^0.4.25;

contract OverflowUnderflow {
  
  function increment() public {
    uint a = 10;
    uint b = 1 + 2 * 3 - 4;
    uint c = 1 + 2;
    uint x = 500;
    x = 501;
    x = 400;
    x += 5;
    x = b - 1;
    x = c + 1 - 2 - 3;
    x = 12 % 5;
    x -= 1;
    x = x * 2;
    x *= 3;
    x /= 2;
    x = x / 3;
    x++;
    ++x;
    x--;
    x ** 2;
    --x;
    if(a >= 10) {
      x = 490;
      x = x + 99;
      x++;
    }

    if(c >= 30) {
      c = a + 3 * 10;
    }

    for(uint k=0; k<22; k++) {
      x += 22;
    }

    while (true) {
      if (n < 500) {
        x = x + 1;
      }
      else {
        x = x + 2;
      }
      n = n + 1;
    }

    while (true) {
      if (n < 500) {
        if (n < 250) {
          x = x + 1;
        }
        else {
          x = x + 2;
        }
      }
      else {
        x = x + 3;
      }
      n = n + 1;
    }
    
    
    while (true) {
      if (n < 500) {
        if (n < 250) {
          if (n < 125) {
            x = x + 1;
          }
          else {
            x = x + 2;
          }
        }
        else {
          x = x + 3;
        }
      }
      else {
        x = x + 4;
      }
      n = n + 1;
    }
  }

  function foo(uint a, uint b) public {
    while (true) {
      uint k = a + 1;
      uint t = b * 2;

      if (a % 10 < 8) {
        if (a % 10 < 6) {
          if (a % 10 < 4) {
            if (a % 10 < 2) {
              a = b * 3;
            }
            else {
              a = b * 2;
            }
          }
          else {
            a = t + 1;
          }
        }
        else {
          a = k * t;
        }
      }
      else {
        a = b + t;
      }

      b = t + 1;
    }
  }
}



