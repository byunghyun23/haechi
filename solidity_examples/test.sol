pragma solidity^0.4.18;

contract Mallory {
  SimpleDAO dao;
  testContract test;
  mapping (address => uint) userBalance;

  function func() public {
    dao.withdraw();
  }
  function() external { 
    dao.withdraw();
  }
  function testFunc() public {
    dao.withdraw();
    func();
   test.testFunc2();
  }
  function notitle() public {
      dao.withdraw();
  }
  function getBalance(address u) public view returns(uint){
    return userBalance[u];
  }
}
 
contract SimpleDAO {
  Mallory mallory;
  mapping (address => uint) public credit;

  function withdraw() public {
    Mallory mal;
    address adrr;
    mallory.testFunc(); 
    mal.func();
    adrr = tx.origin;
  }
}

contract testContract {
  SimpleDAO simple;
  function testFunc2() public {
      simple.withdraw();
  }
}

contract TxOriginContract {
    address owner;
    uint c;

    constructor() public {
        owner = msg.sender;
    }

    function send(uint amount) public payable{
        msg.sender.send(msg.value);
        require(tx.origin == owner);
        tx.origin.send(amount);
    }

    function transfer(uint amount) public payable{
        msg.sender.transfer(amount);
        require(tx.origin == owner);
        tx.origin.send(msg.value);
    }
}

contract ownedContract {
    uint a;
    function get() public view returns(uint) {
        return a;
    }
}

contract BaseNo1 is ownedContract {
    function set() public {
        a = 1;
    }
    function set(uint num, uint num2) public {
        a = num;
    }
}

contract BaseNo2 is ownedContract {
    function set() public {
        a = 2;
    }

    function set(uint num, uint num2) public {
        a = num ;
    }
    function set2() public {
        a = 10;
    }
}

contract Final is BaseNo1, BaseNo2 {
    function set() public {
       a = 3;
    }
    function func() public {
        set();
        set(10, 10);
        super.set();
    }
}

contract Empty is Final {

}

contract Temp is Empty{
    uint a;

    function set(uint num) public {
       a = 3;
    }

    function set() public {
      a = 3;
    }
}

contract Test is Final, Temp {
    function test() public {
        set(10, 20);
    }
}


contract OverflowUnderflow {
  
  function increment() public {
    uint a = 10;
    uint b = 1 + 2 * 3 - 4;
    uint c = 1 + 2;
    uint max = 500;
    max = 501;
    max += 1;
    max = b - 1;
    max = c + 1 - 2 - 3;
    max = 12 % 5;
    max -= 1;
    max = max * 2;
    max *= 3;
    max /= 2;
    max = max / 3;
    max++;
    ++max;
    max--;
    max ** 2;
    --max;
    if(a >= 10) {
      max = 490;
      max = max + 99;
    }

    if(c >= 30) {
      c = a * 3 + 10;
    }
  }
}

contract Contract1 {
    uint a;

    function set() public {
        a = 1;
    }

    function set(uint num) public {
        a = num;
    }
}

contract Contract2 {
    uint a;
    uint b;
    function set(uint num, uint num2) public {
       a = num; 
       b = num2;
    }
}

contract Test2 is Contract1, Contract2 {
    function test() public {
        set(10, 20);
    }
}

contract TestLoop {
    address owner = msg.sender;
    uint i = 2;
    uint a = 2;
    uint b = 3;
    uint c = 0;

    function testWhile(uint amount) public{
        while(i > 0) {
            require(tx.origin == owner);
            msg.sender.transfer(amount);
            i--;
        }
    }

    function testForStatement(uint amount) public {
        require(tx.origin == owner);
        for(i=0; i<10; i++) {
            a++;
            b++;
            for(uint k=0; k<5; k++) {
                msg.sender.send(amount);
                msg.sender.transfer(amount);
                require(tx.origin == owner);
                a++;
            }
        }
        c = a + b;
    }

    function testDoWhile() public {
        i = 10;
        do {
            i--;
            a = 10;
        } while(i > 0);
    }
}