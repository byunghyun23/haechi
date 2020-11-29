pragma solidity^0.4.18;

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
    function set(uint num) public {
        a = num;
    }
}

contract BaseNo2 is ownedContract {
    function set() public {
        a = 2;
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
        set(10);
        super.set();
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

contract Test is Contract1, Contract2 {
    function test() public {
        set(10, 20);
    }
}


