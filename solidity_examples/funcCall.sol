pragma solidity ^0.5.1;

contract TestFuncCall {
    uint value = 100;
    
    function double (uint v) public pure returns(uint){
        return 2 * v;
    }
    
    function test_funcCall(uint x, uint y) public{
        uint z = double(y);
        if (z == x) {
            if (x > y + 10) {
                value++;
            }
        }
    }
}

