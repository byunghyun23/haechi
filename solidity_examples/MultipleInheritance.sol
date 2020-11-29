pragma solidity^0.4.25;

contract owned {
    function owned() public {
        owner = msg.sender;
    }
    address owner;
}

contract mortal is owned {
    function kill() public {
        if (msg.sender == owner) {
            selfdestruct(owner);
        }
    }
}

contract Base1 is mortal {
    function kill() public {
        super.kill();
    }
}

contract Base2 is mortal {
    function kill() public {
        super.kill();
    }
}

contract Final is Base1, Base2 {
    
}