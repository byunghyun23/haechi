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

contract AFAFAF {
    bool locked = false;

    modifier validAddress(address account) {
        if (account == 0x0) { throw; }
        _;
    }

    modifier greaterThan(uint value, uint limit) {
        if(value <= limit) { throw; }
        _;
    }

    modifier lock() {
        if(locked) {
            locked = true;
            _;
            locked = false;
        }
    }

    function f(address account) validAddress(account) {}
    function g(uint a) greaterThan(a, 10) {}
    function refund() lock {
        msg.sender.send(0);
    }

    uint[] public values;

    function Contract() {
    }

    function find(uint value) returns(uint) {
        uint i = 0;
        while (values[i] != value) {
            i++;
        }
        return i;
    }

    function removeByValue(uint value) {
        uint i = find(value);
        removeByIndex(i);
    }

    function removeByIndex(uint i) {
        while (i<values.length-1) {
            values[i] = values[i+1];
            i++;
        }
        values.length--;
    }

    function getValues() constant returns(uint[]) {
        return values;
    }

    function test() returns(uint[]) {
        values.push(10);
        values.push(20);
        values.push(30);
        values.push(40);
        values.push(50);
        removeByValue(30);
        return getValues();
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


