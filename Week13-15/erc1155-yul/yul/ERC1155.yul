/// @title ERC1155 in pure Yul
/// @author Zigtur
/// @notice You can use this contract as an ERC1155 implementation.
/// @dev BE AWARE THAT IT IS NOT A PRODUCTION IMPLEMENTATION
object "ERC1155" {

    code {
        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return(0, datasize("runtime"))
    }

    object "runtime" {
        code {
            //// Storage setup
            // mapping(uint256 => mapping(address => uint256)) private _balances;
            function balances() -> slot { slot:= 0x0 }
            // mapping(address => mapping(address => bool)) private _operatorApprovals;
            function operatorApprovals() -> slot { slot:= 0x1 }
            

            ////// Dispatcher based on selector
            switch selector()
            //// Non-standard functions
            // mint(address,uint256,uint256)
            case 0x156e29f6 {
                mint(decodeAsAddress(0), decodeAsUint(1), decodeAsUint(2))
                returnTrue()
            }
            // mint(address,uint256,uint256,bytes)
            case 0x731133e9 {
                // ignore bytes sent
                mint(decodeAsAddress(0), decodeAsUint(1), decodeAsUint(2))
                returnTrue()
            }

            //// ERC-1155 standard: Write functions
            // safeTransferFrom(address,address,uint256,uint256,bytes)
            case 0xf242432a {
                // ignore bytes sent
                safeTransferFrom(decodeAsAddress(0), decodeAsAddress(1), decodeAsUint(2), decodeAsUint(3))
                returnTrue()
            }
            // safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)
            case 0x2eb2c2d6 {
                // ignore bytes sent
                safeBatchTransferFrom(decodeAsAddress(0), decodeAsAddress(1), decodeAsUint(2), decodeAsUint(3))
                returnTrue()
            }
            // setApprovalForAll(address,bool)
            case 0xa22cb465 {
                setApprovalForAll(decodeAsAddress(0), decodeAsBool(1))
                returnTrue()
            }
            //// ERC-1155 standard: Read functions
            // balanceOf(address,uint256)
            case 0x00fdd58e {
                returnUint(balanceOf(decodeAsAddress(0), decodeAsUint(1)))
            }
            // balanceOfBatch(address[],uint256[])
            case 0x4e1273f4 {
                returnUint(balanceOfBatch(decodeAsUint(0), decodeAsUint(1)))
            }
            // isApprovedForAll(address,address)
            case 0xe985e9c5 {
                returnUint(isApprovedForAll(decodeAsAddress(0), decodeAsAddress(1)))
            }

            // No fallback functions
            default {
                //returnTrue()
                revert(0, 0)
            }

            ///////////////////////////////////////////////////////////////////////////////////////////////////
            ///                                                                                             ///
            ///                              Non standard: Write helper functions                           ///
            ///                                                                                             ///
            ///////////////////////////////////////////////////////////////////////////////////////////////////

            /// @notice A function to mint tokens
            /// @dev Mints `amount` tokens of token type `id` to `to`.
            /// @param to Address to which token will be minted
            /// @param id Token to mint 
            /// @param value Amount of token to mint            
            function mint(to, id, amount) {
                let slot := calculateDoubleMapping(balances(), to, id)
                sstore(slot, amount)
                emitTransferSingle(caller(), 0, to, id, amount)
            }


            ///////////////////////////////////////////////////////////////////////////////////////////////////
            ///                                                                                             ///
            ///                               ERC-1155 standard: Write functions                            ///
            ///                                                                                             ///
            ///////////////////////////////////////////////////////////////////////////////////////////////////

            /// @notice A function to transfer tokens safely
            /// @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
            /// @param from Address from which token will be transfered
            /// @param to Address to which token will be transfered
            /// @param id Token to transfer 
            /// @param value Amount of token to transfer
            function safeBatchTransferFrom(from, to, id, value) {
                //// check if caller can transfer
                // require(from == msg.sender || isApprovedForAll(from, msg.sender))
                // check caller == from before, or isApprovedForAll will revert
                if iszero(eq(from, caller())) {
                    if iszero(isApprovedForAll(from, caller())) {
                        mstore(0x0, 0x455243313135355F4F50455241544F525F4E4F545F415554484F52495A454400)
                        revert(0x0, 31)
                    }
                }

                // Check that `to` != address(0)
                if eq(to, 0x0) {
                    mstore(0x0, 0x455243313135355F5452414E534645525F544F5F5A45524F5F41444452455353)
                    revert(0x0, 32)
                }

                _transferFrom(from, to, id, value)

                emitTransferSingle(caller(), from, to, id, value)
            }

            /// @notice A function to transfer tokens safely
            /// @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
            /// @param from Address from which token will be transfered
            /// @param to Address to which token will be transfered
            /// @param id Token to transfer 
            /// @param value Amount of token to transfer
            function safeTransferFrom(from, to, id, value) {
                //// check if caller can transfer
                // require(from == msg.sender || isApprovedForAll(from, msg.sender))
                // check caller == from before, or isApprovedForAll will revert
                if iszero(eq(from, caller())) {
                    if iszero(isApprovedForAll(from, caller())) {
                        mstore(0x0, 0x455243313135355F4F50455241544F525F4E4F545F415554484F52495A454400)
                        revert(0x0, 31)
                    }
                }

                // Check that `to` != address(0)
                if eq(to, 0x0) {
                    mstore(0x0, 0x455243313135355F5452414E534645525F544F5F5A45524F5F41444452455353)
                    revert(0x0, 32)
                }

                _transferFrom(from, to, id, value)

                emitTransferSingle(caller(), from, to, id, value)
            }


            /// @dev Internal use functions - transfer `amount` tokens of token type `id` from `from` to `to`.
            /// @param from Address from which token will be transfered
            /// @param to Address to which token will be transfered
            /// @param id Token to transfer 
            /// @param value Amount of token to transfer
            function _transferFrom(from, to, id, value) {
                // Do not call balanceOf, to calculate slot only once (gas efficiency)
                let fromOffset := calculateDoubleMapping(balances(), from, id)
                let fromBalance := sload(fromOffset)
                // require(!(fromBalance < value))
                if lt(fromBalance, value) {
                    mstore(0x0, 0x455243313135355F494E53554646494349454E545F42414C414E434500000000)
                    revert(0x0, 28)
                }
                
                // token transfer
                sstore(fromOffset, sub(fromBalance, value))
                let toOffset := calculateDoubleMapping(balances(), to, id)
                sstore(toOffset, add(sload(toOffset), value))
            }

            /**
                @notice Enable or disable approval for a third party ("operator") to manage all of the caller's tokens.
                @dev MUST emit the ApprovalForAll event on success.
                @param _operator  Address to add to the set of authorized operators
                @param _approved  True if the operator is approved, false to revoke approval
            */
            function setApprovalForAll(operator, approved) {
                if eq(caller(), operator) {
                    mstore(0x0, 0x455243313135355F4F50455241544F525F49535F4F574E455200000000000000)
                    revert(0x0, 25)
                }
                let slot := calculateDoubleMapping(operatorApprovals(), operator, caller())
                sstore(slot, approved)
                emitApprovalForAll(caller(), operator, approved)
            }


            ///////////////////////////////////////////////////////////////////////////////////////////////////
            ///                                                                                             ///
            ///                               ERC-1155 standard: Read functions                             ///
            ///                                                                                             ///
            ///////////////////////////////////////////////////////////////////////////////////////////////////

            function balanceOf(account, id) -> amount {
                let offset := calculateDoubleMapping(balances(), account, id)
                amount := sload(offset)
            }

            function balanceOfBatch(accountPointer, idPointer) -> amount {
                let accountsNumber,accountsIndex := decodeAsArray(accountPointer)
                let idsNumber,idsIndex := decodeAsArray(idPointer)

                // require(accounts.length == ids.length)
                if iszero(eq(idsNumber, accountsNumber)) {
                    mstore(0x0, 0x455243313135355F4E4F545F53414D455F53495A450000000000000000000000)
                    revert(0x0, 21)
                }

                //// initialize array for return, according to Solidity standard
                // store pointer to array in memory
                mstore(0x40, 0x20)
                // store array size
                mstore(0x60, accountsNumber)
                let balanceIndex := 0x80

                for { let i:= 0 } lt(i, accountsNumber) { i:= add(i, 1)}
                {
                    mstore(balanceIndex, balanceOf(calldataload(accountsIndex), calldataload(idsIndex)))

                    // increment indexes
                    accountsIndex := add(accountsIndex, 0x20)
                    idsIndex := add(idsIndex, 0x20)
                    balanceIndex := add(balanceIndex, 0x20)
                }
                return(0x40, add(0x40, mul(0x20, accountsNumber)))
            }
            
            function isApprovedForAll(account, operator) -> approved {
                if eq(account, operator) {
                    mstore(0x455243313135355F4F50455241544F525F49535F4F574E455200000000000000, 0x0)
                    revert(0x0, 25)
                }
                let slot := calculateDoubleMapping(operatorApprovals(), operator, account)
                approved := sload(slot)
            }

            ///////////////////////////////////////////////////////////////////////////////////////////////////
            ///                                                                                             ///
            ///                                        Helper functions                                     ///
            ///                                                                                             ///
            ///////////////////////////////////////////////////////////////////////////////////////////////////

            function calculateDoubleMapping(mappingSlot, map2, map1) -> slot {
                //// keccak256(concatenate(account, keccak256(concatenate(id, slot))))
                // keccak256(concatenate(id, slot))
                mstore(0x0, map1)
                mstore(0x20, mappingSlot) // mstore storage slot of mapping
                let tmpHash := keccak256(0, 0x40)
                // keccak256(concatenate(account, tmpHash))
                mstore(0x0, map2)
                mstore(0x20, tmpHash)
                slot := keccak256(0x0, 0x40)
            }

            ///////////////////////////////////////////////////////////////////////////////////////////////////
            ///                                                                                             ///
            ///                                  Calldata decoding functions                                ///
            ///                                                                                             ///
            ///////////////////////////////////////////////////////////////////////////////////////////////////


            /// @notice This function is used to get function selector from the calldata
            /// @return The function selector from calldata
            function selector() -> s {
                s := shr(0xe0, calldataload(0))
            }

            /// @notice A function to decode a calldata slot as an address
            /// @param The offset of the address to read in calldata
            /// @return The value decoded as an address
            function decodeAsAddress(offset) -> v {
                v := decodeAsUint(offset)
                if iszero(iszero(and(v, not(0xffffffffffffffffffffffffffffffffffffffff)))) {
                    revert(0, 0)
                }
            }

            /// @notice A function to decode a calldata slot as a uint 
            /// @param The offset of the uint to read in calldata
            /// @return The value decoded as a uint
            function decodeAsUint(offset) -> v {
                let pos := add(4, mul(offset, 0x20))
                if lt(calldatasize(), add(pos, 0x20)) {
                    revert(0, 0)
                }
                v := calldataload(pos)
            }

            /// @notice A function to decode a calldata slot as a boolean 
            /// @param The offset of the bool to read in calldata
            /// @return The value decoded as a boolean
            function decodeAsBool(offset) -> v {
                let pos := add(4, mul(offset, 0x20))
                if lt(calldatasize(), add(pos, 0x20)) {
                    revert(0, 0)
                }
                v := and(0x1, calldataload(pos))
            }

            /// @notice A function to decode a calldata dynamic array
            /// @param The offset at which the array is stored in calldata (must point to the size argument)
            /// @return The size of the array
            /// @return The offset at which first argument is stored
            function decodeAsArray(pointer) -> size,firstSlot {
                size := calldataload(add(4, pointer))
                if lt(calldatasize(), add(pointer, mul(size, 0x20))) {
                    revert(0, 0)
                }
                firstSlot := add(0x24, pointer)
            }



            ///////////////////////////////////////////////////////////////////////////////////////////////////
            ///                                                                                             ///
            ///                                   Return encoding functions                                 ///
            ///                                                                                             ///
            ///////////////////////////////////////////////////////////////////////////////////////////////////
            /// @notice A function to return a uint value
            /// @param The value to return
            function returnUint(v) {
                mstore(0, v)
                return(0, 0x20)
            }

            /// @notice A function to return `true`
            function returnTrue() {
                returnUint(1)
            }


            ///////////////////////////////////////////////////////////////////////////////////////////////////
            ///                                                                                             ///
            ///                                   Events emitting functions                                 ///
            ///                                                                                             ///
            ///////////////////////////////////////////////////////////////////////////////////////////////////

            /// @notice Emit a TransferSingle event
            /// @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
            /// @dev Corresponds to `event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value)`;
            function emitTransferSingle(operator, from, to, id, amount) {
                let signatureHash := 0xc3d58168c5ae7397731d063d5bbf3d657854427343f4c083240f7aacaa2d0f62
                emit2IndexedEvent(signatureHash, from, to, amount)
            }

            /// @notice Emit a ApprovalForAll event
            /// @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to `approved`.
            /// @dev Corresponds to `event ApprovalForAll(address indexed account, address indexed operator, bool approved);`
            function emitApprovalForAll(owner, operator, approved) {
                let signatureHash := 0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31
                emit2IndexedEvent(signatureHash, owner, operator, approved)
            }

            /// @notice Emit a TransferBatch event
            /// @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all transfers.
            /// @dev Corresponds to `event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values);`
            /*function emitTransferBatch(operator, from, to, id, amount) {
                let signatureHash := 0x4a39dc06d4c0dbc64b70af90fd698a233a518aa5d07e595d983b8c0526c8f7fb
                emitEvent(signatureHash, from, to, amount)
            }*/

            function emit3IndexedEvent(signatureHash, indexed1, indexed2, indexed3, nonIndexed1, nonIndexed2) {
                mstore(0, nonIndexed1)
                mstore(20, nonIndexed2)
                log4(0, 0x40, signatureHash, indexed1, indexed2, indexed3)
            }

            function emit2IndexedEvent(signatureHash, indexed1, indexed2, nonIndexed) {
                mstore(0, nonIndexed)
                log3(0, 0x20, signatureHash, indexed1, indexed2)
            }

            function debugEmit(value) {
                log1(0, 0x00, value)
            }

            /// @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
            /// @dev Corresponds to `event URI(string _value, uint256 indexed _id);`
            /*function emitURI(value, id) {
                let signatureHash := 0x6bb7ff708619ba0610cba295a58592e0451dee2622938c8755667688daf3529b
                emit2IndexedEvent(signatureHash, owner, operator, approved)
            }*/


        }

    }

}