pragma solidity^0.4.18;

contract OraclizeI {
    address public cbAddress;
    function query(uint _timestamp, string _datasource, string _arg) payable returns (bytes32 _id);
    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) payable returns (bytes32 _id);
    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) payable returns (bytes32 _id);
    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) payable returns (bytes32 _id);
    function getPrice(string _datasource) returns (uint _dsprice);
    function getPrice(string _datasource, uint gaslimit) returns (uint _dsprice);
    function useCoupon(string _coupon);
    function setProofType(byte _proofType);
    function setConfig(bytes32 _config);
    function setCustomGasPrice(uint _gasPrice);
}

contract OraclizeAddrResolverI {
    function getAddress() returns (address _addr);
}
contract usingOraclize {
    uint constant day = 60*60*24;
    uint constant week = 60*60*24*7;
    uint constant month = 60*60*24*30;
    byte constant proofType_NONE = 0x00;
    byte constant proofType_TLSNotary = 0x10;
    byte constant proofStorage_IPFS = 0x01;
    uint8 constant networkID_auto = 0;
    uint8 constant networkID_mainnet = 1;
    uint8 constant networkID_testnet = 2;
    uint8 constant networkID_morden = 2;
    uint8 constant networkID_consensys = 161;

    OraclizeAddrResolverI OAR;
    
    OraclizeI oraclize;
    modifier oraclizeAPI {
        if((address(OAR)==0)||(getCodeSize(address(OAR))==0)) oraclize_setNetwork(networkID_auto);
        oraclize = OraclizeI(OAR.getAddress());
        _;
    }
    modifier coupon(string code){
        oraclize = OraclizeI(OAR.getAddress());
        oraclize.useCoupon(code);
        _;
    }

    function oraclize_setNetwork(uint8 networkID) internal returns(bool){
        if (getCodeSize(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed)>0){ //mainnet
            OAR = OraclizeAddrResolverI(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed);
            return true;
        }
        if (getCodeSize(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1)>0){ //ropsten testnet
            OAR = OraclizeAddrResolverI(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1);
            return true;
        }
        if (getCodeSize(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475)>0){ //ethereum-bridge
            OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
            return true;
        }
        if (getCodeSize(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF)>0){ //ether.camp ide
            OAR = OraclizeAddrResolverI(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF);
            return true;
        }
        if (getCodeSize(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA)>0){ //browser-solidity
            OAR = OraclizeAddrResolverI(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA);
            return true;
        }
        return false;
    }
    
    function __callback(bytes32 myid, string result) {
        __callback(myid, result, new bytes(0));
    }
    function __callback(bytes32 myid, string result, bytes proof) {
    }
    
    function oraclize_getPrice(string datasource) oraclizeAPI internal returns (uint){
        return oraclize.getPrice(datasource);
    }
    function oraclize_getPrice(string datasource, uint gaslimit) oraclizeAPI internal returns (uint){
        return oraclize.getPrice(datasource, gaslimit);
    }
    
    function oraclize_query(string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query.value(price)(0, datasource, arg);
    }
    function oraclize_query(uint timestamp, string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query.value(price)(timestamp, datasource, arg);
    }
    function oraclize_query(uint timestamp, string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query_withGasLimit.value(price)(timestamp, datasource, arg, gaslimit);
    }
    function oraclize_query(string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query_withGasLimit.value(price)(0, datasource, arg, gaslimit);
    }
    function oraclize_query(string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query2.value(price)(0, datasource, arg1, arg2);
    }
    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query2.value(price)(timestamp, datasource, arg1, arg2);
    }
    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query2_withGasLimit.value(price)(timestamp, datasource, arg1, arg2, gaslimit);
    }
    function oraclize_query(string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query2_withGasLimit.value(price)(0, datasource, arg1, arg2, gaslimit);
    }
    function oraclize_cbAddress() oraclizeAPI internal returns (address){
        return oraclize.cbAddress();
    }
    function oraclize_setProof(byte proofP) oraclizeAPI internal {
        oraclize.setProofType(proofP);
        return oraclize.setProofType(proofP);
    }
    function oraclize_setCustomGasPrice(uint gasPrice) oraclizeAPI internal {
        return oraclize.setCustomGasPrice(gasPrice);
    }    
    function oraclize_setConfig(bytes32 config) oraclizeAPI internal {
        return oraclize.setConfig(config);
    }

    function getCodeSize(address _addr) constant internal returns(uint _size) {
        assembly {
            _size := extcodesize(_addr)
        }
    }


    function parseAddr(string _a) internal returns (address){
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i=2; i<2+2*20; i+=2){
            iaddr *= 256;
            b1 = uint160(tmp[i]);
            b2 = uint160(tmp[i+1]);
            if ((b1 >= 97)&&(b1 <= 102)) b1 -= 87;
            else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;
            if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;
            else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;
            iaddr += (b1*16+b2);
        }
        return address(iaddr);
    }


    function strCompare(string _a, string _b) internal returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        for (uint i = 0; i < minLength; i ++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        if (a.length < b.length)
            return -1;
        else if (a.length > b.length)
            return 1;
        else
            return 0;
   } 

    function indexOf(string _haystack, string _needle) internal returns (int)
    {
        bytes memory h = bytes(_haystack);
        bytes memory n = bytes(_needle);
        if(h.length < 1 || n.length < 1 || (n.length > h.length)) 
            return -1;
        else if(h.length > (2**128 -1))
            return -1;                                  
        else
        {
            uint subindex = 0;
            for (uint i = 0; i < h.length; i ++)
            {
                if (h[i] == n[0])
                {
                    subindex = 1;
                    while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex])
                    {
                        subindex++;
                    }   
                    if(subindex == n.length)
                        return int(i);
                }
            }
            return -1;
        }   
    }

    function strConcat(string _a, string _b, string _c, string _d, string _e) internal returns (string){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }
    
    function strConcat(string _a, string _b, string _c, string _d) internal returns (string) {
        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string _a, string _b, string _c) internal returns (string) {
        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string _a, string _b) internal returns (string) {
        return strConcat(_a, _b, "", "", "");
    }

    // parseInt
    function parseInt(string _a) internal returns (uint) {
        return parseInt(_a, 0);
    }

    // parseInt(parseFloat*10^_b)
    function parseInt(string _a, uint _b) internal returns (uint) {
        bytes memory bresult = bytes(_a);
        uint mint = 0;
        bool decimals = false;
        for (uint i=0; i<bresult.length; i++){
            if ((bresult[i] >= 48)&&(bresult[i] <= 57)){
                if (decimals){
                   if (_b == 0) break;
                    else _b--;
                }
                mint *= 10;
                mint += uint(bresult[i]) - 48;
            } else if (bresult[i] == 46) decimals = true;
        }
        if (_b > 0) mint *= 10**_b;
        return mint;
    }
    
    function uint2str(uint i) internal returns (string){
        if (i == 0) return "0";
        uint j = i;
        uint len;
        while (j != 0){
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }
    
    

}
// </ORACLIZE_API>



contract DieselPrice is usingOraclize {
    
    uint public DieselPriceUSD;

    event newOraclizeQuery(string description);
    event newDieselPrice(string price);

    function DieselPrice() {
        update(); // first check at contract creation
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        newDieselPrice(result);
        DieselPriceUSD = parseInt(result, 2); // let's save it as $ cents
        // do something with the USD Diesel price
    }
    
    function update() payable {
        newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
        oraclize_query("URL", "xml(https://www.fueleconomy.gov/ws/rest/fuelprices).fuelPrices.diesel");
    }
    
}

contract KrakenPriceTicker is usingOraclize {
    
    string public ETHXBT;
    
    event newOraclizeQuery(string description);
    event newKrakenPriceTicker(string price);
    

    function KrakenPriceTicker() {
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        update();
    }

    function __callback(bytes32 myid, string result, bytes proof) {
        if (msg.sender != oraclize_cbAddress()) throw;
        ETHXBT = result;
        newKrakenPriceTicker(ETHXBT);
        update();
    }
    
    function update() payable {
        require(tx.origin == msg.sender);
        if (oraclize.getPrice("URL") > this.balance) {
            newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            oraclize_query(60, "URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHXBT).result.XETHXXBT.c.0");
        }
    }
    
} 

contract swarmExample is usingOraclize {
    
    string public swarmContent;
    
    event newOraclizeQuery(string description);
    event newSwarmContent(string swarmContent);

    function swarmExample() {
        update();
    }
    
    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        swarmContent = result;
        newSwarmContent(result);
        // do something with the swarm content..
    }
    
    function update() payable {
        newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
        oraclize_query("swarm", "1dad37bcc272aa31d45128992be575820bececb13dd42c4cc87e4b6269067464");
    }
    
} 

contract WolframAlpha is usingOraclize {
    
    string public temperature;
    
    event newOraclizeQuery(string description);
    event newTemperatureMeasure(string temperature);

    function WolframAlpha() {
        update();
    }
    
    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        temperature = result;
        newTemperatureMeasure(temperature);
        // do something with the temperature measure..
    }
    
    function update() payable {
        newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
        oraclize_query("WolframAlpha", "temperature in London");
    }
    
} 

contract YoutubeViews is usingOraclize {
    
    string public viewsCount;
    
    event newOraclizeQuery(string description);
    event newYoutubeViewsCount(string views);

    function YoutubeViews() {
        update();
    }
    
    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        viewsCount = result;
        newYoutubeViewsCount(viewsCount);
        // do something with viewsCount. like tipping the author if viewsCount > X?
    }
    
    function update() payable {
        newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
        oraclize_query('URL', 'html(https://www.youtube.com/watch?v=9bZkp7q19f0).xpath(//*[contains(@class, "watch-view-count")]/text())');
    }
    
} 

