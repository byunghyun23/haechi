pragma solidity^0.5.1;

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
