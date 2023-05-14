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

            // Dispatcher based on selector
            switch selector()
            /// Non-standard functions

            /// ERC-1155 standard: Write functions
            case 0xf242432a /* "safeTransferFrom(address,address,uint256,uint256,bytes)" */ {
                safeTransferFrom(decodeAsAddress(0), decodeAsAddress(1), decodeAsUint(2), decodeAsUint(3))
                returnTrue()
            }
            case 0x2eb2c2d6 /* "safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)" */ {
                approve(decodeAsAddress(0), decodeAsUint(1))
                returnTrue()
            }
            case 0xa22cb465 /* "setApprovalForAll(address,bool)" */ {
                transfer(decodeAsAddress(0), decodeAsUint(1))
                returnTrue()
            }
            /// ERC-1155 standard: Read functions
            case 0x00fdd58e /* "balanceOf(address,uint256)" */ {
                returnUint(balanceOf(decodeAsAddress(0)))
            }
            case 0x4e1273f4 /* "balanceOfBatch(address[],uint256[])" */ {
                returnUint(totalSupply())
            }
            case 0xe985e9c5 /* "isApprovedForAll(address,address)" */ {
                transfer(decodeAsAddress(0), decodeAsUint(1))
                returnTrue()
            }
            /// No fallback functions
            default {
                revert(0, 0)
            }


            ///////////////////////////////////////////////////////////////////////////////////////////////////
            ///                                                                                             ///
            ///                               ERC-1155 standard: Write functions                            ///
            ///                                                                                             ///
            ///////////////////////////////////////////////////////////////////////////////////////////////////

            /// @notice A function to transfer tokens fro
            /// @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
            /// @param from Address from which token will be transfered
            /// @param to Address to which token will be transfered
            /// @param id Token to transfer 
            /// @param value Amount of token to transfer
            /*function safeTransferFrom(offset) -> v {
                // Check that `to` != address(0)

                
                v := decodeAsUint(offset)
                if iszero(iszero(and(v, not(0xffffffffffffffffffffffffffffffffffffffff)))) {
                    revert(0, 0)
                }
            }*/


            ///////////////////////////////////////////////////////////////////////////////////////////////////
            ///                                                                                             ///
            ///                                    Write Helper functions                                   ///
            ///                                                                                             ///
            ///////////////////////////////////////////////////////////////////////////////////////////////////

            function calculateBalanceSlot(id, account) -> slotNumber {
                // keccak256(concatenate(account, keccak256(concatenate(id, slot))))
            }

            ///////////////////////////////////////////////////////////////////////////////////////////////////
            ///                                                                                             ///
            ///                                  Calldata decoding functions                                ///
            ///                                                                                             ///
            ///////////////////////////////////////////////////////////////////////////////////////////////////


            /// @notice This function is used to get function selector from the calldata
            /// @return The function selector from calldata
            function selector() -> s {
                s := shr(calldataload(0), 0xe0)
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
                emit3IndexedEvent(signatureHash, from, to, amount)
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

            /// @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to `approved`.
            /// @dev Corresponds to `event ApprovalForAll(address indexed account, address indexed operator, bool approved);`
            function emitApprovalForAll(owner, operator, approved) {
                let signatureHash := 0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31
                emit2IndexedEvent(signatureHash, owner, operator, approved)
            }

            function emit2IndexedEvent(signatureHash, indexed1, indexed2, nonIndexed) {
                mstore(0, nonIndexed)
                log3(0, 0x20, signatureHash, indexed1, indexed2)
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