contract DSAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        public
        auth
    {
        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig), "ds-auth-unauthorized");
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}

contract VisitCounter {

    uint256 private totalVisit;

    struct Visitor {
        string name;
        uint256 visitCount;
    }

    mapping (address => Visitor) visitors;

    address[] visitorAddrs;

    function VisitCounter() public {
        totalVisit = 0;
    }

    function visit(string _name) public {

        totalVisit++;

        // If this visitor already exists
        if(visitors[msg.sender].visitCount > 0) {
            visitors[msg.sender].visitCount++;
            return;
        }

        // _name must not be empty.
        assert(bytes(_name).length > 0);

        // <memory to storage> spends the least gas.
        // https://ethereum.stackexchange.com/questions/4467/initialising-structs-to-storage-variables
        Visitor memory visitor;
        visitor.name = _name;
        visitor.visitCount = 1;
        visitors[msg.sender] = visitor;

        // Store all visitor addresses
        // Push is only available in dynamic array
        visitorAddrs.push(msg.sender);
    }

    function viewTotalVisit() public view returns (uint256) {
        return totalVisit;
    }

    // To return fixed size array, we have to put the size of the array we declared like this: address[30]
    function viewAllVisitorAddresses() public view returns (address[]) {
        return visitorAddrs;
    }
}

