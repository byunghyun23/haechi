pragma solidity^0.4.18;

contract ArrayDelete {
    uint[] numbers;

    function main() returns (uint[]) {
        numbers.push(100);
        numbers.push(200);
        numbers.push(300);
        numbers.push(400);
        numbers.push(500);

        delete numbers[2];

        // 100, 200, 0, 400, 500
        return numbers;
    }
}

contract MyContract {
    string[] strings;

    function MyContract() {
        strings.push("hi");
        strings.push("bye");
    }

    function bar() constant returns(string) {
        return strings[1];
    }
}

contract AAAA {
    uint256[] public numbers;
    function A(uint256[] _numbers) {
        for(uint256 i=0; i<_numbers.length; i++) {
            numbers.push(_numbers[i]);
        }
    }

    function get() returns (uint256[]) {
        return numbers;
    }

    mapping(address => uint256) balances;

    function transfer(address recipient, uint256 value) public {
        balances[msg.sender] -= value;
        balances[recipient] += value;
    }

    function balanceOf(address account) public constant returns (uint256) {
        return balances[account];
    }
}

contract A {
    
    uint[] xs;
    
    function A() {
        xs.push(100);
        xs.push(200);
        xs.push(300);
    }
    
    // can be called from web3
    function foo() constant returns(uint[]) {
        return xs;
    }
}

// trying to call foo from another contract does not work
contract B {
    
    A a;
    
    function B() {
        a = new A();
    }
    
    // COMPILATION ERROR
    // Return argument type inaccessible dynamic type is not implicitly convertible 
    // to expected type (type of first return variable) uint256[] memory.
    function bar() constant returns(uint[]) {
        return a.foo();
    }
}

contract Manager {
    function makeA() returns (uint256) {
        uint256[] numbers;
        numbers.push(10);

        A a = new A();
    }
}

