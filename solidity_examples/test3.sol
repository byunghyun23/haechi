pragma solidity^0.5.1;

contract Mallory {
  SimpleDAO dao;
  testContract test;
  mapping (address => uint) userBalance;

  function func() public {
    dao.withdraw();
  }
  function() external { 
    //dao.withdraw();
  }
  function testFunc() public {
    //dao.withdraw();
    //func();
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
}

contract BaseNo2 is ownedContract {
    function set() public {
        a = 2;
    }
}

contract Final is BaseNo1, BaseNo2 { }

contract TestLoop {
    address owner = msg.sender;
    uint i = 2;
    uint a = 2;
    uint b = 3;
    uint c = 0;

    function testWhile() public{
        while(i > 0) {
            require(tx.origin == owner);
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