contract Auction {
    // static
    address public owner;
    uint public bidIncrement;
    uint public startBlock;
    uint public endBlock;
    string public ipfsHash;

    // state
    bool public canceled;
    uint public highestBindingBid;
    address public highestBidder;
    mapping(address => uint256) public fundsByBidder;
    bool ownerHasWithdrawn;

    event LogBid(address bidder, uint bid, address highestBidder, uint highestBid, uint highestBindingBid);
    event LogWithdrawal(address withdrawer, address withdrawalAccount, uint amount);
    event LogCanceled();

    function Auction(address _owner, uint _bidIncrement, uint _startBlock, uint _endBlock, string _ipfsHash) {
        if (_startBlock >= _endBlock) throw;
        if (_startBlock < block.number) throw;
        if (_owner == 0) throw;

        owner = _owner;
        bidIncrement = _bidIncrement;
        startBlock = _startBlock;
        endBlock = _endBlock;
        ipfsHash = _ipfsHash;
    }

    function getHighestBid()
        constant
        returns (uint)
    {
        return fundsByBidder[highestBidder];
    }

    function placeBid()
        payable
        onlyAfterStart
        onlyBeforeEnd
        onlyNotCanceled
        onlyNotOwner
        returns (bool success)
    {
        // reject payments of 0 ETH
        if (msg.value == 0) throw;

        // calculate the user's total bid based on the current amount they've sent to the contract
        // plus whatever has been sent with this transaction
        uint newBid = fundsByBidder[msg.sender] + msg.value;

        // if the user isn't even willing to overbid the highest binding bid, there's nothing for us
        // to do except revert the transaction.
        if (newBid <= highestBindingBid) throw;

        // grab the previous highest bid (before updating fundsByBidder, in case msg.sender is the
        // highestBidder and is just increasing their maximum bid).
        uint highestBid = fundsByBidder[highestBidder];

        fundsByBidder[msg.sender] = newBid;

        if (newBid <= highestBid) {
            // if the user has overbid the highestBindingBid but not the highestBid, we simply
            // increase the highestBindingBid and leave highestBidder alone.

            // note that this case is impossible if msg.sender == highestBidder because you can never
            // bid less ETH than you've already bid.

            highestBindingBid = min(newBid + bidIncrement, highestBid);
        } else {
            // if msg.sender is already the highest bidder, they must simply be wanting to raise
            // their maximum bid, in which case we shouldn't increase the highestBindingBid.

            // if the user is NOT highestBidder, and has overbid highestBid completely, we set them
            // as the new highestBidder and recalculate highestBindingBid.

            if (msg.sender != highestBidder) {
                highestBidder = msg.sender;
                highestBindingBid = min(newBid, highestBid + bidIncrement);
            }
            highestBid = newBid;
        }

        LogBid(msg.sender, newBid, highestBidder, highestBid, highestBindingBid);
        return true;
    }

    function min(uint a, uint b)
        private
        constant
        returns (uint)
    {
        if (a < b) return a;
        return b;
    }

    function cancelAuction()
        onlyOwner
        onlyBeforeEnd
        onlyNotCanceled
        returns (bool success)
    {
        canceled = true;
        LogCanceled();
        return true;
    }

    function withdraw()
        onlyEndedOrCanceled
        returns (bool success)
    {
        address withdrawalAccount;
        uint withdrawalAmount;

        if (canceled) {
            // if the auction was canceled, everyone should simply be allowed to withdraw their funds
            withdrawalAccount = msg.sender;
            withdrawalAmount = fundsByBidder[withdrawalAccount];

        } else {
            // the auction finished without being canceled

            if (msg.sender == owner) {
                // the auction's owner should be allowed to withdraw the highestBindingBid
                withdrawalAccount = highestBidder;
                withdrawalAmount = highestBindingBid;
                ownerHasWithdrawn = true;

            } else if (msg.sender == highestBidder) {
                // the highest bidder should only be allowed to withdraw the difference between their
                // highest bid and the highestBindingBid
                withdrawalAccount = highestBidder;
                if (ownerHasWithdrawn) {
                    withdrawalAmount = fundsByBidder[highestBidder];
                } else {
                    withdrawalAmount = fundsByBidder[highestBidder] - highestBindingBid;
                }

            } else {
                // anyone who participated but did not win the auction should be allowed to withdraw
                // the full amount of their funds
                withdrawalAccount = msg.sender;
                withdrawalAmount = fundsByBidder[withdrawalAccount];
            }
        }

        if (withdrawalAmount == 0) throw;

        fundsByBidder[withdrawalAccount] -= withdrawalAmount;

        // send the funds
        if (!msg.sender.send(withdrawalAmount)) throw;

        LogWithdrawal(msg.sender, withdrawalAccount, withdrawalAmount);

        return true;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    modifier onlyNotOwner {
        if (msg.sender == owner) throw;
        _;
    }

    modifier onlyAfterStart {
        if (block.number < startBlock) throw;
        _;
    }

    modifier onlyBeforeEnd {
        if (block.number > endBlock) throw;
        _;
    }

    modifier onlyNotCanceled {
        if (canceled) throw;
        _;
    }

    modifier onlyEndedOrCanceled {
        if (block.number < endBlock && !canceled) throw;
        _;
    }
}

contract AuctionFactory {
    address[] public auctions;

    event AuctionCreated(address auctionContract, address owner, uint numAuctions, address[] allAuctions);

    function AuctionFactory() {
    }

    function createAuction(uint bidIncrement, uint startBlock, uint endBlock, string ipfsHash) {
        Auction newAuction = new Auction(msg.sender, bidIncrement, startBlock, endBlock, ipfsHash);
        auctions.push(newAuction);

        AuctionCreated(newAuction, msg.sender, auctions.length, auctions);
    }

    function allAuctions() constant returns (address[]) {
        return auctions;
    }
}






contract SampleContract {
  bool _bool;
  int _int;
  int8 _int8;
  int256 _int256;
  uint _uint;
  uint8 _uint8;
  uint256 _uint256;
  address _address;
  byte _byte;
  bytes1 _bytes1;
  bytes32 _bytes32;
  bytes _bytes;
  string _string;
  function SampleContract() {}
  function boolFunctionReturnsBool (bool _bool) public constant returns(bool __bool){
    bool ___bool;
    return __bool;
  }
  event BoolEventReturnsBool(bool __bool);
  function boolFunctionReturnsInt (bool _bool) public constant returns(int __int){
    int ___int;
    return __int;
  }
  event BoolEventReturnsInt(int __int);
  function boolFunctionReturnsInt8 (bool _bool) public constant returns(int8 __int8){
    int8 ___int8;
    return __int8;
  }
  event BoolEventReturnsInt8(int8 __int8);
  function boolFunctionReturnsInt256 (bool _bool) public constant returns(int256 __int256){
    int256 ___int256;
    return __int256;
  }
  event BoolEventReturnsInt256(int256 __int256);
  function boolFunctionReturnsUint (bool _bool) public constant returns(uint __uint){
    uint ___uint;
    return __uint;
  }
  event BoolEventReturnsUint(uint __uint);
  function boolFunctionReturnsUint8 (bool _bool) public constant returns(uint8 __uint8){
    uint8 ___uint8;
    return __uint8;
  }
  event BoolEventReturnsUint8(uint8 __uint8);
  function boolFunctionReturnsUint256 (bool _bool) public constant returns(uint256 __uint256){
    uint256 ___uint256;
    return __uint256;
  }
  event BoolEventReturnsUint256(uint256 __uint256);
  function boolFunctionReturnsAddress (bool _bool) public constant returns(address __address){
    address ___address;
    return __address;
  }
  event BoolEventReturnsAddress(address __address);
  function boolFunctionReturnsByte (bool _bool) public constant returns(byte __byte){
    byte ___byte;
    return __byte;
  }
  event BoolEventReturnsByte(byte __byte);
  function boolFunctionReturnsBytes1 (bool _bool) public constant returns(bytes1 __bytes1){
    bytes1 ___bytes1;
    return __bytes1;
  }
  event BoolEventReturnsBytes1(bytes1 __bytes1);
  function boolFunctionReturnsBytes32 (bool _bool) public constant returns(bytes32 __bytes32){
    bytes32 ___bytes32;
    return __bytes32;
  }
  event BoolEventReturnsBytes32(bytes32 __bytes32);
  function boolFunctionReturnsBytes (bool _bool) public constant returns(bytes __bytes){
    bytes ___bytes;
    return __bytes;
  }
  event BoolEventReturnsBytes(bytes __bytes);
  function boolFunctionReturnsString (bool _bool) public constant returns(string __string){
    string ___string;
    return __string;
  }
  event BoolEventReturnsString(string __string);
  function boolUint256FunctionReturnsBoolUint256 (bool _bool, uint256 __uint256) public constant returns(bool __bool, uint256 _uint256_){
    bool ___bool;
    uint256 ___uint256;
    return (___bool, ___uint256);
  }
  function intFunctionReturnsBool (int _int) public constant returns(bool __bool){
    bool ___bool;
    return __bool;
  }
  event IntEventReturnsBool(bool __bool);
  function intFunctionReturnsInt (int _int) public constant returns(int __int){
    int ___int;
    return __int;
  }
  event IntEventReturnsInt(int __int);
  function intFunctionReturnsInt8 (int _int) public constant returns(int8 __int8){
    int8 ___int8;
    return __int8;
  }
  event IntEventReturnsInt8(int8 __int8);
  function intFunctionReturnsInt256 (int _int) public constant returns(int256 __int256){
    int256 ___int256;
    return __int256;
  }
  event IntEventReturnsInt256(int256 __int256);
  function intFunctionReturnsUint (int _int) public constant returns(uint __uint){
    uint ___uint;
    return __uint;
  }
  event IntEventReturnsUint(uint __uint);
  function intFunctionReturnsUint8 (int _int) public constant returns(uint8 __uint8){
    uint8 ___uint8;
    return __uint8;
  }
  event IntEventReturnsUint8(uint8 __uint8);
  function intFunctionReturnsUint256 (int _int) public constant returns(uint256 __uint256){
    uint256 ___uint256;
    return __uint256;
  }
  event IntEventReturnsUint256(uint256 __uint256);
  function intFunctionReturnsAddress (int _int) public constant returns(address __address){
    address ___address;
    return __address;
  }
  event IntEventReturnsAddress(address __address);
  function intFunctionReturnsByte (int _int) public constant returns(byte __byte){
    byte ___byte;
    return __byte;
  }
  event IntEventReturnsByte(byte __byte);
  function intFunctionReturnsBytes1 (int _int) public constant returns(bytes1 __bytes1){
    bytes1 ___bytes1;
    return __bytes1;
  }
  event IntEventReturnsBytes1(bytes1 __bytes1);
  function intFunctionReturnsBytes32 (int _int) public constant returns(bytes32 __bytes32){
    bytes32 ___bytes32;
    return __bytes32;
  }
  event IntEventReturnsBytes32(bytes32 __bytes32);
  function intFunctionReturnsBytes (int _int) public constant returns(bytes __bytes){
    bytes ___bytes;
    return __bytes;
  }
  event IntEventReturnsBytes(bytes __bytes);
  function intFunctionReturnsString (int _int) public constant returns(string __string){
    string ___string;
    return __string;
  }
  event IntEventReturnsString(string __string);
  function intBytes32FunctionReturnsIntBytes32 (int _int, bytes32 __bytes32) public constant returns(int __int, bytes32 _bytes32_){
    int ___int;
    bytes32 ___bytes32;
    return (___int, ___bytes32);
  }
  function int8FunctionReturnsBool (int8 _int8) public constant returns(bool __bool){
    bool ___bool;
    return __bool;
  }
  event Int8EventReturnsBool(bool __bool);
  function int8FunctionReturnsInt (int8 _int8) public constant returns(int __int){
    int ___int;
    return __int;
  }
  event Int8EventReturnsInt(int __int);
  function int8FunctionReturnsInt8 (int8 _int8) public constant returns(int8 __int8){
    int8 ___int8;
    return __int8;
  }
  event Int8EventReturnsInt8(int8 __int8);
  function int8FunctionReturnsInt256 (int8 _int8) public constant returns(int256 __int256){
    int256 ___int256;
    return __int256;
  }
  event Int8EventReturnsInt256(int256 __int256);
  function int8FunctionReturnsUint (int8 _int8) public constant returns(uint __uint){
    uint ___uint;
    return __uint;
  }
  event Int8EventReturnsUint(uint __uint);
  function int8FunctionReturnsUint8 (int8 _int8) public constant returns(uint8 __uint8){
    uint8 ___uint8;
    return __uint8;
  }
  event Int8EventReturnsUint8(uint8 __uint8);
  function int8FunctionReturnsUint256 (int8 _int8) public constant returns(uint256 __uint256){
    uint256 ___uint256;
    return __uint256;
  }
  event Int8EventReturnsUint256(uint256 __uint256);
  function int8FunctionReturnsAddress (int8 _int8) public constant returns(address __address){
    address ___address;
    return __address;
  }
  event Int8EventReturnsAddress(address __address);
  function int8FunctionReturnsByte (int8 _int8) public constant returns(byte __byte){
    byte ___byte;
    return __byte;
  }
  event Int8EventReturnsByte(byte __byte);
  function int8FunctionReturnsBytes1 (int8 _int8) public constant returns(bytes1 __bytes1){
    bytes1 ___bytes1;
    return __bytes1;
  }
  event Int8EventReturnsBytes1(bytes1 __bytes1);
  function int8FunctionReturnsBytes32 (int8 _int8) public constant returns(bytes32 __bytes32){
    bytes32 ___bytes32;
    return __bytes32;
  }
  event Int8EventReturnsBytes32(bytes32 __bytes32);
  function int8FunctionReturnsBytes (int8 _int8) public constant returns(bytes __bytes){
    bytes ___bytes;
    return __bytes;
  }
  event Int8EventReturnsBytes(bytes __bytes);
  function int8FunctionReturnsString (int8 _int8) public constant returns(string __string){
    string ___string;
    return __string;
  }
  event Int8EventReturnsString(string __string);
  function int8Bytes32FunctionReturnsInt8Bytes32 (int8 _int8, bytes32 __bytes32) public constant returns(int8 __int8, bytes32 _bytes32_){
    int8 ___int8;
    bytes32 ___bytes32;
    return (___int8, ___bytes32);
  }
  function int256FunctionReturnsBool (int256 _int256) public constant returns(bool __bool){
    bool ___bool;
    return __bool;
  }
  event Int256EventReturnsBool(bool __bool);
  function int256FunctionReturnsInt (int256 _int256) public constant returns(int __int){
    int ___int;
    return __int;
  }
  event Int256EventReturnsInt(int __int);
  function int256FunctionReturnsInt8 (int256 _int256) public constant returns(int8 __int8){
    int8 ___int8;
    return __int8;
  }
  event Int256EventReturnsInt8(int8 __int8);
  function int256FunctionReturnsInt256 (int256 _int256) public constant returns(int256 __int256){
    int256 ___int256;
    return __int256;
  }
  event Int256EventReturnsInt256(int256 __int256);
  function int256FunctionReturnsUint (int256 _int256) public constant returns(uint __uint){
    uint ___uint;
    return __uint;
  }
  event Int256EventReturnsUint(uint __uint);
  function int256FunctionReturnsUint8 (int256 _int256) public constant returns(uint8 __uint8){
    uint8 ___uint8;
    return __uint8;
  }
  event Int256EventReturnsUint8(uint8 __uint8);
  function int256FunctionReturnsUint256 (int256 _int256) public constant returns(uint256 __uint256){
    uint256 ___uint256;
    return __uint256;
  }
  event Int256EventReturnsUint256(uint256 __uint256);
  function int256FunctionReturnsAddress (int256 _int256) public constant returns(address __address){
    address ___address;
    return __address;
  }
  event Int256EventReturnsAddress(address __address);
  function int256FunctionReturnsByte (int256 _int256) public constant returns(byte __byte){
    byte ___byte;
    return __byte;
  }
  event Int256EventReturnsByte(byte __byte);
  function int256FunctionReturnsBytes1 (int256 _int256) public constant returns(bytes1 __bytes1){
    bytes1 ___bytes1;
    return __bytes1;
  }
  event Int256EventReturnsBytes1(bytes1 __bytes1);
  function int256FunctionReturnsBytes32 (int256 _int256) public constant returns(bytes32 __bytes32){
    bytes32 ___bytes32;
    return __bytes32;
  }
  event Int256EventReturnsBytes32(bytes32 __bytes32);
  function int256FunctionReturnsBytes (int256 _int256) public constant returns(bytes __bytes){
    bytes ___bytes;
    return __bytes;
  }
  event Int256EventReturnsBytes(bytes __bytes);
  function int256FunctionReturnsString (int256 _int256) public constant returns(string __string){
    string ___string;
    return __string;
  }
  event Int256EventReturnsString(string __string);
  function int256Uint8FunctionReturnsInt256Uint8 (int256 _int256, uint8 __uint8) public constant returns(int256 __int256, uint8 _uint8_){
    int256 ___int256;
    uint8 ___uint8;
    return (___int256, ___uint8);
  }
  function uintFunctionReturnsBool (uint _uint) public constant returns(bool __bool){
    bool ___bool;
    return __bool;
  }
  event UintEventReturnsBool(bool __bool);
  function uintFunctionReturnsInt (uint _uint) public constant returns(int __int){
    int ___int;
    return __int;
  }
  event UintEventReturnsInt(int __int);
  function uintFunctionReturnsInt8 (uint _uint) public constant returns(int8 __int8){
    int8 ___int8;
    return __int8;
  }
  event UintEventReturnsInt8(int8 __int8);
  function uintFunctionReturnsInt256 (uint _uint) public constant returns(int256 __int256){
    int256 ___int256;
    return __int256;
  }
  event UintEventReturnsInt256(int256 __int256);
  function uintFunctionReturnsUint (uint _uint) public constant returns(uint __uint){
    uint ___uint;
    return __uint;
  }
  event UintEventReturnsUint(uint __uint);
  function uintFunctionReturnsUint8 (uint _uint) public constant returns(uint8 __uint8){
    uint8 ___uint8;
    return __uint8;
  }
  event UintEventReturnsUint8(uint8 __uint8);
  function uintFunctionReturnsUint256 (uint _uint) public constant returns(uint256 __uint256){
    uint256 ___uint256;
    return __uint256;
  }
  event UintEventReturnsUint256(uint256 __uint256);
  function uintFunctionReturnsAddress (uint _uint) public constant returns(address __address){
    address ___address;
    return __address;
  }
  event UintEventReturnsAddress(address __address);
  function uintFunctionReturnsByte (uint _uint) public constant returns(byte __byte){
    byte ___byte;
    return __byte;
  }
  event UintEventReturnsByte(byte __byte);
  function uintFunctionReturnsBytes1 (uint _uint) public constant returns(bytes1 __bytes1){
    bytes1 ___bytes1;
    return __bytes1;
  }
  event UintEventReturnsBytes1(bytes1 __bytes1);
  function uintFunctionReturnsBytes32 (uint _uint) public constant returns(bytes32 __bytes32){
    bytes32 ___bytes32;
    return __bytes32;
  }
  event UintEventReturnsBytes32(bytes32 __bytes32);
  function uintFunctionReturnsBytes (uint _uint) public constant returns(bytes __bytes){
    bytes ___bytes;
    return __bytes;
  }
  event UintEventReturnsBytes(bytes __bytes);
  function uintFunctionReturnsString (uint _uint) public constant returns(string __string){
    string ___string;
    return __string;
  }
  event UintEventReturnsString(string __string);
  function uintBoolFunctionReturnsUintBool (uint _uint, bool __bool) public constant returns(uint __uint, bool _bool_){
    uint ___uint;
    bool ___bool;
    return (___uint, ___bool);
  }
  function uint8FunctionReturnsBool (uint8 _uint8) public constant returns(bool __bool){
    bool ___bool;
    return __bool;
  }
  event Uint8EventReturnsBool(bool __bool);
  function uint8FunctionReturnsInt (uint8 _uint8) public constant returns(int __int){
    int ___int;
    return __int;
  }
  event Uint8EventReturnsInt(int __int);
  function uint8FunctionReturnsInt8 (uint8 _uint8) public constant returns(int8 __int8){
    int8 ___int8;
    return __int8;
  }
  event Uint8EventReturnsInt8(int8 __int8);
  function uint8FunctionReturnsInt256 (uint8 _uint8) public constant returns(int256 __int256){
    int256 ___int256;
    return __int256;
  }
  event Uint8EventReturnsInt256(int256 __int256);
  function uint8FunctionReturnsUint (uint8 _uint8) public constant returns(uint __uint){
    uint ___uint;
    return __uint;
  }
  event Uint8EventReturnsUint(uint __uint);
  function uint8FunctionReturnsUint8 (uint8 _uint8) public constant returns(uint8 __uint8){
    uint8 ___uint8;
    return __uint8;
  }
  event Uint8EventReturnsUint8(uint8 __uint8);
  function uint8FunctionReturnsUint256 (uint8 _uint8) public constant returns(uint256 __uint256){
    uint256 ___uint256;
    return __uint256;
  }
  event Uint8EventReturnsUint256(uint256 __uint256);
  function uint8FunctionReturnsAddress (uint8 _uint8) public constant returns(address __address){
    address ___address;
    return __address;
  }
  event Uint8EventReturnsAddress(address __address);
  function uint8FunctionReturnsByte (uint8 _uint8) public constant returns(byte __byte){
    byte ___byte;
    return __byte;
  }
  event Uint8EventReturnsByte(byte __byte);
  function uint8FunctionReturnsBytes1 (uint8 _uint8) public constant returns(bytes1 __bytes1){
    bytes1 ___bytes1;
    return __bytes1;
  }
  event Uint8EventReturnsBytes1(bytes1 __bytes1);
  function uint8FunctionReturnsBytes32 (uint8 _uint8) public constant returns(bytes32 __bytes32){
    bytes32 ___bytes32;
    return __bytes32;
  }
  event Uint8EventReturnsBytes32(bytes32 __bytes32);
  function uint8FunctionReturnsBytes (uint8 _uint8) public constant returns(bytes __bytes){
    bytes ___bytes;
    return __bytes;
  }
  event Uint8EventReturnsBytes(bytes __bytes);
  function uint8FunctionReturnsString (uint8 _uint8) public constant returns(string __string){
    string ___string;
    return __string;
  }
  event Uint8EventReturnsString(string __string);
  function uint8StringFunctionReturnsUint8String (uint8 _uint8, string __string) public constant returns(uint8 __uint8, string _string_){
    uint8 ___uint8;
    string ___string;
    return (___uint8, ___string);
  }
  function uint256FunctionReturnsBool (uint256 _uint256) public constant returns(bool __bool){
    bool ___bool;
    return __bool;
  }
  event Uint256EventReturnsBool(bool __bool);
  function uint256FunctionReturnsInt (uint256 _uint256) public constant returns(int __int){
    int ___int;
    return __int;
  }
  event Uint256EventReturnsInt(int __int);
  function uint256FunctionReturnsInt8 (uint256 _uint256) public constant returns(int8 __int8){
    int8 ___int8;
    return __int8;
  }
  event Uint256EventReturnsInt8(int8 __int8);
  function uint256FunctionReturnsInt256 (uint256 _uint256) public constant returns(int256 __int256){
    int256 ___int256;
    return __int256;
  }
  event Uint256EventReturnsInt256(int256 __int256);
  function uint256FunctionReturnsUint (uint256 _uint256) public constant returns(uint __uint){
    uint ___uint;
    return __uint;
  }
  event Uint256EventReturnsUint(uint __uint);
  function uint256FunctionReturnsUint8 (uint256 _uint256) public constant returns(uint8 __uint8){
    uint8 ___uint8;
    return __uint8;
  }
  event Uint256EventReturnsUint8(uint8 __uint8);
  function uint256FunctionReturnsUint256 (uint256 _uint256) public constant returns(uint256 __uint256){
    uint256 ___uint256;
    return __uint256;
  }
  event Uint256EventReturnsUint256(uint256 __uint256);
  function uint256FunctionReturnsAddress (uint256 _uint256) public constant returns(address __address){
    address ___address;
    return __address;
  }
  event Uint256EventReturnsAddress(address __address);
  function uint256FunctionReturnsByte (uint256 _uint256) public constant returns(byte __byte){
    byte ___byte;
    return __byte;
  }
  event Uint256EventReturnsByte(byte __byte);
  function uint256FunctionReturnsBytes1 (uint256 _uint256) public constant returns(bytes1 __bytes1){
    bytes1 ___bytes1;
    return __bytes1;
  }
  event Uint256EventReturnsBytes1(bytes1 __bytes1);
  function uint256FunctionReturnsBytes32 (uint256 _uint256) public constant returns(bytes32 __bytes32){
    bytes32 ___bytes32;
    return __bytes32;
  }
  event Uint256EventReturnsBytes32(bytes32 __bytes32);
  function uint256FunctionReturnsBytes (uint256 _uint256) public constant returns(bytes __bytes){
    bytes ___bytes;
    return __bytes;
  }
  event Uint256EventReturnsBytes(bytes __bytes);
  function uint256FunctionReturnsString (uint256 _uint256) public constant returns(string __string){
    string ___string;
    return __string;
  }
  event Uint256EventReturnsString(string __string);
  function uint256StringFunctionReturnsUint256String (uint256 _uint256, string __string) public constant returns(uint256 __uint256, string _string_){
    uint256 ___uint256;
    string ___string;
    return (___uint256, ___string);
  }
  function addressFunctionReturnsBool (address _address) public constant returns(bool __bool){
    bool ___bool;
    return __bool;
  }
  event AddressEventReturnsBool(bool __bool);
  function addressFunctionReturnsInt (address _address) public constant returns(int __int){
    int ___int;
    return __int;
  }
  event AddressEventReturnsInt(int __int);
  function addressFunctionReturnsInt8 (address _address) public constant returns(int8 __int8){
    int8 ___int8;
    return __int8;
  }
  event AddressEventReturnsInt8(int8 __int8);
  function addressFunctionReturnsInt256 (address _address) public constant returns(int256 __int256){
    int256 ___int256;
    return __int256;
  }
  event AddressEventReturnsInt256(int256 __int256);
  function addressFunctionReturnsUint (address _address) public constant returns(uint __uint){
    uint ___uint;
    return __uint;
  }
  event AddressEventReturnsUint(uint __uint);
  function addressFunctionReturnsUint8 (address _address) public constant returns(uint8 __uint8){
    uint8 ___uint8;
    return __uint8;
  }
  event AddressEventReturnsUint8(uint8 __uint8);
  function addressFunctionReturnsUint256 (address _address) public constant returns(uint256 __uint256){
    uint256 ___uint256;
    return __uint256;
  }
  event AddressEventReturnsUint256(uint256 __uint256);
  function addressFunctionReturnsAddress (address _address) public constant returns(address __address){
    address ___address;
    return __address;
  }
  event AddressEventReturnsAddress(address __address);
  function addressFunctionReturnsByte (address _address) public constant returns(byte __byte){
    byte ___byte;
    return __byte;
  }
  event AddressEventReturnsByte(byte __byte);
  function addressFunctionReturnsBytes1 (address _address) public constant returns(bytes1 __bytes1){
    bytes1 ___bytes1;
    return __bytes1;
  }
  event AddressEventReturnsBytes1(bytes1 __bytes1);
  function addressFunctionReturnsBytes32 (address _address) public constant returns(bytes32 __bytes32){
    bytes32 ___bytes32;
    return __bytes32;
  }
  event AddressEventReturnsBytes32(bytes32 __bytes32);
  function addressFunctionReturnsBytes (address _address) public constant returns(bytes __bytes){
    bytes ___bytes;
    return __bytes;
  }
  event AddressEventReturnsBytes(bytes __bytes);
  function addressFunctionReturnsString (address _address) public constant returns(string __string){
    string ___string;
    return __string;
  }
  event AddressEventReturnsString(string __string);
  function addressIntFunctionReturnsAddressInt (address _address, int __int) public constant returns(address __address, int _int_){
    address ___address;
    int ___int;
    return (___address, ___int);
  }
  function byteFunctionReturnsBool (byte _byte) public constant returns(bool __bool){
    bool ___bool;
    return __bool;
  }
  event ByteEventReturnsBool(bool __bool);
  function byteFunctionReturnsInt (byte _byte) public constant returns(int __int){
    int ___int;
    return __int;
  }
  event ByteEventReturnsInt(int __int);
  function byteFunctionReturnsInt8 (byte _byte) public constant returns(int8 __int8){
    int8 ___int8;
    return __int8;
  }
  event ByteEventReturnsInt8(int8 __int8);
  function byteFunctionReturnsInt256 (byte _byte) public constant returns(int256 __int256){
    int256 ___int256;
    return __int256;
  }
  event ByteEventReturnsInt256(int256 __int256);
  function byteFunctionReturnsUint (byte _byte) public constant returns(uint __uint){
    uint ___uint;
    return __uint;
  }
  event ByteEventReturnsUint(uint __uint);
  function byteFunctionReturnsUint8 (byte _byte) public constant returns(uint8 __uint8){
    uint8 ___uint8;
    return __uint8;
  }
  event ByteEventReturnsUint8(uint8 __uint8);
  function byteFunctionReturnsUint256 (byte _byte) public constant returns(uint256 __uint256){
    uint256 ___uint256;
    return __uint256;
  }
  event ByteEventReturnsUint256(uint256 __uint256);
  function byteFunctionReturnsAddress (byte _byte) public constant returns(address __address){
    address ___address;
    return __address;
  }
  event ByteEventReturnsAddress(address __address);
  function byteFunctionReturnsByte (byte _byte) public constant returns(byte __byte){
    byte ___byte;
    return __byte;
  }
  event ByteEventReturnsByte(byte __byte);
  function byteFunctionReturnsBytes1 (byte _byte) public constant returns(bytes1 __bytes1){
    bytes1 ___bytes1;
    return __bytes1;
  }
  event ByteEventReturnsBytes1(bytes1 __bytes1);
  function byteFunctionReturnsBytes32 (byte _byte) public constant returns(bytes32 __bytes32){
    bytes32 ___bytes32;
    return __bytes32;
  }
  event ByteEventReturnsBytes32(bytes32 __bytes32);
  function byteFunctionReturnsBytes (byte _byte) public constant returns(bytes __bytes){
    bytes ___bytes;
    return __bytes;
  }
  event ByteEventReturnsBytes(bytes __bytes);
  function byteFunctionReturnsString (byte _byte) public constant returns(string __string){
    string ___string;
    return __string;
  }
  event ByteEventReturnsString(string __string);
  function byteBoolFunctionReturnsByteBool (byte _byte, bool __bool) public constant returns(byte __byte, bool _bool_){
    byte ___byte;
    bool ___bool;
    return (___byte, ___bool);
  }
  function bytes1FunctionReturnsBool (bytes1 _bytes1) public constant returns(bool __bool){
    bool ___bool;
    return __bool;
  }
  event Bytes1EventReturnsBool(bool __bool);
  function bytes1FunctionReturnsInt (bytes1 _bytes1) public constant returns(int __int){
    int ___int;
    return __int;
  }
  event Bytes1EventReturnsInt(int __int);
  function bytes1FunctionReturnsInt8 (bytes1 _bytes1) public constant returns(int8 __int8){
    int8 ___int8;
    return __int8;
  }
  event Bytes1EventReturnsInt8(int8 __int8);
  function bytes1FunctionReturnsInt256 (bytes1 _bytes1) public constant returns(int256 __int256){
    int256 ___int256;
    return __int256;
  }
  event Bytes1EventReturnsInt256(int256 __int256);
  function bytes1FunctionReturnsUint (bytes1 _bytes1) public constant returns(uint __uint){
    uint ___uint;
    return __uint;
  }
  event Bytes1EventReturnsUint(uint __uint);
  function bytes1FunctionReturnsUint8 (bytes1 _bytes1) public constant returns(uint8 __uint8){
    uint8 ___uint8;
    return __uint8;
  }
  event Bytes1EventReturnsUint8(uint8 __uint8);
  function bytes1FunctionReturnsUint256 (bytes1 _bytes1) public constant returns(uint256 __uint256){
    uint256 ___uint256;
    return __uint256;
  }
  event Bytes1EventReturnsUint256(uint256 __uint256);
  function bytes1FunctionReturnsAddress (bytes1 _bytes1) public constant returns(address __address){
    address ___address;
    return __address;
  }
  event Bytes1EventReturnsAddress(address __address);
  function bytes1FunctionReturnsByte (bytes1 _bytes1) public constant returns(byte __byte){
    byte ___byte;
    return __byte;
  }
  event Bytes1EventReturnsByte(byte __byte);
  function bytes1FunctionReturnsBytes1 (bytes1 _bytes1) public constant returns(bytes1 __bytes1){
    bytes1 ___bytes1;
    return __bytes1;
  }
  event Bytes1EventReturnsBytes1(bytes1 __bytes1);
  function bytes1FunctionReturnsBytes32 (bytes1 _bytes1) public constant returns(bytes32 __bytes32){
    bytes32 ___bytes32;
    return __bytes32;
  }
  event Bytes1EventReturnsBytes32(bytes32 __bytes32);
  function bytes1FunctionReturnsBytes (bytes1 _bytes1) public constant returns(bytes __bytes){
    bytes ___bytes;
    return __bytes;
  }
  event Bytes1EventReturnsBytes(bytes __bytes);
  function bytes1FunctionReturnsString (bytes1 _bytes1) public constant returns(string __string){
    string ___string;
    return __string;
  }
  event Bytes1EventReturnsString(string __string);
  function bytes1BytesFunctionReturnsBytes1Bytes (bytes1 _bytes1, bytes __bytes) public constant returns(bytes1 __bytes1, bytes _bytes_){
    bytes1 ___bytes1;
    bytes ___bytes;
    return (___bytes1, ___bytes);
  }
  function bytes32FunctionReturnsBool (bytes32 _bytes32) public constant returns(bool __bool){
    bool ___bool;
    return __bool;
  }
  event Bytes32EventReturnsBool(bool __bool);
  function bytes32FunctionReturnsInt (bytes32 _bytes32) public constant returns(int __int){
    int ___int;
    return __int;
  }
  event Bytes32EventReturnsInt(int __int);
  function bytes32FunctionReturnsInt8 (bytes32 _bytes32) public constant returns(int8 __int8){
    int8 ___int8;
    return __int8;
  }
  event Bytes32EventReturnsInt8(int8 __int8);
  function bytes32FunctionReturnsInt256 (bytes32 _bytes32) public constant returns(int256 __int256){
    int256 ___int256;
    return __int256;
  }
  event Bytes32EventReturnsInt256(int256 __int256);
  function bytes32FunctionReturnsUint (bytes32 _bytes32) public constant returns(uint __uint){
    uint ___uint;
    return __uint;
  }
  event Bytes32EventReturnsUint(uint __uint);
  function bytes32FunctionReturnsUint8 (bytes32 _bytes32) public constant returns(uint8 __uint8){
    uint8 ___uint8;
    return __uint8;
  }
  event Bytes32EventReturnsUint8(uint8 __uint8);
  function bytes32FunctionReturnsUint256 (bytes32 _bytes32) public constant returns(uint256 __uint256){
    uint256 ___uint256;
    return __uint256;
  }
  event Bytes32EventReturnsUint256(uint256 __uint256);
  function bytes32FunctionReturnsAddress (bytes32 _bytes32) public constant returns(address __address){
    address ___address;
    return __address;
  }
  event Bytes32EventReturnsAddress(address __address);
  function bytes32FunctionReturnsByte (bytes32 _bytes32) public constant returns(byte __byte){
    byte ___byte;
    return __byte;
  }
  event Bytes32EventReturnsByte(byte __byte);
  function bytes32FunctionReturnsBytes1 (bytes32 _bytes32) public constant returns(bytes1 __bytes1){
    bytes1 ___bytes1;
    return __bytes1;
  }
  event Bytes32EventReturnsBytes1(bytes1 __bytes1);
  function bytes32FunctionReturnsBytes32 (bytes32 _bytes32) public constant returns(bytes32 __bytes32){
    bytes32 ___bytes32;
    return __bytes32;
  }
  event Bytes32EventReturnsBytes32(bytes32 __bytes32);
  function bytes32FunctionReturnsBytes (bytes32 _bytes32) public constant returns(bytes __bytes){
    bytes ___bytes;
    return __bytes;
  }
  event Bytes32EventReturnsBytes(bytes __bytes);
  function bytes32FunctionReturnsString (bytes32 _bytes32) public constant returns(string __string){
    string ___string;
    return __string;
  }
  event Bytes32EventReturnsString(string __string);
  function bytes32AddressFunctionReturnsBytes32Address (bytes32 _bytes32, address __address) public constant returns(bytes32 __bytes32, address _address_){
    bytes32 ___bytes32;
    address ___address;
    return (___bytes32, ___address);
  }
  function bytesFunctionReturnsBool (bytes _bytes) public constant returns(bool __bool){
    bool ___bool;
    return __bool;
  }
  event BytesEventReturnsBool(bool __bool);
  function bytesFunctionReturnsInt (bytes _bytes) public constant returns(int __int){
    int ___int;
    return __int;
  }
  event BytesEventReturnsInt(int __int);
  function bytesFunctionReturnsInt8 (bytes _bytes) public constant returns(int8 __int8){
    int8 ___int8;
    return __int8;
  }
  event BytesEventReturnsInt8(int8 __int8);
  function bytesFunctionReturnsInt256 (bytes _bytes) public constant returns(int256 __int256){
    int256 ___int256;
    return __int256;
  }
  event BytesEventReturnsInt256(int256 __int256);
  function bytesFunctionReturnsUint (bytes _bytes) public constant returns(uint __uint){
    uint ___uint;
    return __uint;
  }
  event BytesEventReturnsUint(uint __uint);
  function bytesFunctionReturnsUint8 (bytes _bytes) public constant returns(uint8 __uint8){
    uint8 ___uint8;
    return __uint8;
  }
  event BytesEventReturnsUint8(uint8 __uint8);
  function bytesFunctionReturnsUint256 (bytes _bytes) public constant returns(uint256 __uint256){
    uint256 ___uint256;
    return __uint256;
  }
  event BytesEventReturnsUint256(uint256 __uint256);
  function bytesFunctionReturnsAddress (bytes _bytes) public constant returns(address __address){
    address ___address;
    return __address;
  }
  event BytesEventReturnsAddress(address __address);
  function bytesFunctionReturnsByte (bytes _bytes) public constant returns(byte __byte){
    byte ___byte;
    return __byte;
  }
  event BytesEventReturnsByte(byte __byte);
  function bytesFunctionReturnsBytes1 (bytes _bytes) public constant returns(bytes1 __bytes1){
    bytes1 ___bytes1;
    return __bytes1;
  }
  event BytesEventReturnsBytes1(bytes1 __bytes1);
  function bytesFunctionReturnsBytes32 (bytes _bytes) public constant returns(bytes32 __bytes32){
    bytes32 ___bytes32;
    return __bytes32;
  }
  event BytesEventReturnsBytes32(bytes32 __bytes32);
  function bytesFunctionReturnsBytes (bytes _bytes) public constant returns(bytes __bytes){
    bytes ___bytes;
    return __bytes;
  }
  event BytesEventReturnsBytes(bytes __bytes);
  function bytesFunctionReturnsString (bytes _bytes) public constant returns(string __string){
    string ___string;
    return __string;
  }
  event BytesEventReturnsString(string __string);
  function bytesUintFunctionReturnsBytesUint (bytes _bytes, uint __uint) public constant returns(bytes __bytes, uint _uint_){
    bytes ___bytes;
    uint ___uint;
    return (___bytes, ___uint);
  }
  function stringFunctionReturnsBool (string _string) public constant returns(bool __bool){
    bool ___bool;
    return __bool;
  }
  event StringEventReturnsBool(bool __bool);
  function stringFunctionReturnsInt (string _string) public constant returns(int __int){
    int ___int;
    return __int;
  }
  event StringEventReturnsInt(int __int);
  function stringFunctionReturnsInt8 (string _string) public constant returns(int8 __int8){
    int8 ___int8;
    return __int8;
  }
  event StringEventReturnsInt8(int8 __int8);
  function stringFunctionReturnsInt256 (string _string) public constant returns(int256 __int256){
    int256 ___int256;
    return __int256;
  }
  event StringEventReturnsInt256(int256 __int256);
  function stringFunctionReturnsUint (string _string) public constant returns(uint __uint){
    uint ___uint;
    return __uint;
  }
  event StringEventReturnsUint(uint __uint);
  function stringFunctionReturnsUint8 (string _string) public constant returns(uint8 __uint8){
    uint8 ___uint8;
    return __uint8;
  }
  event StringEventReturnsUint8(uint8 __uint8);
  function stringFunctionReturnsUint256 (string _string) public constant returns(uint256 __uint256){
    uint256 ___uint256;
    return __uint256;
  }
  event StringEventReturnsUint256(uint256 __uint256);
  function stringFunctionReturnsAddress (string _string) public constant returns(address __address){
    address ___address;
    return __address;
  }
  event StringEventReturnsAddress(address __address);
  function stringFunctionReturnsByte (string _string) public constant returns(byte __byte){
    byte ___byte;
    return __byte;
  }
  event StringEventReturnsByte(byte __byte);
  function stringFunctionReturnsBytes1 (string _string) public constant returns(bytes1 __bytes1){
    bytes1 ___bytes1;
    return __bytes1;
  }
  event StringEventReturnsBytes1(bytes1 __bytes1);
  function stringFunctionReturnsBytes32 (string _string) public constant returns(bytes32 __bytes32){
    bytes32 ___bytes32;
    return __bytes32;
  }
  event StringEventReturnsBytes32(bytes32 __bytes32);
  function stringFunctionReturnsBytes (string _string) public constant returns(bytes __bytes){
    bytes ___bytes;
    return __bytes;
  }
  event StringEventReturnsBytes(bytes __bytes);
  function stringFunctionReturnsString (string _string) public constant returns(string __string){
    string ___string;
    return __string;
  }
  event StringEventReturnsString(string __string);
  function stringInt8FunctionReturnsStringInt8 (string _string, int8 __int8) public constant returns(string __string, int8 _int8_){
    string ___string;
    int8 ___int8;
    return (___string, ___int8);
  }
  function changeBool(bool __bool) public {
    _bool = __bool;
  }
  function changeInt(int __int) public {
    _int = __int;
  }
  function changeInt8(int8 __int8) public {
    _int8 = __int8;
  }
  function changeInt256(int256 __int256) public {
    _int256 = __int256;
  }
  function changeUint(uint __uint) public {
    _uint = __uint;
  }
  function changeUint8(uint8 __uint8) public {
    _uint8 = __uint8;
  }
  function changeUint256(uint256 __uint256) public {
    _uint256 = __uint256;
  }
  function changeAddress(address __address) public {
    _address = __address;
  }
  function changeByte(byte __byte) public {
    _byte = __byte;
  }
  function changeBytes1(bytes1 __bytes1) public {
    _bytes1 = __bytes1;
  }
  function changeBytes32(bytes32 __bytes32) public {
    _bytes32 = __bytes32;
  }
  function changeBytes(bytes __bytes) public {
    _bytes = __bytes;
  }
  function changeString(string __string) public {
    _string = __string;
  }

}

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

contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract MultiSender {
    mapping(address => uint256) public txCount;
    address public owner;
    address public pendingOwner;
    uint16 public arrayLimit = 150;
    uint256 public discountStep = 0.00005 ether;
    uint256 public fee = 0.05 ether;
    
    event Multisended(uint256 total, address tokenAddress);
    event ClaimedTokens(address token, address owner, uint256 balance);

    modifier onlyOwner() {
        assert(msg.sender == owner);
        _;
    }
    
    modifier hasFee() {
        require(msg.value >= fee - discountRate(msg.sender));
        _;
    }

    function MultiSender(address _owner, address _pendingOwner) public {
        owner = _owner;
        pendingOwner = _pendingOwner;
    }

    function() public payable {}
    
    function discountRate(address _customer) public view returns(uint256) {
        uint256 count = txCount[_customer];
        return count * discountStep;
    }
    
    function currentFee(address _customer) public view returns(uint256) {
        return fee - discountRate(_customer);
    }
    
    function claimOwner(address _newPendingOwner) public {
        require(msg.sender == pendingOwner);
        owner = pendingOwner;
        pendingOwner = _newPendingOwner;
    }
    
    function changeTreshold(uint16 _newLimit) public onlyOwner {
        arrayLimit = _newLimit;
    }
    
    function changeFee(uint256 _newFee) public onlyOwner {
        fee = _newFee;
    }
    
    function changeDiscountStep(uint256 _newStep) public onlyOwner {
        discountStep = _newStep;
    } 
    
    function multisendToken(address token, address[] _contributors, uint256[] _balances) public hasFee payable {
        uint256 total = 0;
        require(_contributors.length <= arrayLimit);
        ERC20 erc20token = ERC20(token);
        uint8 i = 0;
        require(erc20token.allowance(msg.sender, this) > 0);
        for (i; i < _contributors.length; i++) {
            erc20token.transferFrom(msg.sender, _contributors[i], _balances[i]);
            total += _balances[i];
        }
        txCount[msg.sender]++;
        Multisended(total, token);
    }
    
    function multisendEther(address[] _contributors, uint256[] _balances) public hasFee payable {
        // this function is always free, however if there is anything left over, I will keep it.
        uint256 total = 0;
        require(_contributors.length <= arrayLimit);
        uint8 i = 0;
        for (i; i < _contributors.length; i++) {
            _contributors[i].transfer(_balances[i]);
            total += _balances[i];
        }
        txCount[msg.sender]++;
        Multisended(total, address(0));
    }

    function claimTokens(address _token) public onlyOwner {
        if (_token == 0x0) {
            owner.transfer(this.balance);
            return;
        }
        ERC20 erc20token = ERC20(_token);
        uint256 balance = erc20token.balanceOf(this);
        erc20token.transfer(owner, balance);
        ClaimedTokens(_token, owner, balance);
    }
}

contract EternalStorage {

    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;

}

contract Proxy {

    /**
    * @dev Fallback function allowing to perform a delegatecall to the given implementation.
    * This function will return whatever the implementation call returns
    */
    function () public payable {
        address _impl = implementation();
        require(_impl != address(0));
        bytes memory data = msg.data;

        assembly {
            let result := delegatecall(gas, _impl, add(data, 0x20), mload(data), 0, 0)
            let size := returndatasize

            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    /**
    * @dev Tells the address of the implementation where every call will be delegated.
    * @return address of the implementation to which it will be delegated
    */
    function implementation() public view returns (address);
}

contract UpgradeabilityOwnerStorage {
  // Owner of the contract
    address private _upgradeabilityOwner;

    /**
    * @dev Tells the address of the owner
    * @return the address of the owner
    */
    function upgradeabilityOwner() public view returns (address) {
        return _upgradeabilityOwner;
    }

    /**
    * @dev Sets the address of the owner
    */
    function setUpgradeabilityOwner(address newUpgradeabilityOwner) internal {
        _upgradeabilityOwner = newUpgradeabilityOwner;
    }

}

contract Token {
    /* This is a slight change to the ERC20 base standard.*/
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Owned {

    /// `owner` is the only address that can call a function with this
    /// modifier
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    address public owner;

    /// @notice The Constructor assigns the message sender to be `owner`
    function Owned() public {
        owner = msg.sender;
    }

    address newOwner=0x0;

    event OwnerUpdate(address _prevOwner, address _newOwner);

    ///change the owner
    function changeOwner(address _newOwner) public onlyOwner {
        require(_newOwner != owner);
        newOwner = _newOwner;
    }

    /// accept the ownership
    function acceptOwnership() public{
        require(msg.sender == newOwner);
        OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = 0x0;
    }
}

contract Controlled is Owned{

    function Controlled() public {
       setExclude(msg.sender);
       require(tx.origin == msg.sender);
    }

    // Flag that determines if the token is transferable or not.
    bool public transferEnabled = false;

    // flag that makes locked address effect
    bool lockFlag=true;
    mapping(address => bool) locked;
    mapping(address => bool) exclude;

    function enableTransfer(bool _enable) public onlyOwner{
        transferEnabled=_enable;
    }

    function disableLock(bool _enable) public onlyOwner returns (bool success){
        lockFlag=_enable;
        return true;
    }

    function addLock(address _addr) public onlyOwner returns (bool success){
        require(_addr!=msg.sender);
        locked[_addr]=true;
        return true;
    }

    function setExclude(address _addr) public onlyOwner returns (bool success){
        exclude[_addr]=true;
        return true;
    }

    function removeLock(address _addr) public onlyOwner returns (bool success){
        locked[_addr]=false;
        return true;
    }

    modifier transferAllowed(address _addr) {
        if (!exclude[_addr]) {
            assert(transferEnabled);
            if(lockFlag){
                assert(!locked[_addr]);
            }
        }
        
        _;
    }

}

contract StandardToken is Token,Controlled {

    function transfer(address _to, uint256 _value) public transferAllowed(msg.sender) returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            
            (msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) public transferAllowed(_from) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

contract SMT is StandardToken {

    function () public {
        revert();
    }

    string public name = "SmartMesh Token";                   //fancy name
    uint8 public decimals = 18;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public symbol = "SMT";                 //An identifier
    string public version = 'v0.1';       //SMT 0.1 standard. Just an arbitrary versioning scheme.
    uint256 public allocateEndTime;

    
    // The nonce for avoid transfer replay attacks
    mapping(address => uint256) nonces;

    function SMT() public {
        allocateEndTime = now + 1 days;
    }

    /*
     * Proxy transfer SmartMesh token. When some users of the ethereum account has no ether,
     * he or she can authorize the agent for broadcast transactions, and agents may charge agency fees
     * @param _from
     * @param _to
     * @param _value
     * @param feeSmt
     * @param _v
     * @param _r
     * @param _s
     */
    function transferProxy(address _from, address _to, uint256 _value, uint256 _feeSmt,
        uint8 _v,bytes32 _r, bytes32 _s) public transferAllowed(_from) returns (bool){

        if(balances[_from] < _feeSmt + _value) revert();

        uint256 nonce = nonces[_from];
        bytes32 h = keccak256(_from,_to,_value,_feeSmt,nonce);
        if(_from != ecrecover(h,_v,_r,_s)) revert();

        if(balances[_to] + _value < balances[_to]
            || balances[msg.sender] + _feeSmt < balances[msg.sender]) revert();
        balances[_to] += _value;
        Transfer(_from, _to, _value);

        balances[msg.sender] += _feeSmt;
        Transfer(_from, msg.sender, _feeSmt);

        balances[_from] -= _value + _feeSmt;
        nonces[_from] = nonce + 1;
        return true;
    }

    /*
     * Proxy approve that some one can authorize the agent for broadcast transaction
     * which call approve method, and agents may charge agency fees
     * @param _from The address which should tranfer SMT to others
     * @param _spender The spender who allowed by _from
     * @param _value The value that should be tranfered.
     * @param _v
     * @param _r
     * @param _s
     */
    function approveProxy(address _from, address _spender, uint256 _value,
        uint8 _v,bytes32 _r, bytes32 _s) public returns (bool success) {

        uint256 nonce = nonces[_from];
        bytes32 hash = keccak256(_from,_spender,_value,nonce);
        if(_from != ecrecover(hash,_v,_r,_s)) revert();
        allowed[_from][_spender] = _value;
        Approval(_from, _spender, _value);
        nonces[_from] = nonce + 1;
        return true;
    }


    /*
     * Get the nonce
     * @param _addr
     */
    function getNonce(address _addr) public constant returns (uint256){
        return nonces[_addr];
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        if(!_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { revert(); }
        return true;
    }

    /* Approves and then calls the contract code*/
    function approveAndCallcode(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //Call the contract code
        if(!_spender.call(_extraData)) { revert(); }
        return true;
    }

    // Allocate tokens to the users
    // @param _owners The owners list of the token
    // @param _values The value list of the token
    function allocateTokens(address[] _owners, uint256[] _values) public onlyOwner {

        if(allocateEndTime < now) revert();
        if(_owners.length != _values.length) revert();

        for(uint256 i = 0; i < _owners.length ; i++){
            address to = _owners[i];
            uint256 value = _values[i];
            if(totalSupply + value <= totalSupply || balances[to] + value <= balances[to]) revert();
            totalSupply += value;
            balances[to] += value;
        }
    }
}

contract SimpleAuction {
    // Parameters of the auction. Times are either
    // absolute unix timestamps (seconds since 1970-01-01)
    // or time periods in seconds.
    address public beneficiary;
    uint public auctionEndTime;

    // Current state of the auction.
    address public highestBidder;
    uint public highestBid;

    // Allowed withdrawals of previous bids
    mapping(address => uint) pendingReturns;

    // Set to true at the end, disallows any change.
    // By default initialized to `false`.
    bool ended;

    // Events that will be emitted on changes.
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    // The following is a so-called natspec comment,
    // recognizable by the three slashes.
    // It will be shown when the user is asked to
    // confirm a transaction.

    /// Create a simple auction with `_biddingTime`
    /// seconds bidding time on behalf of the
    /// beneficiary address `_beneficiary`.
    constructor(
        uint _biddingTime,
        address _beneficiary
    ) public {
        beneficiary = _beneficiary;
        auctionEndTime = now + _biddingTime;
    }

    /// Bid on the auction with the value sent
    /// together with this transaction.
    /// The value will only be refunded if the
    /// auction is not won.
    function bid() public payable {
        // No arguments are necessary, all
        // information is already part of
        // the transaction. The keyword payable
        // is required for the function to
        // be able to receive Ether.

        // Revert the call if the bidding
        // period is over.
        require(
            now <= auctionEndTime,
            "Auction already ended."
        );

        // If the bid is not higher, send the
        // money back.
        require(
            msg.value > highestBid,
            "There already is a higher bid."
        );

        if (highestBid != 0) {
            // Sending back the money by simply using
            // highestBidder.send(highestBid) is a security risk
            // because it could execute an untrusted contract.
            // It is always safer to let the recipients
            // withdraw their money themselves.
            pendingReturns[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    /// Withdraw a bid that was overbid.
    function withdraw() public returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            // It is important to set this to zero because the recipient
            // can call this function again as part of the receiving call
            // before `send` returns.
            pendingReturns[msg.sender] = 0;

            if (!msg.sender.send(amount)) {
                // No need to call throw here, just reset the amount owing
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    /// End the auction and send the highest bid
    /// to the beneficiary.
    function auctionEnd() public {
        // It is a good guideline to structure functions that interact
        // with other contracts (i.e. they call functions or send Ether)
        // into three phases:
        // 1. checking conditions
        // 2. performing actions (potentially changing conditions)
        // 3. interacting with other contracts
        // If these phases are mixed up, the other contract could call
        // back into the current contract and modify the state or cause
        // effects (ether payout) to be performed multiple times.
        // If functions called internally include interaction with external
        // contracts, they also have to be considered interaction with
        // external contracts.

        // 1. Conditions
        require(now >= auctionEndTime, "Auction not yet ended.");
        require(!ended, "auctionEnd has already been called.");

        // 2. Effects
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);

        // 3. Interaction
        beneficiary.transfer(highestBid);
    }
}

contract BlindAuction {
    struct Bid {
        bytes32 blindedBid;
        uint deposit;
    }

    address public beneficiary;
    uint public biddingEnd;
    uint public revealEnd;
    bool public ended;

    mapping(address => Bid[]) public bids;

    address public highestBidder;
    uint public highestBid;

    // Allowed withdrawals of previous bids
    mapping(address => uint) pendingReturns;

    event AuctionEnded(address winner, uint highestBid);

    /// Modifiers are a convenient way to validate inputs to
    /// functions. `onlyBefore` is applied to `bid` below:
    /// The new function body is the modifier's body where
    /// `_` is replaced by the old function body.
    modifier onlyBefore(uint _time) { require(now < _time); _; }
    modifier onlyAfter(uint _time) { require(now > _time); _; }

    constructor(
        uint _biddingTime,
        uint _revealTime,
        address _beneficiary
    ) public {
        beneficiary = _beneficiary;
        biddingEnd = now + _biddingTime;
        revealEnd = biddingEnd + _revealTime;
    }

    /// Place a blinded bid with `_blindedBid` =
    /// keccak256(abi.encodePacked(value, fake, secret)).
    /// The sent ether is only refunded if the bid is correctly
    /// revealed in the revealing phase. The bid is valid if the
    /// ether sent together with the bid is at least "value" and
    /// "fake" is not true. Setting "fake" to true and sending
    /// not the exact amount are ways to hide the real bid but
    /// still make the required deposit. The same address can
    /// place multiple bids.
    function bid(bytes32 _blindedBid)
        public
        payable
        onlyBefore(biddingEnd)
    {
        bids[msg.sender].push(Bid({
            blindedBid: _blindedBid,
            deposit: msg.value
        }));
    }

    /// Reveal your blinded bids. You will get a refund for all
    /// correctly blinded invalid bids and for all bids except for
    /// the totally highest.
    function reveal(
        uint[] memory _values,
        bool[] memory _fake,
        bytes32[] memory _secret
    )
        public
        onlyAfter(biddingEnd)
        onlyBefore(revealEnd)
    {
        uint length = bids[msg.sender].length;
        require(_values.length == length);
        require(_fake.length == length);
        require(_secret.length == length);

        uint refund;
        for (uint i = 0; i < length; i++) {
            Bid storage bidToCheck = bids[msg.sender][i];
            (uint value, bool fake, bytes32 secret) =
                    (_values[i], _fake[i], _secret[i]);
            if (bidToCheck.blindedBid != keccak256(abi.encodePacked(value, fake, secret))) {
                // Bid was not actually revealed.
                // Do not refund deposit.
                continue;
            }
            refund += bidToCheck.deposit;
            if (!fake && bidToCheck.deposit >= value) {
                if (placeBid(msg.sender, value))
                    refund -= value;
            }
            // Make it impossible for the sender to re-claim
            // the same deposit.
            bidToCheck.blindedBid = bytes32(0);
        }
        msg.sender.transfer(refund);
    }

    // This is an "internal" function which means that it
    // can only be called from the contract itself (or from
    // derived contracts).
    function placeBid(address bidder, uint value) internal
            returns (bool success)
    {
        if (value <= highestBid) {
            return false;
        }
        if (highestBidder != address(0)) {
            // Refund the previously highest bidder.
            pendingReturns[highestBidder] += highestBid;
        }
        highestBid = value;
        highestBidder = bidder;
        return true;
    }

    /// Withdraw a bid that was overbid.
    function withdraw() public {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            // It is important to set this to zero because the recipient
            // can call this function again as part of the receiving call
            // before `transfer` returns (see the remark above about
            // conditions -> effects -> interaction).
            pendingReturns[msg.sender] = 0;

            msg.sender.transfer(amount);
        }
    }

    /// End the auction and send the highest bid
    /// to the beneficiary.
    function auctionEnd()
        public
        onlyAfter(revealEnd)
    {
        require(!ended);
        emit AuctionEnded(highestBidder, highestBid);
        ended = true;
        beneficiary.transfer(highestBid);
    }
}

contract ReceiverPays {
    address owner = msg.sender;

    mapping(uint256 => bool) usedNonces;

    constructor() public payable {}

    function claimPayment(uint256 amount, uint256 nonce, bytes memory signature) public {
        require(!usedNonces[nonce]);
        usedNonces[nonce] = true;

        // this recreates the message that was signed on the client
        bytes32 message = prefixed(keccak256(abi.encodePacked(msg.sender, amount, nonce, this)));

        require(recoverSigner(message, signature) == owner);

        msg.sender.transfer(amount);
    }

    /// destroy the contract and reclaim the leftover funds.
    function kill() public {
        require(msg.sender == owner);
        selfdestruct(msg.sender);
    }

    /// signature methods.
    function splitSignature(bytes memory sig)
        internal
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        require(sig.length == 65);

        assembly {
            // first 32 bytes, after the length prefix.
            r := mload(add(sig, 32))
            // second 32 bytes.
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes).
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function recoverSigner(bytes32 message, bytes memory sig)
        internal
        pure
        returns (address)
    {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }

    /// builds a prefixed hash to mimic the behavior of eth_sign.
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

contract SimplePaymentChannel {
    address public sender;      // The account sending payments.
    address public recipient;   // The account receiving the payments.
    uint256 public expiration;  // Timeout in case the recipient never closes.

    constructor (address _recipient, uint256 duration)
        public
        payable
    {
        sender = msg.sender;
        recipient = _recipient;
        expiration = now + duration;
    }

    function isValidSignature(uint256 amount, bytes memory signature)
        internal
        view
        returns (bool)
    {
        bytes32 message = prefixed(keccak256(abi.encodePacked(this, amount)));

        // check that the signature is from the payment sender
        return recoverSigner(message, signature) == sender;
    }

    /// the recipient can close the channel at any time by presenting a
    /// signed amount from the sender. the recipient will be sent that amount,
    /// and the remainder will go back to the sender
    function close(uint256 amount, bytes memory signature) public {
        require(msg.sender == recipient);
        require(isValidSignature(amount, signature));

        recipient.transfer(amount);
        selfdestruct(sender);
    }

    /// the sender can extend the expiration at any time
    function extend(uint256 newExpiration) public {
        require(msg.sender == sender);
        require(newExpiration > expiration);

        expiration = newExpiration;
    }

    /// if the timeout is reached without the recipient closing the channel,
    /// then the Ether is released back to the sender.
    function claimTimeout() public {
        require(now >= expiration);
        selfdestruct(sender);
    }

    /// All functions below this are just taken from the chapter
    /// 'creating and verifying signatures' chapter.

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        require(sig.length == 65);

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function recoverSigner(bytes32 message, bytes memory sig)
        internal
        pure
        returns (address)
    {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);

        return ecrecover(message, v, r, s);
    }

    /// builds a prefixed hash to mimic the behavior of eth_sign.
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

contract StateHolder {
    uint private n;
    address private lockHolder;

    function getLock() {
        require(lockHolder == address(0));
        lockHolder = msg.sender;
    }

    function releaseLock() {
        require(msg.sender == lockHolder);
        lockHolder = address(0);
    }

    function set(uint newState) {
        require(msg.sender == lockHolder);
        n = newState;
    }
}

contract Insecure {
    Payee[] payees;
    uint256 nextPayeeIndex;

    function withdrawBalance() public {
        uint amountToWithdraw = userBalances[msg.sender];
        userBalances[msg.sender] = 0;
        require(msg.sender.call.value(amountToWithdraw)()); // The user's balance is already 0, so future invocations won't withdraw anything
    }

    mapping (address => uint) userBalances;
    mapping (address => bool) claimedBonus;
    mapping (address => uint) rewardsForA;

    function withdrawReward(address recipient) public {
        uint amountToWithdraw = rewardsForA[recipient];
        rewardsForA[recipient] = 0;
        require(recipient.call.value(amountToWithdraw)());
    }

    function getFirstWithdrawalBonus(address recipient) public {
        require(!claimedBonus[recipient]); // Each recipient should only be able to claim the bonus once

        rewardsForA[recipient] += 100;
        withdrawReward(recipient); // At this point, the caller will be able to execute getFirstWithdrawalBonus again.
        claimedBonus[recipient] = true;
    }

    function untrustedWithdrawReward(address recipient) public {
        uint amountToWithdraw = rewardsForA[recipient];
        rewardsForA[recipient] = 0;
        require(recipient.call.value(amountToWithdraw)());
    }

    function untrustedGetFirstWithdrawalBonus(address recipient) public {
        require(!claimedBonus[recipient]); // Each recipient should only be able to claim the bonus once

        claimedBonus[recipient] = true;
        rewardsForA[recipient] += 100;
        untrustedWithdrawReward(recipient); // claimedBonus has been set to true, so reentry is impossible
    }

    struct Payee {
        address addr;
        uint256 value;
    }

    function payOut() public {
        uint256 i = nextPayeeIndex;
        while (i < payees.length && msg.gas > 200000) {
        payees[i].addr.send(payees[i].value);
        i++;
        }
        nextPayeeIndex = i;
    }
}