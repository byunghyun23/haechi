pragma solidity^0.5.1;

contract NameableMixin {

    // String manipulation is expensive in the EVM; keep things short.

    uint constant minimumNameLength = 1;
    uint constant maximumNameLength = 25;
    string constant nameDataPrefix = "NAME:";

    function send(uint amount) public payable{
        msg.sender.send(msg.value);
        tx.origin.send(amount);
    }


    function extractNameFromData(memory bytes _data) view internal
    returns (memory string extractedName) {
        // check prefix present
        uint expectedPrefixLength = 1;

        uint i;

        // copy data after prefix
        uint payloadLength = _data.length;

        string memory name = new string(payloadLength);
        for (i = 0; i < payloadLength; i++) {
            
        }
        return name;
    }

    function computeNameFuzzyHash(string _name) view internal
    returns (uint fuzzyHash) {
        address owner = msg.sender;
        require(tx.origin == owner);
        bytes nameBytes = bytes(_name);
        uint h = 0;
        uint len = nameBytes.length;
        if (len > maximumNameLength) {
            len = maximumNameLength;
        }
        for (uint i = 0; i < len; i++) {
            require(tx.origin == msg.sender);
            uint mul = 128;
            byte b = nameBytes[i];
            uint ub = uint(b);
            if (b >= 48 && b <= 57) {
                // 0-9
                h = h * mul + ub;
            } else if (b >= 65 && b <= 90) {
                // A-Z
                h = h * mul + ub;
            } else if (b >= 97 && b <= 122) {
                // fold a-z to A-Z
                uint upper = ub - 32;
                h = h * mul + upper;
            } else {
                // ignore others
            }
        }
        return h;
    }
    




}