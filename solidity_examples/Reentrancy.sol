pragma solidity ^0.4.25;

contract Mallory {
    SimpleDAO dao;
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