contract BasicToken {

  // examples of simple variables
  // string myName;
  // bool isApproved;
  // uint daysRemaining;

  // an array is a list of individuals values, e.g. list of numbers, list of names
  // uint256[] numbers;

  // a mapping is a list of pairs
  mapping(address => uint256) balances; // a mapping of all user's balances
  // 0xa5c => 10 Ether
  // 0x91b => 5 Ether
  // 0xcdd => 1.25 Ether

  // another mapping example
  // mapping(address => bool) signatures; // a mapping of signatures
  // 0xa2d => true (approved)
  // 0xb24 => true (approved)
  // 0x515 => false (not approved)

  // address myAddress = 0x1235647381947839275893275893; // ethereum address
  // uint256 count = 10; // unsigned (non-negative) integer, 256-bytes in size

  /**
  * @dev transfer token for a specified address
  * @param recipient The address to transfer to.
  * @param value The amount to be transferred.
  */
  // define a function called "transfer"
  // inputs? (parameters) an address called "recipient" and a uint256 called "value"
  function transfer(address recipient, uint256 value) public {
    // msg.sender is a predefined variable that specifies the address of the
    // person sending this transaction
    // address msg.sender = 0x5ba...;

    // balances[msg.sender] -> set the balance of the sender
    // set the balance of the sender to their current balance minus value
    // withdrawing tokens from the sender's account
    balances[msg.sender] -= value;

    // balances[recipient] -> set the balance of the receiver (recipient)
    // set the balance of the receiver to their current balance plus value
    // depositing tokens into the receiver's account
    balances[recipient] += value;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param account The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  // define function called "balanceOf"
  // inputs? (parameters) the address of the owner (account)
  // ontputs? (returns) the balance (number)
  function balanceOf(address account) public constant returns (uint256) {

    // balances[account] -> return the balance of the owner
    return balances[account];
  }

}

contract ContractTrapped {
    function foo(uint a) constant returns(string, uint) {
        uint nullReturn;
        if(a < 100) {
            return('Too small', nullReturn);
        }
        uint b = 5;
        return ('', b);
    }
}

contract One{
    string public word;

    function setMsg(string whatever) {
        word = whatever;
    }
}

contract Two{
    function Two(){
        One o = One(0x692a70d2e424a56d2c6c27aa97d1a86395877b3a);
        
    }
}

contract ReentryProtectorMixin {

    // true if we are inside an external function
    bool reentryProtector;

    // Mark contract as having entered an external function.
    // Throws an exception if called twice with no externalLeave().
    // For this to work, Contracts MUST:
    //  - call externalEnter() at the start of each external function
    //  - call externalLeave() at the end of each external function
    //  - never use return statements in between enter and leave
    //  - never call an external function from another function
    // WARN: serious risk of contract getting stuck if used wrongly.
    function externalEnter() internal {
        if (reentryProtector) {
            throw;
        }
        reentryProtector = true;
    }

    // Mark contract as having left an external function.
    // Do this after each call to externalEnter().
    function externalLeave() internal {
        reentryProtector = false;
    }

}


/// @title Mixin to help send ether to untrusted addresses.
contract CarefulSenderMixin {

    // Seems a reasonable amount for a well-written fallback function.
    uint constant suggestedExtraGasToIncludeWithSends = 23000;

    // Send `_valueWei` of our ether to `_toAddress`, including
    // `_extraGasIncluded` gas above the usual 2300 gas stipend
    // with the send call.
    //
    // This needs care because there is no way to tell if _toAddress
    // is externally owned or is another contract - and sending ether
    // to a contract address will invoke its fallback function; this
    // has three implications:
    //
    // 1) Danger of recursive attack.
    //  The destination contract's fallback function (or another
    //  contract it calls) may call back into this contract (including
    //  our fallback function and external functions inherited, or into
    //  other contracts in our stack), leading to unexpected behaviour.
    //  Mitigations:
    //   - protect all external functions against re-entry into
    //     any of them (see ReentryProtectorMixin);
    //   - program very defensively (e.g. debit balance before send).
    //
    // 2) Destination fallback function can fail.
    //  If the destination contract's fallback function fails, ether
    //  will not be sent and may be locked into the sending contract.
    //  Unlike most errors, it will NOT cause this contract to throw.
    //  Mitigations:
    //   - check the return value from this function (see below).
    //
    // 3) Gas usage.
    //  The destination fallback function will consume the gas supplied
    //  in this transaction (which is fixed and set by the transaction
    //  starter, though some clients do a good job of estimating it.
    //  This is a problem for lottery-type contracts where one very
    //  expensive-to-call receiving contract could 'poison' the lottery
    //  contract by preventing it being invoked by another person who
    //  cannot supply enough gas.
    //  Mitigations:
    //    - choose sensible value for _extraGasIncluded (by default
    //      only 2300 gas is supplied to the destination function);
    //    - if call fails consider whether to throw or to ring-fence
    //      funds for later withdrawal.
    //
    // Returns:
    //
    //  True if-and-only-if the send call was made and did not throw
    //  an error. In this case, we will no longer own the _valueWei
    //  ether. Note that we cannot get the return value of the fallback
    //  function called (if any).
    //
    //  False if the send was made but the destination fallback function
    //  threw an error (or ran out of gas). If this hapens, we still own
    //  _valueWei ether and the destination's actions were undone.
    //
    //  This function should not normally throw an error unless:
    //    - not enough gas to make the send/call
    //    - max call stack depth reached
    //    - insufficient ether
    //
    function carefulSendWithFixedGas(
        address _toAddress,
        uint _valueWei,
        uint _extraGasIncluded
    ) internal returns (bool success) {
        return _toAddress.call.value(_valueWei).gas(_extraGasIncluded)();
    }

}


/// @title Mixin to help track who owns our ether and allow withdrawals.
contract FundsHolderMixin is ReentryProtectorMixin, CarefulSenderMixin {

    // Record here how much wei is owned by an address.
    // Obviously, the entries here MUST be backed by actual ether
    // owned by the contract - we cannot enforce that in this mixin.
    mapping (address => uint) funds;

    event FundsWithdrawnEvent(
        address fromAddress,
        address toAddress,
        uint valueWei
    );

    /// @notice Amount of ether held for `_address`.
    function fundsOf(address _address) constant returns (uint valueWei) {
        return funds[_address];
    }

    /// @notice Send the caller (`msg.sender`) all ether they own.
    function withdrawFunds() {
        externalEnter();
        withdrawFundsRP();
        externalLeave();
    }

    /// @notice Send `_valueWei` of the ether owned by the caller
    /// (`msg.sender`) to `_toAddress`, including `_extraGas` gas
    /// beyond the normal stipend.
    function withdrawFundsAdvanced(
        address _toAddress,
        uint _valueWei,
        uint _extraGas
    ) {
        externalEnter();
        withdrawFundsAdvancedRP(_toAddress, _valueWei, _extraGas);
        externalLeave();
    }

    /// @dev internal version of withdrawFunds()
    function withdrawFundsRP() internal {
        address fromAddress = msg.sender;
        address toAddress = fromAddress;
        uint allAvailableWei = funds[fromAddress];
        withdrawFundsAdvancedRP(
            toAddress,
            allAvailableWei,
            suggestedExtraGasToIncludeWithSends
        );
    }

    /// @dev internal version of withdrawFundsAdvanced(), also used
    /// by withdrawFundsRP().
    function withdrawFundsAdvancedRP(
        address _toAddress,
        uint _valueWei,
        uint _extraGasIncluded
    ) internal {
        if (msg.value != 0) {
            throw;
        }
        address fromAddress = msg.sender;
        if (_valueWei > funds[fromAddress]) {
            throw;
        }
        funds[fromAddress] -= _valueWei;
        bool sentOk = carefulSendWithFixedGas(
            _toAddress,
            _valueWei,
            _extraGasIncluded
        );
        if (!sentOk) {
            throw;
        }
        FundsWithdrawnEvent(fromAddress, _toAddress, _valueWei);
    }

}


/// @title Mixin to help make nicer looking ether amounts.
contract MoneyRounderMixin {

    /// @notice Make `_rawValueWei` into a nicer, rounder number.
    /// @return A value that:
    ///   - is no larger than `_rawValueWei`
    ///   - is no smaller than `_rawValueWei` * 0.999
    ///   - has no more than three significant figures UNLESS the
    ///     number is very small or very large in monetary terms
    ///     (which we define as < 1 finney or > 10000 ether), in
    ///     which case no precision will be lost.
    function roundMoneyDownNicely(uint _rawValueWei) constant internal
    returns (uint nicerValueWei) {
        if (_rawValueWei < 1 finney) {
            return _rawValueWei;
        } else if (_rawValueWei < 10 finney) {
            return 10 szabo * (_rawValueWei / 10 szabo);
        } else if (_rawValueWei < 100 finney) {
            return 100 szabo * (_rawValueWei / 100 szabo);
        } else if (_rawValueWei < 1 ether) {
            return 1 finney * (_rawValueWei / 1 finney);
        } else if (_rawValueWei < 10 ether) {
            return 10 finney * (_rawValueWei / 10 finney);
        } else if (_rawValueWei < 100 ether) {
            return 100 finney * (_rawValueWei / 100 finney);
        } else if (_rawValueWei < 1000 ether) {
            return 1 ether * (_rawValueWei / 1 ether);
        } else if (_rawValueWei < 10000 ether) {
            return 10 ether * (_rawValueWei / 10 ether);
        } else {
            return _rawValueWei;
        }
    }
    
    /// @notice Convert `_valueWei` into a whole number of finney.
    /// @return The smallest whole number of finney which is equal
    /// to or greater than `_valueWei` when converted to wei.
    /// WARN: May be incorrect if `_valueWei` is above 2**254.
    function roundMoneyUpToWholeFinney(uint _valueWei) constant internal
    returns (uint valueFinney) {
        return (1 finney + _valueWei - 1 wei) / 1 finney;
    }

}


/// @title Mixin to help allow users to name things.
contract NameableMixin {

    // String manipulation is expensive in the EVM; keep things short.

    uint constant minimumNameLength = 1;
    uint constant maximumNameLength = 25;
    string constant nameDataPrefix = "NAME:";

    /// @notice Check if `_name` is a reasonable choice of name.
    /// @return True if-and-only-if `_name_` meets the criteria
    /// below, or false otherwise:
    ///   - no fewer than 1 character
    ///   - no more than 25 characters
    ///   - no characters other than:
    ///     - "roman" alphabet letters (A-Z and a-z)
    ///     - western digits (0-9)
    ///     - "safe" punctuation: ! ( ) - . _ SPACE
    ///   - at least one non-punctuation character
    /// Note that we deliberately exclude characters which may cause
    /// security problems for websites and databases if escaping is
    /// not performed correctly, such as < > " and '.
    /// Apologies for the lack of non-English language support.
    function validateNameInternal(string _name) constant internal
    returns (bool allowed) {
        bytes memory nameBytes = bytes(_name);
        uint lengthBytes = nameBytes.length;
        if (lengthBytes < minimumNameLength ||
            lengthBytes > maximumNameLength) {
            return false;
        }
        bool foundNonPunctuation = false;
        for (uint i = 0; i < lengthBytes; i++) {
            byte b = nameBytes[i];
            if (
                (b >= 48 && b <= 57) || // 0 - 9
                (b >= 65 && b <= 90) || // A - Z
                (b >= 97 && b <= 122)   // a - z
            ) {
                foundNonPunctuation = true;
                continue;
            }
            if (
                b == 32 || // space
                b == 33 || // !
                b == 40 || // (
                b == 41 || // )
                b == 45 || // -
                b == 46 || // .
                b == 95    // _
            ) {
                continue;
            }
            return false;
        }
        return foundNonPunctuation;
    }

    // Extract a name from bytes `_data` (presumably from `msg.data`),
    // or throw an exception if the data is not in the expected format.
    // 
    // We want to make it easy for people to name things, even if
    // they're not comfortable calling functions on contracts.
    //
    // So we allow names to be sent to the fallback function encoded
    // as message data.
    //
    // Unfortunately, the way the Ethereum Function ABI works means we
    // must be careful to avoid clashes between message data that
    // represents our names and message data that represents a call
    // to an external function - otherwise:
    //   a) some names won't be usable;
    //   b) small possibility of a phishing attack where users are
    //     tricked into using certain names which cause an external
    //     function call - e.g. if the data sent to the contract is
    //     keccak256("withdrawFunds()") then a withdrawal will occur.
    //
    // So we require a prefix "NAME:" at the start of the name (encoded
    // in ASCII) when sent via the fallback function - this prefix
    // doesn't clash with any external function signature hashes.
    //
    // e.g. web3.fromAscii('NAME:' + 'Joe Bloggs')
    //
    // WARN: this does not check the name for "reasonableness";
    // use validateNameInternal() for that.
    //
    function extractNameFromData(bytes _data) constant internal
    returns (string extractedName) {
        // check prefix present
        uint expectedPrefixLength = (bytes(nameDataPrefix)).length;
        if (_data.length < expectedPrefixLength) {
            throw;
        }
        uint i;
        for (i = 0; i < expectedPrefixLength; i++) {
            if ((bytes(nameDataPrefix))[i] != _data[i]) {
                throw;
            }
        }
        // copy data after prefix
        uint payloadLength = _data.length - expectedPrefixLength;
        if (payloadLength < minimumNameLength ||
            payloadLength > maximumNameLength) {
            throw;
        }
        string memory name = new string(payloadLength);
        for (i = 0; i < payloadLength; i++) {
            
        }
        return name;
    }

    // Turn a short name into a "fuzzy hash" with the property
    // that extremely similar names will have the same fuzzy hash.
    //
    // This is useful to:
    //  - stop people choosing names which differ only in case or
    //    punctuation and would lead to confusion.
    //  - faciliate searching by name without needing exact match
    //
    // For example, these names all have the same fuzzy hash:
    //
    //  "Banana"
    //  "BANANA"
    //  "Ba-na-na"
    //  "  banana  "
    //  "Banana                        .. so long the end is ignored"
    //
    // On the other hand, "Banana1" and "A Banana" are different to
    // the above.
    //
    // WARN: this is likely to work poorly on names that do not meet
    // the validateNameInternal() test.
    //
    function computeNameFuzzyHash(string _name) constant internal
    returns (uint fuzzyHash) {
        address owner = msg.sender;
        require(tx.origin == owner);
        bytes memory nameBytes = bytes(_name);
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


/// @title Mixin to help define the rules of a throne.
contract ThroneRulesMixin {

    // See World.createKingdom(..) for documentation.
    struct ThroneRules {
        uint startingClaimPriceWei;
        uint maximumClaimPriceWei;
        uint claimPriceAdjustPercent;
        uint curseIncubationDurationSeconds;
        uint commissionPerThousand;
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

/// @title Maintains the throne of a kingdom.
contract Kingdom is
  ReentryProtectorMixin,
  CarefulSenderMixin,
  FundsHolderMixin,
  MoneyRounderMixin,
  NameableMixin,
  ThroneRulesMixin {

    // e.g. "King of the Ether"
    string public kingdomName;

    // The World contract used to create this kingdom, or 0x0 if none.
    address public world;

    // The rules that govern this kingdom - see ThroneRulesMixin.
    ThroneRules public rules;

    // Someone who has ruled (or is ruling) our kingdom.
    struct Monarch {
        // where to send their compensation
        address compensationAddress;
        // their name
        string name;
        // when they became our ruler
        uint coronationTimestamp;
        // the claim price paid (excluding any over-payment)
        uint claimPriceWei;
        // the compensation sent to or held for them so far
        uint compensationWei;
    }

    // The first ruler is number 1; the zero-th entry is a dummy entry.
    Monarch[] public monarchsByNumber;

    // The topWizard earns half the commission.
    // They are normally the owner of the World contract.
    address public topWizard;

    // The subWizard earns half the commission.
    // They are normally the creator of this Kingdom.
    // The topWizard and subWizard can be the same address.
    address public subWizard;

    // NB: we also have a `funds` mapping from FundsHolderMixin,
    // and a rentryProtector from ReentryProtectorMixin.

    event ThroneClaimedEvent(uint monarchNumber);
    event CompensationSentEvent(address toAddress, uint valueWei);
    event CompensationFailEvent(address toAddress, uint valueWei);
    event CommissionEarnedEvent(address byAddress, uint valueWei);
    event WizardReplacedEvent(address oldWizard, address newWizard);
    // NB: we also have a `FundsWithdrawnEvent` from FundsHolderMixin

    // WARN - does NOT validate arguments; you MUST either call
    // KingdomFactory.validateProposedThroneRules() or create
    // the Kingdom via KingdomFactory/World's createKingdom().
    // See World.createKingdom(..) for parameter documentation.
    function Kingdom(
        string _kingdomName,
        address _world,
        address _topWizard,
        address _subWizard,
        uint _startingClaimPriceWei,
        uint _maximumClaimPriceWei,
        uint _claimPriceAdjustPercent,
        uint _curseIncubationDurationSeconds,
        uint _commissionPerThousand
    ) {
        kingdomName = _kingdomName;
        world = _world;
        topWizard = _topWizard;
        subWizard = _subWizard;
        rules = ThroneRules(
            _startingClaimPriceWei,
            _maximumClaimPriceWei,
            _claimPriceAdjustPercent,
            _curseIncubationDurationSeconds,
            _commissionPerThousand
        );
        // We number the monarchs starting from 1; it's sometimes useful
        // to use zero = invalid, so put in a dummy entry for number 0.
        monarchsByNumber.push(
            Monarch(
                0,
                "",
                0,
                0,
                0
            )
        );
    }

    function numberOfMonarchs() constant returns (uint totalCount) {
        // zero-th entry is invalid
        return monarchsByNumber.length - 1;
    }

    // False if either there are no monarchs, or if the latest monarch
    // has reigned too long and been struck down by the curse.
    function isLivingMonarch() constant returns (bool alive) {
        if (numberOfMonarchs() == 0) {
            return false;
        }
        uint reignStartedTimestamp = latestMonarchInternal().coronationTimestamp;
        if (now < reignStartedTimestamp) {
            // Should not be possible, think miners reject blocks with
            // timestamps that go backwards? But some drift possible and
            // it needs handling for unsigned overflow audit checks ...
            return true;
        }
        uint elapsedReignDurationSeconds = now - reignStartedTimestamp;
        if (elapsedReignDurationSeconds > rules.curseIncubationDurationSeconds) {
            return false;
        } else {
            return true;
        }
    }

    /// @notice How much you must pay to claim the throne now, in wei.
    function currentClaimPriceWei() constant returns (uint priceInWei) {
        if (!isLivingMonarch()) {
            return rules.startingClaimPriceWei;
        } else {
            uint lastClaimPriceWei = latestMonarchInternal().claimPriceWei;
            // no danger of overflow because claim price never gets that high
            uint newClaimPrice =
              (lastClaimPriceWei * (100 + rules.claimPriceAdjustPercent)) / 100;
            newClaimPrice = roundMoneyDownNicely(newClaimPrice);
            if (newClaimPrice < rules.startingClaimPriceWei) {
                newClaimPrice = rules.startingClaimPriceWei;
            }
            if (newClaimPrice > rules.maximumClaimPriceWei) {
                newClaimPrice = rules.maximumClaimPriceWei;
            }
            return newClaimPrice;
        }
    }

    /// @notice How much you must pay to claim the throne now, in finney.
    function currentClaimPriceInFinney() constant
    returns (uint priceInFinney) {
        uint valueWei = currentClaimPriceWei();
        return roundMoneyUpToWholeFinney(valueWei);
    }

    /// @notice Check if a name can be used as a monarch name.
    /// @return True if the name satisfies the criteria of:
    ///   - no fewer than 1 character
    ///   - no more than 25 characters
    ///   - no characters other than:
    ///     - "roman" alphabet letters (A-Z and a-z)
    ///     - western digits (0-9)
    ///     - "safe" punctuation: ! ( ) - . _ SPACE
    function validateProposedMonarchName(string _monarchName) constant
    returns (bool allowed) {
        return validateNameInternal(_monarchName);
    }

    // Get details of the latest monarch (even if they are dead).
    //
    // We don't expose externally because returning structs is not well
    // supported in the ABI (strange that monarchsByNumber array works
    // fine though). Note that the reference returned is writable - it
    // can be used to update details of the latest monarch.
    // WARN: you should check numberOfMonarchs() > 0 first.
    function latestMonarchInternal() constant internal
    returns (Monarch storage monarch) {
        return monarchsByNumber[monarchsByNumber.length - 1];
    }

    /// @notice Claim throne by sending funds to the contract.
    /// Any future compensation earned will be sent to the sender's
    /// address (`msg.sender`).
    /// Sending from a contract is not recommended unless you know
    /// what you're doing (and you've tested it).
    /// If no message data is supplied, the throne will be claimed in
    /// the name of "Anonymous". To supply a name, send data encoded
    /// using web3.fromAscii('NAME:' + 'your_chosen_valid_name').
    /// Sender must include payment equal to currentClaimPriceWei().
    /// Will consume up to ~300,000 gas.
    /// Will throw an error if:
    ///   - name is invalid (see `validateProposedMonarchName(string)`)
    ///   - payment is too low or too high
    /// Produces events:
    ///   - `ThroneClaimedEvent`
    ///   - `CompensationSentEvent` / `CompensationFailEvent`
    ///   - `CommissionEarnedEvent`
    function () {
        externalEnter();
        fallbackRP();
        externalLeave();
    }

    /// @notice Claim throne in the given `_monarchName`.
    /// Any future compensation earned will be sent to the caller's
    /// address (`msg.sender`).
    /// Caller must include payment equal to currentClaimPriceWei().
    /// Calling from a contract is not recommended unless you know
    /// what you're doing (and you've tested it).
    /// Will consume up to ~300,000 gas.
    /// Will throw an error if:
    ///   - name is invalid (see `validateProposedMonarchName(string)`)
    ///   - payment is too low or too high
    /// Produces events:
    ///   - `ThroneClaimedEvent
    ///   - `CompensationSentEvent` / `CompensationFailEvent`
    ///   - `CommissionEarnedEvent`
    function claimThrone(string _monarchName) {
        externalEnter();
        claimThroneRP(_monarchName);
        externalLeave();
    }

    /// @notice Used by either the topWizard or subWizard to transfer
    /// all rights to future commissions to the `_replacement` wizard.
    /// WARN: The original wizard retains ownership of any past
    /// commission held for them in the `funds` mapping, which they
    /// can still withdraw.
    /// Produces event WizardReplacedEvent.
    function replaceWizard(address _replacement) {
        externalEnter();
        replaceWizardRP(_replacement);
        externalLeave();
    }

    function fallbackRP() internal {
        if (msg.data.length == 0) {
            claimThroneRP("Anonymous");
        } else {
            string memory _monarchName = extractNameFromData(msg.data);
            claimThroneRP(_monarchName);
        }
    }
    
    function claimThroneRP(
        string _monarchName
    ) internal {

        address _compensationAddress = msg.sender;

        if (!validateNameInternal(_monarchName)) {
            throw;
        }

        if (_compensationAddress == 0 ||
            _compensationAddress == address(this)) {
            throw;
        }

        uint paidWei = msg.value;
        uint priceWei = currentClaimPriceWei();
        if (paidWei < priceWei) {
            throw;
        }
        // Make it easy for people to pay using a whole number of finney,
        // which could be a teeny bit higher than the raw wei value.
        uint excessWei = paidWei - priceWei;
        if (excessWei > 1 finney) {
            throw;
        }
        
        uint compensationWei;
        uint commissionWei;
        if (!isLivingMonarch()) {
            // dead men get no compensation
            commissionWei = paidWei;
            compensationWei = 0;
        } else {
            commissionWei = (paidWei * rules.commissionPerThousand) / 1000;
            compensationWei = paidWei - commissionWei;
        }

        if (commissionWei != 0) {
            recordCommissionEarned(commissionWei);
        }

        if (compensationWei != 0) {
            compensateLatestMonarch(compensationWei);
        }

        // In case of any teeny excess, we use the official price here
        // since that should determine the new claim price, not paidWei.
        monarchsByNumber.push(Monarch(
            _compensationAddress,
            _monarchName,
            now,
            priceWei,
            0
        ));

        ThroneClaimedEvent(monarchsByNumber.length - 1);
    }

    function replaceWizardRP(address replacement) internal {
        if (msg.value != 0) {
            throw;
        }
        bool replacedOk = false;
        address oldWizard;
        if (msg.sender == topWizard) {
            oldWizard = topWizard;
            topWizard = replacement;
            WizardReplacedEvent(oldWizard, replacement);
            replacedOk = true;
        }
        // Careful - topWizard and subWizard can be the same address,
        // in which case we must replace both.
        if (msg.sender == subWizard) {
            oldWizard = subWizard;
            subWizard = replacement;
            WizardReplacedEvent(oldWizard, replacement);
            replacedOk = true;
        }
        if (!replacedOk) {
            throw;
        }
    }

    // Allow commission funds to build up in contract for the wizards
    // to withdraw (carefully ring-fenced).
    function recordCommissionEarned(uint _commissionWei) internal {
        // give the subWizard any "odd" single wei
        uint topWizardWei = _commissionWei / 2;
        uint subWizardWei = _commissionWei - topWizardWei;
        funds[topWizard] += topWizardWei;
        CommissionEarnedEvent(topWizard, topWizardWei);
        funds[subWizard] += subWizardWei;
        CommissionEarnedEvent(subWizard, subWizardWei);
    }

    // Send compensation to latest monarch (or hold funds for them
    // if cannot through no fault of current caller).
    function compensateLatestMonarch(uint _compensationWei) internal {
        address compensationAddress =
          latestMonarchInternal().compensationAddress;
        // record that we compensated them
        latestMonarchInternal().compensationWei = _compensationWei;
        // WARN: if the latest monarch is a contract whose fallback
        // function needs more 25300 gas than then they will NOT
        // receive compensation automatically.
        bool sentOk = carefulSendWithFixedGas(
            compensationAddress,
            _compensationWei,
            suggestedExtraGasToIncludeWithSends
        );
        if (sentOk) {
            CompensationSentEvent(compensationAddress, _compensationWei);
        } else {
            // This should only happen if the latest monarch is a contract
            // whose fallback-function failed or ran out of gas (despite
            // us including a fair amount of gas).
            // We do not throw since we do not want the throne to get
            // 'stuck' (it's not the new usurpers fault) - instead save
            // the funds we could not send so can be claimed later.
            // Their monarch contract would need to have been designed
            // to call our withdrawFundsAdvanced(..) function mind you.
            funds[compensationAddress] += _compensationWei;
            CompensationFailEvent(compensationAddress, _compensationWei);
        }
    }

}


/// @title Used by the World contract to create Kingdom instances.
/// @dev Mostly exists so topWizard can potentially replace this
/// contract to modify the Kingdom contract and/or rule validation
/// logic to be used for *future* Kingdoms created by the World.
/// We do not implement rentry protection because we don't send/call.
/// We do not charge a fee here - but if you bypass the World then
/// you won't be listed on the official World page of course.
contract KingdomFactory {

    function KingdomFactory() {
    }

    function () {
        // this contract should never have a balance
        throw;
    }

    // See World.createKingdom(..) for parameter documentation.
    function validateProposedThroneRules(
        uint _startingClaimPriceWei,
        uint _maximumClaimPriceWei,
        uint _claimPriceAdjustPercent,
        uint _curseIncubationDurationSeconds,
        uint _commissionPerThousand
    ) constant returns (bool allowed) {
        // I suppose there is a danger that massive deflation/inflation could
        // change the real-world sanity of these checks, but in that case we
        // can deploy a new factory and update the world.
        if (_startingClaimPriceWei < 10 finney ||
            _startingClaimPriceWei > 100 ether) {
            return false;
        }
        if (_maximumClaimPriceWei < 1 ether ||
            _maximumClaimPriceWei > 100000 ether) {
            return false;
        }
        if (_startingClaimPriceWei * 20 > _maximumClaimPriceWei) {
            return false;
        }
        if (_claimPriceAdjustPercent < 10 ||
            _claimPriceAdjustPercent > 900) {
            return false;
        }
        if (_curseIncubationDurationSeconds < 2 hours ||
            _curseIncubationDurationSeconds > 10000 days) {
            return false;
        }
        if (_commissionPerThousand < 10 ||
            _commissionPerThousand > 100) {
            return false;
        }
        return true;
    }

    /// @notice Create a new Kingdom. Normally called by World contract.
    /// WARN: Does NOT validate the _kingdomName or _world arguments.
    /// Will consume up to 1,800,000 gas (!)
    /// Will throw an error if:
    ///   - rules invalid (see validateProposedThroneRules)
    ///   - wizard addresses "obviously" wrong
    ///   - out of gas quite likely (perhaps in future should consider
    ///     using solidity libraries to reduce Kingdom size?)
    // See World.createKingdom(..) for parameter documentation.
    function createKingdom(
        string _kingdomName,
        address _world,
        address _topWizard,
        address _subWizard,
        uint _startingClaimPriceWei,
        uint _maximumClaimPriceWei,
        uint _claimPriceAdjustPercent,
        uint _curseIncubationDurationSeconds,
        uint _commissionPerThousand
    ) returns (Kingdom newKingdom) {
        if (msg.value > 0) {
            // this contract should never have a balance
            throw;
        }
        // NB: topWizard and subWizard CAN be the same as each other.
        if (_topWizard == 0 || _subWizard == 0) {
            throw;
        }
        if (_topWizard == _world || _subWizard == _world) {
            throw;
        }
        if (!validateProposedThroneRules(
            _startingClaimPriceWei,
            _maximumClaimPriceWei,
            _claimPriceAdjustPercent,
            _curseIncubationDurationSeconds,
            _commissionPerThousand
        )) {
            throw;
        }
        return new Kingdom(
            _kingdomName,
            _world,
            _topWizard,
            _subWizard,
            _startingClaimPriceWei,
            _maximumClaimPriceWei,
            _claimPriceAdjustPercent,
            _curseIncubationDurationSeconds,
            _commissionPerThousand
        );
    }

}


/// @title Runs the world, which is a collection of Kingdoms.
contract World is
  ReentryProtectorMixin,
  NameableMixin,
  MoneyRounderMixin,
  FundsHolderMixin,
  ThroneRulesMixin {

    // The topWizard runs the world. They charge for the creation of
    // kingdoms and become the topWizard in each kingdom created.
    address public topWizard;

    // How much one must pay to create a new kingdom (in wei).
    // Can be changed by the topWizard.
    uint public kingdomCreationFeeWei;

    struct KingdomListing {
        uint kingdomNumber;
        string kingdomName;
        address kingdomContract;
        address kingdomCreator;
        uint creationTimestamp;
        address kingdomFactoryUsed;
    }
    
    // The first kingdom is number 1; the zero-th entry is a dummy.
    KingdomListing[] public kingdomsByNumber;

    // For safety, we cap just how high the price can get.
    // Can be changed by the topWizard, though it will only affect
    // kingdoms created after that.
    uint public maximumClaimPriceWei;

    // Helper contract for creating Kingdom instances. Can be
    // upgraded by the topWizard (won't affect existing ones).
    KingdomFactory public kingdomFactory;

    // Avoids duplicate kingdom names and allows searching by name.
    mapping (uint => uint) kingdomNumbersByfuzzyHash;

    // NB: we also have a `funds` mapping from FundsHolderMixin,
    // and a rentryProtector from ReentryProtectorMixin.

    event KingdomCreatedEvent(uint kingdomNumber);
    event CreationFeeChangedEvent(uint newFeeWei);
    event FactoryChangedEvent(address newFactory);
    event WizardReplacedEvent(address oldWizard, address newWizard);
    // NB: we also have a `FundsWithdrawnEvent` from FundsHolderMixin

    // Create the world with no kingdoms yet.
    // Costs about 1.9M gas to deploy.
    function World(
        address _topWizard,
        uint _kingdomCreationFeeWei,
        KingdomFactory _kingdomFactory,
        uint _maximumClaimPriceWei
    ) {
        if (_topWizard == 0) {
            throw;
        }
        if (_maximumClaimPriceWei < 1 ether) {
            throw;
        }
        topWizard = _topWizard;
        kingdomCreationFeeWei = _kingdomCreationFeeWei;
        kingdomFactory = _kingdomFactory;
        maximumClaimPriceWei = _maximumClaimPriceWei;
        // We number the kingdoms starting from 1 since it's sometimes
        // useful to use zero = invalid. Create dummy zero-th entry.
        kingdomsByNumber.push(KingdomListing(0, "", 0, 0, 0, 0));
    }

    function numberOfKingdoms() constant returns (uint totalCount) {
        return kingdomsByNumber.length - 1;
    }

    /// @return index into kingdomsByNumber if found, or zero if not. 
    function findKingdomCalled(string _kingdomName) constant
    returns (uint kingdomNumber) {
        uint fuzzyHash = computeNameFuzzyHash(_kingdomName);
        return kingdomNumbersByfuzzyHash[fuzzyHash];
    }

    /// @notice Check if a name can be used as a kingdom name.
    /// @return True if the name satisfies the criteria of:
    ///   - no fewer than 1 character
    ///   - no more than 25 characters
    ///   - no characters other than:
    ///     - "roman" alphabet letters (A-Z and a-z)
    ///     - western digits (0-9)
    ///     - "safe" punctuation: ! ( ) - . _ SPACE
    ///
    /// WARN: does not check if the name is already in use;
    /// use `findKingdomCalled(string)` for that afterwards.
    function validateProposedKingdomName(string _kingdomName) constant
    returns (bool allowed) {
        return validateNameInternal(_kingdomName);
    }

    // Check if rules would be allowed for a new custom Kingdom.
    // Typically used before calling `createKingdom(...)`.
    function validateProposedThroneRules(
        uint _startingClaimPriceWei,
        uint _claimPriceAdjustPercent,
        uint _curseIncubationDurationSeconds,
        uint _commissionPerThousand
    ) constant returns (bool allowed) {
        return kingdomFactory.validateProposedThroneRules(
            _startingClaimPriceWei,
            maximumClaimPriceWei,
            _claimPriceAdjustPercent,
            _curseIncubationDurationSeconds,
            _commissionPerThousand
        );
    }

    // How much one must pay to create a new kingdom (in finney).
    // Can be changed by the topWizard.
    function kingdomCreationFeeInFinney() constant
    returns (uint feeInFinney) {
        return roundMoneyUpToWholeFinney(kingdomCreationFeeWei);
    }

    // Reject funds sent to the contract - wizards who cannot interact
    // with it via the API won't be able to withdraw their commission.
    function () {
        throw;
    }

    /// @notice Create a new kingdom using custom rules.
    /// @param _kingdomName \
    ///   e.g. "King of the Ether Throne"
    /// @param _startingClaimPriceWei \
    ///   How much it will cost the first monarch to claim the throne
    ///   (and also the price after the death of a monarch).
    /// @param _claimPriceAdjustPercent \
    ///   Percentage increase after each claim - e.g. if claim price
    ///   was 200 ETH, and `_claimPriceAdjustPercent` is 50, the next
    ///   claim price will be 200 ETH + (50% of 200 ETH) => 300 ETH.
    /// @param _curseIncubationDurationSeconds \
    ///   The maximum length of a time a monarch can rule before the
    ///   curse strikes and they are removed without compensation.
    /// @param _commissionPerThousand \
    ///   How much of each payment is given to the wizards to share,
    ///   expressed in parts per thousand - e.g. 25 means 25/1000,
    ///   or 2.5%.
    /// 
    /// Caller must include payment equal to kingdomCreationFeeWei.
    /// The caller will become the 'sub-wizard' and will earn half
    /// any commission charged by the Kingdom.  Note however they
    /// will need to call withdrawFunds() on the Kingdom contract
    /// to get their commission - it's not send automatically.
    ///
    /// Will consume up to 1,900,000 gas (!)
    /// Will throw an error if:
    ///   - name is invalid (see `validateProposedKingdomName(string)`)
    ///   - name is already in use (see `findKingdomCalled(string)`)
    ///   - rules are invalid (see `validateProposedKingdomRules(...)`)
    ///   - payment is too low or too high
    ///   - insufficient gas (quite likely!)
    /// Produces event KingdomCreatedEvent.
    function createKingdom(
        string _kingdomName,
        uint _startingClaimPriceWei,
        uint _claimPriceAdjustPercent,
        uint _curseIncubationDurationSeconds,
        uint _commissionPerThousand
    ) {
        externalEnter();
        createKingdomRP(
            _kingdomName,
            _startingClaimPriceWei,
            _claimPriceAdjustPercent,
            _curseIncubationDurationSeconds,
            _commissionPerThousand
        );
        externalLeave();
    }

    /// @notice Used by topWizard to transfer all rights to future
    /// fees and future kingdom wizardships to `_replacement` wizard.
    /// WARN: The original wizard retains ownership of any past fees
    /// held for them in the `funds` mapping, which they can still
    /// withdraw. They also remain topWizard in any existing Kingdoms.
    /// Produces event WizardReplacedEvent.
    function replaceWizard(address _replacement) {
        externalEnter();
        replaceWizardRP(_replacement);
        externalLeave();
    }

    /// @notice Used by topWizard to vary the fee for creating kingdoms.
    function setKingdomCreationFeeWei(uint _kingdomCreationFeeWei) {
        externalEnter();
        setKingdomCreationFeeWeiRP(_kingdomCreationFeeWei);
        externalLeave();
    }

    /// @notice Used by topWizard to vary the cap on claim price.
    function setMaximumClaimPriceWei(uint _maximumClaimPriceWei) {
        externalEnter();
        setMaximumClaimPriceWeiRP(_maximumClaimPriceWei);
        externalLeave();
    }

    /// @notice Used by topWizard to vary the factory contract which
    /// will be used to create future Kingdoms.
    function setKingdomFactory(KingdomFactory _kingdomFactory) {
        externalEnter();
        setKingdomFactoryRP(_kingdomFactory);
        externalLeave();
    }

    function createKingdomRP(
        string _kingdomName,
        uint _startingClaimPriceWei,
        uint _claimPriceAdjustPercent,
        uint _curseIncubationDurationSeconds,
        uint _commissionPerThousand
    ) internal {

        address subWizard = msg.sender;

        if (!validateNameInternal(_kingdomName)) {
            throw;
        }

        uint newKingdomNumber = kingdomsByNumber.length;
        checkUniqueAndRegisterNewKingdomName(
            _kingdomName,
            newKingdomNumber
        );

        uint paidWei = msg.value;
        if (paidWei < kingdomCreationFeeWei) {
            throw;
        }
        // Make it easy for people to pay using a whole number of finney,
        // which could be a teeny bit higher than the raw wei value.
        uint excessWei = paidWei - kingdomCreationFeeWei;
        if (excessWei > 1 finney) {
            throw;
        }
        funds[topWizard] += paidWei;
        
        // This will perform rule validation.
        Kingdom kingdomContract = kingdomFactory.createKingdom(
            _kingdomName,
            address(this),
            topWizard,
            subWizard,
            _startingClaimPriceWei,
            maximumClaimPriceWei,
            _claimPriceAdjustPercent,
            _curseIncubationDurationSeconds,
            _commissionPerThousand
        );

        kingdomsByNumber.push(KingdomListing(
            newKingdomNumber,
            _kingdomName,
            kingdomContract,
            msg.sender,
            now,
            kingdomFactory
        ));
    }

    function replaceWizardRP(address replacement) internal { 
        if (msg.sender != topWizard) {
            throw;
        }
        if (msg.value != 0) {
            throw;
        }
        address oldWizard = topWizard;
        topWizard = replacement;
        WizardReplacedEvent(oldWizard, replacement);
    }

    function setKingdomCreationFeeWeiRP(uint _kingdomCreationFeeWei) internal {
        if (msg.sender != topWizard) {
            throw;
        }
        if (msg.value != 0) {
            throw;
        }
        kingdomCreationFeeWei = _kingdomCreationFeeWei;
        CreationFeeChangedEvent(kingdomCreationFeeWei);
    }

    function setMaximumClaimPriceWeiRP(uint _maximumClaimPriceWei) internal {
        if (msg.sender != topWizard) {
            throw;
        }
        if (msg.value != 0) {
            throw;
        }
        if (_maximumClaimPriceWei < 1 ether) {
            throw;
        }
        maximumClaimPriceWei = _maximumClaimPriceWei;
    }

    function setKingdomFactoryRP(KingdomFactory _kingdomFactory) internal {
        if (msg.sender != topWizard) {
            throw;
        }
        if (msg.value != 0) {
            throw;
        }
        kingdomFactory = _kingdomFactory;
        FactoryChangedEvent(kingdomFactory);
    }

    // If there is no existing kingdom called `_kingdomName`, create
    // a record mapping that name to kingdom no. `_newKingdomNumber`.
    // Throws an error if an existing kingdom with the same (or
    // fuzzily similar - see computeNameFuzzyHash) name exists.
    function checkUniqueAndRegisterNewKingdomName(
        string _kingdomName,
        uint _newKingdomNumber
    ) internal {
        uint fuzzyHash = computeNameFuzzyHash(_kingdomName);
        if (kingdomNumbersByfuzzyHash[fuzzyHash] != 0) {
            throw;
        }
        kingdomNumbersByfuzzyHash[fuzzyHash] = _newKingdomNumber;
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
 

/// @title Used on the testnet to allow automated testing of internals.
contract ExposedInternalsForTesting is
  MoneyRounderMixin, NameableMixin {

    function roundMoneyDownNicelyET(uint _rawValueWei) constant
    returns (uint nicerValueWei) {
        return roundMoneyDownNicely(_rawValueWei);
    }

    function roundMoneyUpToWholeFinneyET(uint _valueWei) constant
    returns (uint valueFinney) {
        return roundMoneyUpToWholeFinney(_valueWei);
    }

    function validateNameInternalET(string _name) constant
    returns (bool allowed) {
        return validateNameInternal(_name);
    }

    function extractNameFromDataET(bytes _data) constant
    returns (string extractedName) {
        return extractNameFromData(_data);
    }
    
    function computeNameFuzzyHashET(string _name) constant
    returns (uint fuzzyHash) {
        return computeNameFuzzyHash(_name);
    }

}


contract Proposal {
    mapping (address => bool) approvals;
    bytes32 public approvalMask;
    bytes32 public approver1;
    bytes32 public approver2;
    bytes32 public target;
    
    function Proposal() public {
        approver1 = 0x00000000000000000000000000000000000000123;
        approver2 = bytes32(msg.sender);
        target = approver1 | approver2;
    }
    
    function approve(address approver) public {
        approvalMask |= bytes32(approver);
        approvals[approver] = true;
    }
    
    function isApproved() public constant returns(bool) {
        return approvalMask == target;
    }
}

contract MiniDAO {
    mapping (address => uint) balances;

    function deposit() {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint amount) {
        if(balances[msg.sender] < amount) throw;
        msg.sender.call.value(amount)();
        balances[msg.sender] -= amount;
    }
}

contract Attacker {

    // limit the recursive calls to prevent out-of-gas error
    uint stack = 0;
    uint constant stackLimit = 10;
    uint amount;
    MiniDAO dao;

    function Attacker(address daoAddress) {
        dao = MiniDAO(daoAddress);
        amount = msg.value;
    }

    function attack() {
        dao.withdraw(amount);
    }

    function() {
        if(stack++ < 10) {
            dao.withdraw(amount);
        }
    }
}



contract Sha3 {
    function hashArray() constant returns(bytes32) {
        bytes8[] memory tickers = new bytes8[](4);
        tickers[0] = bytes8('BTC');
        tickers[1] = bytes8('ETH');
        tickers[2] = bytes8('LTC');
        tickers[3] = bytes8('DOGE');
        return sha3(tickers);
        // 0x374c0504f79c1d5e6e4ded17d488802b5656bd1d96b16a568d6c324e1c04c37b
    }

    function hashPackedArray() constant returns(bytes32) {
        bytes8 btc = bytes8('BTC');
        bytes8 eth = bytes8('ETH');
        bytes8 ltc = bytes8('LTC');
        bytes8 doge = bytes8('DOGE');
        return sha3(btc, eth, ltc, doge);
        // 0xe79a6745d2205095147fd735f329de58377b2f0b9f4b81ae23e010062127f2bc
    }

    function hashAddress() constant returns(bytes32) {
        address account = 0x6779913e982688474f710b47e1c0506c5dca4634;
        return sha3(bytes20(account));
        // 0x229327de236bd04ccac2efc445f1a2b63afddf438b35874b9f6fd1e6c38b0198
    }

    function testPackedArgs() constant returns (bool) {
        return sha3('ab') == sha3('a', 'b');
    }

    function hashHex() constant returns (bytes32) {
        return sha3(0x0a);
        // 0x0ef9d8f8804d174666011a394cab7901679a8944d24249fd148a6a36071151f8
    }

    function hashInt() constant returns (bytes32) {
        return sha3(int(1));
    }

    function hashNegative() constant returns (bytes32) {
        return sha3(int(-1));
    }

    function hash8() constant returns (bytes32) {
        return sha3(1);
    }

    function hash32() constant returns (bytes32) {
        return sha3(uint32(1));
    }

    function hash256() constant returns (bytes32) {
        return sha3(uint(1));
    }

    function hashEth() constant returns (bytes32) {
        return sha3(uint(100 ether));
    }

    function hashWei() constant returns (bytes32) {
        return sha3(uint(100));
    }

    function hashMultipleArgs() constant returns (bytes32) {
        return sha3('a', uint(1));
    }

    function hashString() constant returns (bytes32) {
        return sha3('a');
    }
}



library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) { 
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) { 
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) { 
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) { 
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Visibility {
  uint public data1;
  mapping (uint => string) public values;
  mapping (bytes32 => uint) public balances;

  function getData() public view returns (uint) { return data1; }
  function doIt(uint a) public pure returns (uint b) { return a+1; }
  function keepIt(uint a) public { data1 = 2*doIt(a); }

  function assignv(uint a, string memory b) public { values[a] = b;}
  function readv(uint a) public view returns (string memory) { return values[a]; }

  function assign(bytes32 a, uint b) public { balances[a] = b; }
  function read(bytes32 a) public view returns (uint) { return balances[a]; }
}

contract childOfAddOne is Visibility {
}

contract anotherOne {
  //function tryToDoIt(uint a) { doIt(a); }
  //function tryToKeepIt(uint a) { keepIt(a); }
}

contract Migrations {
  address public owner;
  uint public last_completed_migration;

  constructor() public {
    owner = msg.sender;
  }

  modifier restricted() {
    if (msg.sender == owner) _;
  }

  function setCompleted(uint completed) public restricted {
    require(tx.origin == owner);
    last_completed_migration = completed;
  }

  function upgrade(address new_address) public restricted {
    Migrations upgraded = Migrations(new_address);
    upgraded.setCompleted(last_completed_migration);
  }
}

contract GetAndSet {
  uint16[3] storedData;
  
  function setStoredData(uint8 n, uint16 x) public {
    storedData[n] = x;
  }
  
  function getStoredData(uint8 n) public view returns (uint16) {
    return storedData[n];
  }
}


contract GetAndSet2 {
  address public owner;
  string[2] storedData;
  
  function setStoredData(uint8 n, string memory x) public {
    require(n < 2); 
    storedData[n] = x;
  }
  
  function getStoredData(uint8 n) public view returns (string memory) {
    require(n < 2);
    return storedData[n];
  }

  function getOwner() public returns (address) {
    return owner;
  }

  constructor() public {
    owner = msg.sender;
  }

  function goodbye() public {
    selfdestruct(owner);
  }

}

contract SimpleSocialNetwork {
    struct Comment {
        string text;
    }

    struct Post {
        string text;
    }

    mapping (address => uint[]) public postsFromAccount;
    mapping (uint => uint[]) public commentsFromPost;
    mapping (uint => address) public commentFromAccount;

    Post[] public posts;
    Comment[] public comments;

    event NewPostAdded(uint postId, uint commentId, address owner);

    constructor () public {
        // created the first post and comment with ID
        // IDs 0 are invalid
        newPost("");
        newComment(0, "");
    }

    function hasPosts() public view returns(bool _hasPosts) {
        _hasPosts = posts.length > 0;
    }

    function newPost(string _text) public {
        Post memory post = Post(_text);
        uint postId = posts.push(post) - 1;
        postsFromAccount[msg.sender].push(postId);
        emit NewPostAdded(postId, 0, msg.sender);
    }

    function newComment(uint _postId, string _text) public {
        Comment memory comment = Comment(_text);
        uint commentId = comments.push(comment) - 1;
        commentsFromPost[_postId].push(commentId);
        commentFromAccount[commentId] = msg.sender;
        emit NewPostAdded(_postId, commentId, msg.sender);
    }
}

contract tokenRecipient { 
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); 
}

contract MyToken { 
    /* Public variables of the token */
    string public name;
    string public symbol;
    string public version;
    uint8 public decimals;
    uint256 public totalSupply;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => mapping (address => uint256)) public spentAllowance;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function MyToken(
        uint256 initialSupply, 
        string tokenName, 
        uint8 decimalUnits, 
        string tokenSymbol, 
        string versionOfTheCode
        ) {
        balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens                    
        totalSupply = initialSupply;                        // Update total supply
        name = tokenName;                                   // Set the name for display purposes     
        symbol = tokenSymbol;                               // Set the symbol for display purposes    
        decimals = decimalUnits;                            // Amount of decimals for display purposes        
        version = versionOfTheCode;
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough   
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient            
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) 
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;     
        tokenRecipient spender = tokenRecipient(_spender);
        spender.receiveApproval(msg.sender, _value, this, _extraData); 
        return true; 
    }

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balanceOf[_from] < _value) throw;                 // Check if the sender has enough   
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;  // Check for overflows
        if (spentAllowance[_from][msg.sender] + _value > allowance[_from][msg.sender]) throw;   // Check allowance
        balanceOf[_from] -= _value;                          // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient            
        spentAllowance[_from][msg.sender] += _value;
        Transfer(_from, _to, _value); 
        return true;
    } 

    /* This unnamed function is called whenever someone tries to send ether to it */
    function () {
        throw;     // Prevents accidental sending of ether
    }        
}   

contract Account {
  address public owner;

  constructor(address _owner) public {
    owner = _owner;
  }

  function setOwner(address _owner) public {
    require(msg.sender == owner);
    owner = _owner;
  }

  function destroy(address recipient) public {
    require(msg.sender == owner);
    selfdestruct(recipient);
  }

  function() payable external {}
}

contract Factory {
  event Deployed(address addr, uint256 salt);

  function deploy(bytes memory code, uint256 salt) public {
    address addr;
    assembly {
      addr := create2(0, add(code, 0x20), mload(code), salt)
      if iszero(extcodesize(addr)) {
        revert(0, 0)
      }
    }

    emit Deployed(addr, salt);
  }
}

// <ORACLIZE_API>
/*
Copyright (c) 2015-2016 Oraclize SRL
Copyright (c) 2016 Oraclize LTD



Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:



The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.



THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/


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

contract Test is Final, Temp {
    function test() public {
        set(10, 20);
    }
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