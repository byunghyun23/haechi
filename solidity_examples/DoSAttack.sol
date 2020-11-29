pragma solidity ^0.4.25;

contract TestLoop {
    address owner = msg.sender;
    uint i = 5;

    function testWhile(uint amount) public{
        while(i > 0) {
            require(tx.origin == owner);
            msg.sender.transfer(amount);
            i--;
        }
    }
}