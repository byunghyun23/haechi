pragma solidity^0.4.18;

contract TestLoop {
    address owner = msg.sender;
    uint i = 2;
    uint z;
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
            a++; b++;
            for(uint k=0; k<5; k++) {
                msg.sender.send(amount);
                msg.sender.transfer(amount);
                require(tx.origin == owner);
                a++;
            }
        }
        c = a + b;
    }

    //function testDoWhile() public {
    //    i = 10;
    //    do {
    //        i--;
    //        a = 10;
    //    } while(i > 0);
    //}
}

